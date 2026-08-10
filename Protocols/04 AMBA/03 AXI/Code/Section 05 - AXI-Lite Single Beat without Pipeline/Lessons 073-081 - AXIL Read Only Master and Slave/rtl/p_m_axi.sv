/*
 * REVISION ATLAS - INSTRUCTOR COURSE CODE (COMMENTS ADDED ONLY)
 * Section 05: AXI-Lite Single Beat without Pipeline
 * Lecture path: Lessons 73-81 - AXI-Lite Read-Only Master/Slave
 * Downloadable source page: Lesson 081
 * Module: p_m_axi
 * Role: Instructor design RTL
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
`timescale 1ns / 1ps

module p_m_axi (
 // Signal definition - m_axi_aclk: rising-edge clock for the retained FSM and handshakes.
 // Signal definition - m_axi_aresetn: active-LOW reset for the course state/output logic.
 input wire m_axi_aclk, m_axi_aresetn,
 // Signal definition - i_wr: local operation control; asserted starts writes in write lessons, while deasserted selects reads in the read-only lesson.
 input wire i_wr,
 // Signal definition - i_addrin: local command address loaded into the manager's AXI address channel.
 input wire [31:0] i_addrin,
 // Read Address Channel
 // Signal definition - m_axi_arvalid: AXI read-address VALID.
 output reg m_axi_arvalid,
 // Signal definition - m_axi_arready: AXI read-address READY.
 input wire m_axi_arready,
 // Signal definition - m_axi_araddr: AXI read address offered with ARVALID.
 output reg [31:0] m_axi_araddr,
 // Read Data Channel
 // Signal definition - m_axi_rvalid: AXI read-data VALID.
 input wire m_axi_rvalid,
 // Signal definition - m_axi_rready: AXI read-data READY.
 output reg m_axi_rready,
 // Signal definition - m_axi_rdata: AXI read payload.
 input wire [31:0] m_axi_rdata,
 // Signal definition - m_axi_rresp: AXI read-response status.
 input wire [1:0] m_axi_rresp,
 // Read Out
 // Signal definition - o_rdata: AXI read payload.
 output reg [31:0] o_rdata,
 // Signal definition - o_resp: response/status value associated with the completed channel.
 output reg [1:0] o_resp
);

// Read Operation
// Signal definition - wait_for_rdata: read-outstanding flag set after ARVALID and cleared when the R handshake completes.
reg wait_for_rdata = 0;

initial m_axi_arvalid = 0;
initial m_axi_araddr = 0;
initial m_axi_rready = 0;

always @(posedge m_axi_aclk) begin
 if (m_axi_aresetn == 1'b0) begin
 m_axi_arvalid <= 0;
 end else if (wait_for_rdata) begin
 if (m_axi_arready)
 m_axi_arvalid <= 1'b0;
 end else if (i_wr == 1'b0) begin
 m_axi_arvalid <= 1'b1;
 end
end

always @(posedge m_axi_aclk) begin
 if (m_axi_aresetn == 1'b0) begin
 m_axi_araddr <= 0;
 end else if (wait_for_rdata) begin
 if (m_axi_arready)
 m_axi_araddr <= 0;
 end else if (i_wr == 1'b0) begin
 m_axi_araddr <= i_addrin;
 end
end

always @(posedge m_axi_aclk) begin
 if (m_axi_aresetn == 1'b0) begin
 m_axi_rready <= 0;
 end else if (m_axi_rready) begin
 m_axi_rready <= 0;
 end else if (m_axi_rvalid) begin
 m_axi_rready <= 1;
 end
end

always @(posedge m_axi_aclk) begin
 if (m_axi_aresetn == 1'b0) begin
 o_rdata <= 0;
 o_resp <= 0;
 wait_for_rdata <= 0;
 end else if (m_axi_rvalid && m_axi_rready) begin
 o_rdata <= m_axi_rdata;
 o_resp <= m_axi_rresp;
 wait_for_rdata <= 0;
 end else if (m_axi_arvalid) begin
 o_rdata <= 0;
 o_resp <= 0;
 wait_for_rdata <= 1;
 end
end

endmodule
