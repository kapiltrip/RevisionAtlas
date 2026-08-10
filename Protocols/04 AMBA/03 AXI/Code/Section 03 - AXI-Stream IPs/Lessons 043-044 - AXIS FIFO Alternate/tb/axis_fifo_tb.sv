/*
 * REVISION ATLAS - INSTRUCTOR COURSE CODE (COMMENTS ADDED ONLY)
 * Section 03: AXI-Stream IPs
 * Lecture path: Lessons 43-44 - AXI-Stream FIFO Alternate
 * Downloadable source page: Lesson 044
 * Module: axis_fifo_tb
 * Role: Instructor-supplied testbench/stimulus
 *
 * PRESERVATION:
 * - Module name, port/signal names, architecture, state flow, and executable
 *   statements are the instructor's. The repository adds comments and splits
 *   multi-module lesson blocks into named files only.
 *
 * ASSUMPTIONS:
 * - The current memory head is presented through the alternate combinational output style.
 * - One clock domain carries TDATA, TKEEP, and TLAST.
 * - The course pointer, count, full, and empty rules are preserved.
 *
 * USED / OMITTED / SIMPLIFIED:
 * - TSTRB, TID, TDEST, TUSER, CDC support, and parameterization are absent.
 * - The course event-priority behavior is retained rather than redesigned.
 *
 * BEHAVIORAL CONSEQUENCE:
 * - The read-memory style assumes a target that can present the addressed entry as written.
 * - A synchronous block RAM may require a different registered architecture, which is intentionally not added here.
 */
`timescale 1ns / 1ps

module axis_fifo_tb;


 // Inputs
 // Signal definition - aclk: clock used to sample the course FSM and interface handshakes on rising edges.
 reg aclk;
 // Signal definition - aresetn: active-LOW reset for the course FSM and handshake outputs.
 reg aresetn;
 // Signal definition - s_axis_tvalid: AXI-Stream input VALID driven by the upstream Transmitter.
 reg s_axis_tvalid;
 // Signal definition - s_axis_tdata: AXI-Stream input payload associated with the current offered beat.
 reg [7:0] s_axis_tdata;
 // Signal definition - s_axis_tkeep: AXI-Stream input byte-lane qualifier stored and forwarded with TDATA.
 reg s_axis_tkeep;
 // Signal definition - s_axis_tlast: AXI-Stream input packet-end marker associated with the current beat.
 reg s_axis_tlast;

 // Outputs
 // Signal definition - m_axis_tvalid: AXI-Stream output VALID presented to the downstream Receiver.
 wire m_axis_tvalid;
 // Signal definition - m_axis_tdata: AXI-Stream output payload for the currently offered beat.
 wire [7:0] m_axis_tdata;
 // Signal definition - m_axis_tkeep: AXI-Stream output byte-lane qualifier paired with TDATA.
 wire m_axis_tkeep;
 // Signal definition - m_axis_tlast: AXI-Stream output packet-end marker paired with the current beat.
 wire m_axis_tlast;
 // Signal definition - m_axis_tready: AXI-Stream output READY returned by the downstream Receiver.
 reg m_axis_tready;

 // Instantiate the DUT
 axis_fifo dut (
 .aclk(aclk),
 .aresetn(aresetn),
 .s_axis_tvalid(s_axis_tvalid),
 .s_axis_tdata(s_axis_tdata),
 .s_axis_tkeep(s_axis_tkeep),
 .s_axis_tlast(s_axis_tlast),
 .m_axis_tvalid(m_axis_tvalid),
 .m_axis_tdata(m_axis_tdata),
 .m_axis_tkeep(m_axis_tkeep),
 .m_axis_tlast(m_axis_tlast),
 .m_axis_tready(m_axis_tready)
 );

 // Clock generation
 always #10 aclk = ~aclk;

 // Initial stimulus
 initial begin
 // Initialize inputs
 aclk = 0;
 aresetn = 0;
 s_axis_tvalid = 0;
 s_axis_tdata = 8'h00;
 s_axis_tkeep = 1'b0;
 s_axis_tlast = 0;

 repeat(5) @(posedge aclk);
 aresetn = 1;
 for(int i = 0; i < 20 ; i++)
 begin
 @(posedge aclk);
 m_axis_tready = 0;
 s_axis_tvalid = 1;
 s_axis_tdata = $random();
 s_axis_tkeep = 1'b1;
 s_axis_tlast = 0;
 end

 for(int i = 0; i < 20 ; i++)
 begin
 @(posedge aclk);
 s_axis_tvalid = 0;
 m_axis_tready = 1;
 s_axis_tdata = 0;
 s_axis_tkeep = 0;
 s_axis_tlast = 0;
 end


 #10 $finish;
 end

endmodule
