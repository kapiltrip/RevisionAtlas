/*
 * REVISION ATLAS - INSTRUCTOR COURSE CODE (COMMENTS ADDED ONLY)
 * Section 02: AXI-Stream Interface Fundamentals
 * Lecture path: Lessons 23-26 - AXI-Stream Slave
 * Downloadable source page: Lesson 026
 * Module: axis_s
 * Role: Instructor design RTL
 *
 * PRESERVATION:
 * - Module name, port/signal names, architecture, state flow, and executable
 *   statements are the instructor's. The repository adds comments and splits
 *   multi-module lesson blocks into named files only.
 *
 * ASSUMPTIONS:
 * - The interface carries 8-bit TDATA plus TVALID, TREADY, and TLAST.
 * - s_axis_aresetn is active LOW and sampled by the course state register.
 * - The source is expected to hold a beat until the Receiver raises TREADY.
 *
 * USED / OMITTED / SIMPLIFIED:
 * - TKEEP, TSTRB, TID, TDEST, TUSER, buffering, and a downstream output handshake are absent.
 * - dout is a combinational view in the store state, not a retained payload register.
 *
 * BEHAVIORAL CONSEQUENCE:
 * - A consumer cannot treat dout as stored data after the state leaves store.
 * - The implementation is a teaching endpoint and can insert readiness bubbles.
 */
module axis_s(
    // Signal definition - s_axis_aclk: clock used to sample the course FSM and interface handshakes on rising edges.
    input  wire s_axis_aclk,
    // Signal definition - s_axis_aresetn: active-LOW reset used by the course state and output logic.
    input  wire s_axis_aresetn,
    // Signal definition - s_axis_tready: AXI-Stream input READY returned by this Receiver/path.
    output wire s_axis_tready,
    // Signal definition - s_axis_tvalid: AXI-Stream input VALID driven by the upstream Transmitter.
    input  wire s_axis_tvalid,
    // Signal definition - s_axis_tdata: AXI-Stream input payload associated with the current offered beat.
    input  wire [7:0] s_axis_tdata,
    // Signal definition - s_axis_tlast: AXI-Stream input packet-end marker associated with the current beat.
    input  wire s_axis_tlast,
    // Signal definition - dout: local data output exposed by the receiver or completed read path.
    output wire [7:0] dout
    );

    // State definition - encoded FSM states used by the instructor's next-state logic.
    typedef enum bit [1:0] {idle = 2'b00, store = 2'b01, last_byte = 2'b10} state_type;
    state_type state = idle, next_state = idle;

    always@(posedge s_axis_aclk)
    begin
    if(s_axis_aresetn == 1'b0)
    state  <= idle;
    else
    state <= next_state;
    end


    always@(*)
        begin
               case(state)
               idle:
                begin
                    if(s_axis_tvalid == 1'b1)
                      next_state = store;
                    else
                      next_state = idle;
                end

               store:
                begin
                if(s_axis_tlast == 1'b1 && s_axis_tvalid == 1'b1 )
                      next_state = idle;
                 else if (s_axis_tlast == 1'b0 && s_axis_tvalid == 1'b1)
                      next_state = store;
                 else
                      next_state = idle;
               end

               default: next_state = idle;

               endcase
         end



assign s_axis_tready = (state == store);
assign dout          = (state == store ) ? s_axis_tdata : 8'h00;


endmodule
