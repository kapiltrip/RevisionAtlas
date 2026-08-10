/*
 * REVISION ATLAS - INSTRUCTOR COURSE CODE (COMMENTS ADDED ONLY)
 * Section 03: AXI-Stream IPs
 * Lecture path: Lessons 34-38 - Two-Input AXI-Stream Arbiter
 * Downloadable source page: Lesson 038
 * Module: axis_arb
 * Role: Instructor design RTL
 *
 * PRESERVATION:
 * - Module name, port/signal names, architecture, state flow, and executable
 *   statements are the instructor's. The repository adds comments and splits
 *   multi-module lesson blocks into named files only.
 *
 * ASSUMPTIONS:
 * - Each input uses 8-bit TDATA and TLAST marks the packet boundary.
 * - The selected source owns the output until the course FSM changes selection.
 * - aresetn is active LOW.
 *
 * USED / OMITTED / SIMPLIFIED:
 * - TKEEP, TSTRB, TID, TDEST, and TUSER are not routed.
 * - The teaching VALID/READY relationship is retained exactly, including its simplified READY-dependent behavior.
 *
 * BEHAVIORAL CONSEQUENCE:
 * - The code reproduces the lecture waveform but is not protocol-hardened for arbitrary back-pressure.
 * - Do not add sidebands without routing the entire selected beat bundle through the same selection.
 */
module axis_arb (
 // Signal definition - aclk: clock used to sample the course FSM and interface handshakes on rising edges.
 input wire aclk,
 // Signal definition - aresetn: active-LOW reset for the course FSM and handshake outputs.
 input wire aresetn,
 // Signal definition - s_axis_tready1: readiness/acceptance control used by the matching course handshake.
 output wire s_axis_tready1,
 // Signal definition - s_axis_tready2: readiness/acceptance control used by the matching course handshake.
 output wire s_axis_tready2,
 // Signal definition - s_axis_tvalid1: validity control indicating that the matching course payload or response is offered.
 input wire s_axis_tvalid1,
 // Signal definition - s_axis_tvalid2: validity control indicating that the matching course payload or response is offered.
 input wire s_axis_tvalid2,
 // Signal definition - s_axis_tdata1: payload offered by AXI-Stream input 1.
 input wire [7:0] s_axis_tdata1,
 // Signal definition - s_axis_tdata2: payload offered by AXI-Stream input 2.
 input wire [7:0] s_axis_tdata2,
 // Signal definition - s_axis_tlast1: packet-end marker accompanying AXI-Stream input 1.
 input wire s_axis_tlast1,
 // Signal definition - s_axis_tlast2: packet-end marker accompanying AXI-Stream input 2.
 input wire s_axis_tlast2,
 // Signal definition - m_axis_tready: AXI-Stream output READY returned by the downstream Receiver.
 input wire m_axis_tready,
 // Signal definition - m_axis_tvalid: AXI-Stream output VALID presented to the downstream Receiver.
 output wire m_axis_tvalid,
 // Signal definition - m_axis_tdata: AXI-Stream output payload for the currently offered beat.
 output wire [7:0] m_axis_tdata,
 // Signal definition - m_axis_tlast: AXI-Stream output packet-end marker paired with the current beat.
 output wire m_axis_tlast
);

// State definition - encoded FSM states used by the instructor's next-state logic.
typedef enum logic [1:0] {idle = 2'b00, s1 = 2'b01, s2 = 2'b10} state_type;
state_type state, next_state;

assign s_axis_tready1 = 1'b1;
assign s_axis_tready2 = 1'b1;

always @(posedge aclk) begin
 if (aresetn == 1'b0)
 state <= idle;
 else
 state <= next_state;
end

///////////////////
// Signal definition - reg_tdata: combinationally selected payload from whichever AXI-Stream input currently owns the output.
reg [7:0] reg_tdata;
// Signal definition - reg_tlast: combinationally selected TLAST from whichever AXI-Stream input currently owns the output.
reg reg_tlast;

always @(*) begin
 case (state)
 idle: begin
 if (s_axis_tvalid1 && s_axis_tready1) begin
 next_state = s1;
 reg_tdata = s_axis_tdata1;
 reg_tlast = s_axis_tlast1;
 end else if (s_axis_tvalid2 && s_axis_tready2) begin
 next_state = s2;
 reg_tdata = s_axis_tdata2;
 reg_tlast = s_axis_tlast2;
 end else
 next_state = idle;
 end

 s1: begin
 if (m_axis_tready == 1'b1) begin
 if (s_axis_tlast1) begin
 reg_tdata = s_axis_tdata1;
 reg_tlast = s_axis_tlast1;
 if (s_axis_tvalid2 && s_axis_tready2)
 next_state = s2;
 else
 next_state = idle;
 end else begin
 next_state = s1;
 reg_tdata = s_axis_tdata1;
 reg_tlast = s_axis_tlast1;
 end
 end else begin
 next_state = s1;
 end
 end

 s2: begin
 if (m_axis_tready == 1'b1) begin
 if (s_axis_tlast2) begin
 reg_tdata = s_axis_tdata2;
 reg_tlast = s_axis_tlast2;
 if (s_axis_tvalid1 && s_axis_tready1)
 next_state = s1;
 else
 next_state = idle;
 end else begin
 next_state = s2;
 reg_tdata = s_axis_tdata2;
 reg_tlast = s_axis_tlast2;
 end
 end else begin
 next_state = s2;
 end
 end

 default: next_state = idle;
 endcase
end

assign m_axis_tdata = ((s_axis_tvalid1 && s_axis_tready1)||(s_axis_tvalid2 && s_axis_tready2)) ? reg_tdata : 8'h00;
assign m_axis_tlast = ((s_axis_tvalid1 && s_axis_tready1)||(s_axis_tvalid2 && s_axis_tready2)) ? reg_tlast : 1'b0;
assign m_axis_tvalid = ((s_axis_tvalid1 && s_axis_tready1)||(s_axis_tvalid2 && s_axis_tready2)) ? 1'b1 : 1'b0;

endmodule
