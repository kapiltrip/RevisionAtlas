`timescale 1ns/1ps

module ahb_lite_manager_tb;

    localparam [1:0] REQ_SINGLE = 2'b00;
    localparam [1:0] REQ_INCR4  = 2'b01;
    localparam [1:0] REQ_WRAP4  = 2'b10;

    reg          HCLK;
    reg          HRESETn;
    reg          req_valid;
    wire         req_ready;
    reg          req_write;
    reg  [1:0]   req_burst;
    reg  [31:0]  req_addr;
    reg  [127:0] req_wdata;
    wire         done;
    wire         error;
    wire [127:0] rsp_rdata;

    wire [31:0] HADDR;
    wire [2:0]  HBURST;
    wire        HMASTLOCK;
    wire [3:0]  HPROT;
    wire [2:0]  HSIZE;
    wire [1:0]  HTRANS;
    wire [31:0] HWDATA;
    wire        HWRITE;
    wire [31:0] HRDATA;
    wire        HREADY;
    wire        HRESP;

    integer errors;
    integer i;

    ahb_lite_manager dut (
        .HCLK(HCLK),
        .HRESETn(HRESETn),
        .req_valid(req_valid),
        .req_ready(req_ready),
        .req_write(req_write),
        .req_burst(req_burst),
        .req_addr(req_addr),
        .req_wdata(req_wdata),
        .done(done),
        .error(error),
        .rsp_rdata(rsp_rdata),
        .HADDR(HADDR),
        .HBURST(HBURST),
        .HMASTLOCK(HMASTLOCK),
        .HPROT(HPROT),
        .HSIZE(HSIZE),
        .HTRANS(HTRANS),
        .HWDATA(HWDATA),
        .HWRITE(HWRITE),
        .HRDATA(HRDATA),
        .HREADY(HREADY),
        .HRESP(HRESP)
    );

    always #5 HCLK = ~HCLK;

    // ---------------------------------------------------------------------
    // Minimal AHB-Lite subordinate memory model
    // ---------------------------------------------------------------------
    reg [31:0] memory [0:255];
    reg        data_pending_q;
    reg [31:0] data_addr_q;
    reg        data_write_q;
    reg        wait_q;

    // Insert one wait state for addresses whose word offset is 1. This makes
    // every test exercise the manager's HREADY hold behavior.
    assign HREADY = !(data_pending_q && wait_q);
    assign HRESP  = 1'b0;
    assign HRDATA = memory[data_addr_q[9:2]];

    always @(posedge HCLK or negedge HRESETn) begin
        if (!HRESETn) begin
            data_pending_q <= 1'b0;
            data_addr_q    <= 32'b0;
            data_write_q   <= 1'b0;
            wait_q          <= 1'b0;
        end else begin
            // Complete the current data phase when it is no longer stalled.
            if (data_pending_q) begin
                if (wait_q) begin
                    wait_q <= 1'b0;
                end else begin
                    if (data_write_q)
                        memory[data_addr_q[9:2]] <= HWDATA;
                    data_pending_q <= 1'b0;
                end
            end

            // Accept the pipelined address phase on the same edge that the
            // preceding data phase completes.
            if (HREADY && HTRANS[1]) begin
                data_pending_q <= 1'b1;
                data_addr_q    <= HADDR;
                data_write_q   <= HWRITE;
                wait_q          <= (HADDR[3:2] == 2'b01);
            end
        end
    end

    // ---------------------------------------------------------------------
    // Checks and request helper
    // ---------------------------------------------------------------------
    reg [31:0] prev_HADDR;
    reg [2:0]  prev_HBURST;
    reg [2:0]  prev_HSIZE;
    reg [1:0]  prev_HTRANS;
    reg        prev_HWRITE;
    reg [31:0] prev_HWDATA;
    reg        prev_HREADY;

    always @(posedge HCLK) begin
        // If HREADY was LOW for the cycle that just ended, the manager had
        // to hold the transfer stable throughout that extended cycle.
        if (HRESETn && !prev_HREADY && !HRESP) begin
            if ({HADDR, HBURST, HSIZE, HTRANS, HWRITE, HWDATA} !==
                {prev_HADDR, prev_HBURST, prev_HSIZE,
                 prev_HTRANS, prev_HWRITE, prev_HWDATA}) begin
                $display("ERROR: bus outputs changed during an HREADY wait state");
                errors = errors + 1;
            end
        end

        prev_HADDR  <= HADDR;
        prev_HBURST <= HBURST;
        prev_HSIZE  <= HSIZE;
        prev_HTRANS <= HTRANS;
        prev_HWRITE <= HWRITE;
        prev_HWDATA <= HWDATA;
        prev_HREADY <= HREADY;
    end

    task run_request;
        input         write_request;
        input [1:0]   burst_request;
        input [31:0]  start_address;
        input [127:0] write_words;
        begin
            while (!req_ready)
                @(negedge HCLK);

            req_write = write_request;
            req_burst = burst_request;
            req_addr  = start_address;
            req_wdata = write_words;
            req_valid = 1'b1;
            @(negedge HCLK);
            req_valid = 1'b0;

            while (!done)
                @(negedge HCLK);

            if (error) begin
                $display("ERROR: request at address %08h failed", start_address);
                errors = errors + 1;
            end
        end
    endtask

    task expect_word;
        input [31:0] address;
        input [31:0] expected;
        begin
            if (memory[address[9:2]] !== expected) begin
                $display("ERROR: memory[%08h] = %08h, expected %08h",
                         address, memory[address[9:2]], expected);
                errors = errors + 1;
            end
        end
    endtask

    task expect_read_pack;
        input [127:0] expected;
        begin
            if (rsp_rdata !== expected) begin
                $display("ERROR: rsp_rdata = %032h, expected %032h",
                         rsp_rdata, expected);
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        HCLK       = 1'b0;
        HRESETn    = 1'b0;
        req_valid  = 1'b0;
        req_write  = 1'b0;
        req_burst  = REQ_SINGLE;
        req_addr   = 32'b0;
        req_wdata  = 128'b0;
        errors     = 0;

        for (i = 0; i < 256; i = i + 1)
            memory[i] = 32'b0;

        $dumpfile("ahb_lite_manager.vcd");
        $dumpvars(0, ahb_lite_manager_tb);

        repeat (3) @(negedge HCLK);
        HRESETn = 1'b1;

        // One normal word transfer.
        run_request(1'b1, REQ_SINGLE, 32'h0000_0080,
                    128'h0_0_0_CAFE_BABE);
        expect_word(32'h0000_0080, 32'hCAFE_BABE);

        // Four sequential word addresses: 0x20, 0x24, 0x28, 0x2C.
        run_request(1'b1, REQ_INCR4, 32'h0000_0020,
                    128'h4444_4444_3333_3333_2222_2222_1111_1111);
        expect_word(32'h0000_0020, 32'h1111_1111);
        expect_word(32'h0000_0024, 32'h2222_2222);
        expect_word(32'h0000_0028, 32'h3333_3333);
        expect_word(32'h0000_002C, 32'h4444_4444);

        run_request(1'b0, REQ_INCR4, 32'h0000_0020, 128'b0);
        expect_read_pack(128'h4444_4444_3333_3333_2222_2222_1111_1111);

        // WRAP4 at 0x3C stays inside the 16-byte region 0x30-0x3F:
        // 0x3C, 0x30, 0x34, 0x38.
        run_request(1'b1, REQ_WRAP4, 32'h0000_003C,
                    128'hA3A3_A3A3_A2A2_A2A2_A1A1_A1A1_A0A0_A0A0);
        expect_word(32'h0000_003C, 32'hA0A0_A0A0);
        expect_word(32'h0000_0030, 32'hA1A1_A1A1);
        expect_word(32'h0000_0034, 32'hA2A2_A2A2);
        expect_word(32'h0000_0038, 32'hA3A3_A3A3);

        run_request(1'b0, REQ_WRAP4, 32'h0000_003C, 128'b0);
        expect_read_pack(128'hA3A3_A3A3_A2A2_A2A2_A1A1_A1A1_A0A0_A0A0);

        // Local interface validation: unaligned word requests are rejected
        // without starting an AHB transfer.
        while (!req_ready)
            @(negedge HCLK);
        req_addr  = 32'h0000_0022;
        req_burst = REQ_SINGLE;
        req_write = 1'b1;
        req_valid = 1'b1;
        @(negedge HCLK);
        req_valid = 1'b0;
        if (!(done && error)) begin
            $display("ERROR: unaligned request was not rejected");
            errors = errors + 1;
        end

        repeat (2) @(negedge HCLK);
        if (errors == 0)
            $display("PASS: SINGLE, INCR4, WRAP4, reads, writes, and wait states verified");
        else
            $display("FAIL: %0d error(s)", errors);

        $finish;
    end

endmodule
