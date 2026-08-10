/*
 * REVISION ATLAS - INSTRUCTOR COURSE CODE (COMMENTS ADDED ONLY)
 * Section 05: AXI-Lite Single Beat without Pipeline
 * Lecture path: Lessons 73-81 - AXI-Lite Read-Only Master/Slave
 * Downloadable source page: Lesson 081
 * Module: top
 * Role: Instructor integration/top-level RTL
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
module top (
 // Signal definition - i_addrin: local command address loaded into the manager's AXI address channel.
 input [31:0] i_addrin,
 // Signal definition - i_wr: local operation control; asserted starts writes in write lessons, while deasserted selects reads in the read-only lesson.
 input i_wr,
 // Signal definition - m_axi_aclk: rising-edge clock for the retained FSM and handshakes.
 input m_axi_aclk,
 // Signal definition - m_axi_aresetn: active-LOW reset for the course state/output logic.
 input m_axi_aresetn,
 // Signal definition - o_rdata: AXI read payload.
 output [31:0] o_rdata,
 // Signal definition - o_resp: response/status value associated with the completed channel.
 output [1:0] o_resp
);

// Signal definition - m_axi_arvalid: AXI read-address VALID.
// Signal definition - m_axi_arready: AXI read-address READY.
// Signal definition - m_axi_rvalid: AXI read-data VALID.
// Signal definition - m_axi_rready: AXI read-data READY.
wire m_axi_arvalid, m_axi_arready, m_axi_rvalid, m_axi_rready;
// Signal definition - m_axi_araddr: AXI read address offered with ARVALID.
wire [31:0] m_axi_araddr;
// Signal definition - m_axi_rdata: AXI read payload.
wire [31:0] m_axi_rdata;
// Signal definition - m_axi_rresp: AXI read-response status.
wire [1:0] m_axi_rresp;

p_m_axi mdut (
 .m_axi_aclk(m_axi_aclk),
 .m_axi_aresetn(m_axi_aresetn),
 .i_wr(i_wr),
 .i_addrin(i_addrin),
 .m_axi_arvalid(m_axi_arvalid),
 .m_axi_arready(m_axi_arready),
 .m_axi_araddr(m_axi_araddr),
 .m_axi_rvalid(m_axi_rvalid),
 .m_axi_rready(m_axi_rready),
 .m_axi_rdata(m_axi_rdata),
 .m_axi_rresp(m_axi_rresp),
 .o_rdata(o_rdata),
 .o_resp(o_resp)
);

p_s_axi sdut (
 .s_axi_aclk(m_axi_aclk),
 .s_axi_aresetn(m_axi_aresetn),
 .s_axi_arvalid(m_axi_arvalid),
 .s_axi_arready(m_axi_arready),
 .s_axi_araddr(m_axi_araddr),
 .s_axi_rvalid(m_axi_rvalid),
 .s_axi_rready(m_axi_rready),
 .s_axi_rdata(m_axi_rdata),
 .s_axi_rresp(m_axi_rresp)
);

endmodule
