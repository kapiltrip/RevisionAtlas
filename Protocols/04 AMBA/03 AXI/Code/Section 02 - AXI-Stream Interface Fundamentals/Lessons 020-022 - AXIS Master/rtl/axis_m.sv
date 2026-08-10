/*
 * REVISION ATLAS - INSTRUCTOR COURSE CODE (COMMENTS ADDED ONLY)
 * Section 02: AXI-Stream Interface Fundamentals
 * Lecture path: Lessons 20-22 - AXI-Stream Master
 * Downloadable source page: Lesson 022
 * Module: axis_m
 * Role: Instructor design RTL
 *
 * PRESERVATION:
 * - Module name, port/signal names, architecture, state flow, and executable
 *   statements are the instructor's. The repository adds comments and splits
 *   multi-module lesson blocks into named files only.
 *
 * ASSUMPTIONS:
 * - newd starts a packet and din remains stable for the complete packet.
 * - The packet always contains four 8-bit beats: din multiplied by count 0, 1, 2, and 3.
 * - m_axis_aresetn is sampled synchronously and is active LOW.
 *
 * USED / OMITTED / SIMPLIFIED:
 * - TKEEP, TSTRB, TID, TDEST, TUSER, and configurable packet length are not implemented.
 * - There is no local ready/acknowledge signal for newd and no input payload buffer.
 *
 * BEHAVIORAL CONSEQUENCE:
 * - Changing din during a stall can change the offered TDATA even though the beat was not accepted.
 * - Arithmetic truncates naturally to eight bits.
 */
module axis_m(
    // Signal definition - m_axis_aclk: clock used to sample the course FSM and interface handshakes on rising edges.
    input  wire m_axis_aclk,
    // Signal definition - m_axis_aresetn: active-LOW reset used by the course state and output logic.
    input  wire m_axis_aresetn,
    // Signal definition - newd: local request that tells the AXI-Stream source to start a new fixed packet.
    input  wire newd,
    // Signal definition - din: local payload/data input consumed by the course transaction generator.
    input  wire [7:0] din,
    // Signal definition - m_axis_tready: AXI-Stream output READY returned by the downstream Receiver.
    input  wire m_axis_tready,
    // Signal definition - m_axis_tvalid: AXI-Stream output VALID presented to the downstream Receiver.
    output wire m_axis_tvalid,
    // Signal definition - m_axis_tdata: AXI-Stream output payload for the currently offered beat.
    output wire [7:0] m_axis_tdata,
    // Signal definition - m_axis_tlast: AXI-Stream output packet-end marker paired with the current beat.
    output wire m_axis_tlast
    );

    // State definition - encoded FSM states used by the instructor's next-state logic.
    typedef enum bit {idle = 1'b0, tx = 1'b1} state_type;
    state_type state = idle, next_state = idle;

    // Signal definition - count: current packet beat index (0-3); it scales DIN and asserts TLAST on beat 3.
    reg [2:0] count = 0;


    always@(posedge m_axis_aclk)
    begin
    if(m_axis_aresetn == 1'b0)
        state <= idle;
    else
        state <= next_state;
    end


    always@(posedge m_axis_aclk)
    begin
    if(state == idle)
       count <= 0;
    else if(state == tx && count != 3 && m_axis_tready == 1'b1)
        count <= count +1;
    else
        count <= count;
    end


    always@(*)
    begin
       case(state)
               idle:
               begin
                    if(newd == 1'b1)
                      next_state = tx;
                    else
                      next_state = idle;
               end

               tx:
               begin
                    if(m_axis_tready == 1'b1)
                    begin
                        if(count != 3)
                        next_state  = tx;
                        else
                        next_state  = idle;
                    end
                    else
                    begin
                        next_state  = tx;
                    end
                end

               default: next_state = idle;

               endcase

        end

 assign m_axis_tdata   = (m_axis_tvalid) ? din*count : 0;
 assign m_axis_tlast   = (count == 3 && state == tx)    ? 1'b1 : 0;
 assign m_axis_tvalid  = (state == tx ) ? 1'b1 : 1'b0;


endmodule
