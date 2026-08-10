/*
 * REVISION ATLAS - INSTRUCTOR COURSE CODE (COMMENTS ADDED ONLY)
 * Section 03: AXI-Stream IPs
 * Lecture path: Lessons 34-38 - Two-Input AXI-Stream Arbiter
 * Downloadable source page: Lesson 038
 * Module: tb_axis_arb
 * Role: Instructor-supplied testbench/stimulus
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
module tb_axis_arb;
 // Define testbench ports



 // Signal definition - aclk: clock used to sample the course FSM and interface handshakes on rising edges.
 reg aclk = 0;
 // Signal definition - aresetn: active-LOW reset for the course FSM and handshake outputs.
 reg aresetn;
 // Signal definition - s_axis_tready1: readiness/acceptance control used by the matching course handshake.
 wire s_axis_tready1;
 // Signal definition - s_axis_tready2: readiness/acceptance control used by the matching course handshake.
 wire s_axis_tready2;
 // Signal definition - s_axis_tvalid1: validity control indicating that the matching course payload or response is offered.
 reg s_axis_tvalid1;
 // Signal definition - s_axis_tvalid2: validity control indicating that the matching course payload or response is offered.
 reg s_axis_tvalid2;
 // Signal definition - s_axis_tdata1: payload offered by AXI-Stream input 1.
 reg [7:0] s_axis_tdata1;
 // Signal definition - s_axis_tdata2: payload offered by AXI-Stream input 2.
 reg [7:0] s_axis_tdata2;
 // Signal definition - s_axis_tlast1: packet-end marker accompanying AXI-Stream input 1.
 reg s_axis_tlast1;
 // Signal definition - s_axis_tlast2: packet-end marker accompanying AXI-Stream input 2.
 reg s_axis_tlast2;
 // Signal definition - m_axis_tready: AXI-Stream output READY returned by the downstream Receiver.
 reg m_axis_tready;
 // Signal definition - m_axis_tvalid: AXI-Stream output VALID presented to the downstream Receiver.
 wire m_axis_tvalid;
 // Signal definition - m_axis_tdata: AXI-Stream output payload for the currently offered beat.
 wire [7:0] m_axis_tdata;
 // Signal definition - m_axis_tlast: AXI-Stream output packet-end marker paired with the current beat.
 wire m_axis_tlast;

 // Instantiate the axis_arb module
 axis_arb dut (
 .aclk(aclk),
 .aresetn(aresetn),
 .s_axis_tready1(s_axis_tready1),
 .s_axis_tready2(s_axis_tready2),
 .s_axis_tvalid1(s_axis_tvalid1),
 .s_axis_tvalid2(s_axis_tvalid2),
 .s_axis_tdata1(s_axis_tdata1),
 .s_axis_tdata2(s_axis_tdata2),
 .s_axis_tlast1(s_axis_tlast1),
 .s_axis_tlast2(s_axis_tlast2),
 .m_axis_tready(m_axis_tready),
 .m_axis_tvalid(m_axis_tvalid),
 .m_axis_tdata(m_axis_tdata),
 .m_axis_tlast(m_axis_tlast)
 );

always #10 aclk = ~aclk;

initial begin
aresetn = 0;
repeat(10) @(posedge aclk);
aresetn = 1;
for(int i = 0; i < 5; i++)
begin
@(posedge aclk);
s_axis_tvalid1 = 1;
s_axis_tvalid2 = 0;
s_axis_tlast1 = 0;
s_axis_tlast2 = 0;
s_axis_tdata1 = $random();
s_axis_tdata2 = $random();
m_axis_tready = 1;
end
@(posedge aclk);
s_axis_tdata1 = $random();
s_axis_tlast1 = 1;
@(posedge aclk);
s_axis_tlast1 = 0;
s_axis_tvalid1 = 0;

for(int i = 0; i < 5; i++)
begin
@(posedge aclk);
s_axis_tvalid1 = 0;
s_axis_tvalid2 = 1;
s_axis_tdata1 = $random();
s_axis_tdata2 = $random();
m_axis_tready = 1;
s_axis_tlast2 = 0;
end
@(posedge aclk);
s_axis_tdata2 = $random();
s_axis_tlast2 = 1;
@(posedge aclk);
s_axis_tlast2 = 0;
s_axis_tvalid2 = 0;
$stop;
end
 // Testbench code here
 // You can apply stimulus to the input ports and monitor the output ports
endmodule
