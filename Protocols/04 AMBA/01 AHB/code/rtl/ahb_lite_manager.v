`timescale 1ns/1ps

// Educational AMBA AHB-Lite manager.
//
// Scope kept intentionally small:
//   * 32-bit data bus and word transfers only (HSIZE = 3'b010)
//   * SINGLE, INCR4, and WRAP4 bursts
//   * one command at a time
//   * one pipelined AHB address phase plus its following data phase
//
// req_wdata packs four possible write beats:
//   beat 0 = req_wdata[31:0]
//   beat 1 = req_wdata[63:32]
//   beat 2 = req_wdata[95:64]
//   beat 3 = req_wdata[127:96]
// rsp_rdata uses the same packing for completed read beats.
module ahb_lite_manager (
    input  wire         HCLK,       // AHB clock; transfers sample on rising edges.
    input  wire         HRESETn,    // Active-LOW reset; asynchronous assertion here.

    // Small command interface used by the testbench or a local controller.
    input  wire         req_valid,  // Offers one command with all req_* fields.
    output wire         req_ready,  // HIGH only while a new command can be accepted.
    input  wire         req_write,  // 1 = write, 0 = read.
    input  wire [1:0]   req_burst,  // Local 00=SINGLE, 01=INCR4, 10=WRAP4 code.
    input  wire [31:0]  req_addr,   // Byte address of the first word-aligned beat.
    input  wire [127:0] req_wdata,  // Four packed 32-bit write beats, beat 0 in [31:0].

    output reg          done,       // One-cycle command-completion/rejection pulse.
    output reg          error,      // One-cycle local-reject or AHB-error pulse.
    output reg  [127:0] rsp_rdata,  // Packed completed read beats, beat 0 in [31:0].

    // AHB-Lite manager interface.
    output reg  [31:0]  HADDR,      // Current address-phase byte address.
    output wire [2:0]   HBURST,     // Address-phase burst type.
    output wire         HMASTLOCK,  // Locked-sequence indicator; tied LOW here.
    output wire [3:0]   HPROT,      // Address-phase protection attributes.
    output wire [2:0]   HSIZE,      // Transfer size; fixed to 32-bit words.
    output reg  [1:0]   HTRANS,     // Address-phase IDLE/NONSEQ/SEQ transfer type.
    output wire [31:0]  HWDATA,     // Write payload for the older data phase.
    output reg          HWRITE,     // Address-phase direction: 1=write, 0=read.

    input  wire [31:0]  HRDATA,     // Read payload for the active data phase.
    input  wire         HREADY,     // Completes data and advances address when HIGH.
    input  wire         HRESP       // Active data-phase response: 0=OKAY, 1=ERROR.
);

    // Local command encodings. These are not the HBURST wire encodings.
    localparam [1:0] REQ_SINGLE = 2'b00;
    localparam [1:0] REQ_INCR4  = 2'b01;
    localparam [1:0] REQ_WRAP4  = 2'b10;

    // AHB transfer-type encodings.
    localparam [1:0] HTRANS_IDLE   = 2'b00;
    localparam [1:0] HTRANS_NONSEQ = 2'b10;
    localparam [1:0] HTRANS_SEQ    = 2'b11;

    localparam STATE_IDLE   = 1'b0;
    localparam STATE_ACTIVE = 1'b1;

    reg         state_q;
    reg         write_q;
    reg  [1:0]  burst_q;
    reg  [127:0] write_data_q;

    // addr_index_q identifies the address phase currently on HADDR.
    // data_index_q identifies the following data phase currently in progress.
    reg  [1:0]  addr_index_q;
    reg  [1:0]  data_index_q;
    reg         data_valid_q;

    assign req_ready = (state_q == STATE_IDLE);

    // This example always transfers 32-bit words.
    assign HSIZE     = 3'b010;
    assign HMASTLOCK = 1'b0;

    // Data access, privileged, not bufferable, not cacheable.
    assign HPROT = 4'b0011;

    // Translate the compact local request into the standard AHB encoding.
    assign HBURST = (burst_q == REQ_INCR4) ? 3'b011 :
                    (burst_q == REQ_WRAP4) ? 3'b010 :
                                             3'b000;

    // Write data belongs to the data phase, one cycle after its address phase.
    assign HWDATA = !data_valid_q ? 32'b0 :
                   (data_index_q == 2'd0) ? write_data_q[31:0]   :
                   (data_index_q == 2'd1) ? write_data_q[63:32]  :
                   (data_index_q == 2'd2) ? write_data_q[95:64]  :
                                             write_data_q[127:96];

    // Calculate the address of the next word beat.
    // A four-beat word WRAP4 burst wraps inside a 4 * 4-byte = 16-byte region.
    function [31:0] next_word_address;
        input [31:0] current_address;
        input [1:0]  burst_kind;
        begin
            if (burst_kind == REQ_WRAP4)
                next_word_address = {
                    current_address[31:4],
                    (current_address[3:0] + 4'd4) & 4'hF
                };
            else
                next_word_address = current_address + 32'd4;
        end
    endfunction

    // Save a completed read beat in the same beat ordering as req_wdata.
    task capture_read_data;
        input [1:0]  beat_index;
        input [31:0] read_value;
        begin
            case (beat_index)
                2'd0: rsp_rdata[31:0]   <= read_value;
                2'd1: rsp_rdata[63:32]  <= read_value;
                2'd2: rsp_rdata[95:64]  <= read_value;
                2'd3: rsp_rdata[127:96] <= read_value;
            endcase
        end
    endtask

    always @(posedge HCLK or negedge HRESETn) begin
        if (!HRESETn) begin
            state_q       <= STATE_IDLE;
            write_q       <= 1'b0;
            burst_q       <= REQ_SINGLE;
            write_data_q  <= 128'b0;
            addr_index_q  <= 2'b0;
            data_index_q  <= 2'b0;
            data_valid_q  <= 1'b0;
            done           <= 1'b0;
            error          <= 1'b0;
            rsp_rdata      <= 128'b0;
            HADDR          <= 32'b0;
            HTRANS         <= HTRANS_IDLE;
            HWRITE         <= 1'b0;
        end else begin
            // Status outputs are one-clock pulses.
            done  <= 1'b0;
            error <= 1'b0;

            case (state_q)
                STATE_IDLE: begin
                    HTRANS        <= HTRANS_IDLE;
                    data_valid_q  <= 1'b0;

                    if (req_valid) begin
                        // Word transfers must be word aligned. 2'b11 is reserved
                        // in the small local request encoding used by this module.
                        if ((req_addr[1:0] != 2'b00) ||
                            (req_burst == 2'b11)) begin
                            done  <= 1'b1;
                            error <= 1'b1;
                        end else begin
                            state_q       <= STATE_ACTIVE;
                            write_q       <= req_write;
                            burst_q       <= req_burst;
                            write_data_q  <= req_wdata;
                            addr_index_q  <= 2'd0;
                            data_index_q  <= 2'd0;
                            data_valid_q  <= 1'b0;
                            rsp_rdata      <= 128'b0;

                            HADDR  <= req_addr;
                            HWRITE <= req_write;
                            HTRANS <= HTRANS_NONSEQ;
                        end
                    end
                end

                STATE_ACTIVE: begin
                    // HRESP can assert in the first cycle of the two-cycle AHB
                    // ERROR response while HREADY is LOW. HTRANS is allowed to
                    // change to IDLE here so the pipelined next address is cancelled.
                    if (data_valid_q && HRESP && !HREADY) begin
                        HTRANS <= HTRANS_IDLE;
                    end else if (HREADY) begin
                        // First finish the data phase that was accepted previously.
                        if (data_valid_q && HRESP) begin
                            state_q      <= STATE_IDLE;
                            data_valid_q <= 1'b0;
                            HTRANS       <= HTRANS_IDLE;
                            done          <= 1'b1;
                            error         <= 1'b1;
                        end else begin
                            if (data_valid_q && !write_q)
                                capture_read_data(data_index_q, HRDATA);

                            // A valid address phase is accepted only when HREADY is HIGH.
                            if (HTRANS[1]) begin
                                data_valid_q <= 1'b1;
                                data_index_q <= addr_index_q;

                                if ((burst_q == REQ_SINGLE) ||
                                    (addr_index_q == 2'd3)) begin
                                    // No new address follows, but the accepted address
                                    // still has one data phase left to complete.
                                    HTRANS <= HTRANS_IDLE;
                                end else begin
                                    addr_index_q <= addr_index_q + 2'd1;
                                    HADDR         <= next_word_address(HADDR, burst_q);
                                    HTRANS        <= HTRANS_SEQ;
                                end
                            end else if (data_valid_q) begin
                                // HTRANS was already IDLE, so this edge completes
                                // the final outstanding data phase.
                                state_q      <= STATE_IDLE;
                                data_valid_q <= 1'b0;
                                done          <= 1'b1;
                            end
                        end
                    end
                    // When HREADY is LOW and HRESP is LOW, every address/control
                    // output and the data-phase index deliberately holds its value.
                end
            endcase
        end
    end

endmodule
