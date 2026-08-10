/*
 * REVISION ATLAS - INSTRUCTOR COURSE CODE (COMMENTS ADDED ONLY)
 * Section 05: AXI-Lite Single Beat without Pipeline
 * Lecture path: Lessons 73-81 - AXI-Lite Read-Only Master/Slave
 * Downloadable source page: Lesson 081
 * Module: tb
 * Role: Instructor-supplied testbench/stimulus
 *
 * PRESERVATION:
 * - Module/signal names, executable statements, FSM architecture, and stimulus
 *   are retained. Only comments and one-module-per-file organization were added.
 *
 * ASSUMPTIONS:
 * - AR and R carry one read at a time.
 * - Manager and subordinate share one clock and active-LOW reset.
 * - No request is pipelined behind another.
 *
 * USED / OMITTED / SIMPLIFIED:
 * - AW/W/B write channels, IDs, bursts, and optional signals absent from the course ports are omitted.
 *
 * BEHAVIORAL CONSEQUENCE:
 * - Only single-beat reads are demonstrated.
 * - The top inherits the instructor timing of p_m_axi and p_s_axi.
 */
module tb;

// Declare testbench signals
// Signal definition - i_addrin: local command address loaded into the manager's AXI address channel.
reg [31:0] i_addrin;
// Signal definition - i_wr: local operation control; asserted starts writes in write lessons, while deasserted selects reads in the read-only lesson.
reg i_wr = 0;
// Signal definition - m_axi_aclk: rising-edge clock for the retained FSM and handshakes.
reg m_axi_aclk = 0;
// Signal definition - m_axi_aresetn: active-LOW reset for the course state/output logic.
reg m_axi_aresetn = 0;
// Signal definition - o_rdata: AXI read payload.
wire [31:0] o_rdata;
// Signal definition - o_resp: response/status value associated with the completed channel.
wire [1:0] o_resp;

// Instantiate the design under test (DUT)
top DUT (
 .i_addrin(i_addrin),
 .i_wr(i_wr),
 .m_axi_aclk(m_axi_aclk),
 .m_axi_aresetn(m_axi_aresetn),
 .o_rdata(o_rdata),
 .o_resp(o_resp)
);

// Clock generation
initial begin
 m_axi_aclk = 0;
 forever #10 m_axi_aclk = ~m_axi_aclk; // 100 MHz clock
end

// Reset generation
initial begin
 m_axi_aresetn = 0;
 #20 m_axi_aresetn = 1;
end

// Signal definition - i: loop index used by initialization or TB stimulus.
integer i = 0;

// Stimulus
initial begin
 @(posedge m_axi_aresetn);
 for (i = 0; i < 10; i = i + 1) begin
 @(posedge m_axi_aclk);
 i_addrin = $urandom_range(0, 15);
 @(posedge DUT.mdut.m_axi_rready);
 end
 $finish; // End simulation
end

endmodule
