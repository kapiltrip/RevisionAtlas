/*
 * REVISION ATLAS - INSTRUCTOR COURSE CODE (COMMENTS ADDED ONLY)
 * Section 05: AXI-Lite Single Beat without Pipeline
 * Lecture path: Lessons 60-67 - AXI-Lite Write-Only Master/Slave
 * Downloadable source page: Lesson 066
 * Module: m_axi
 * Role: Instructor design RTL
 *
 * PRESERVATION:
 * - Module/signal names, executable statements, FSM architecture, and stimulus
 *   are retained. Only comments and one-module-per-file organization were added.
 *
 * ASSUMPTIONS:
 * - One single-beat write is active at a time.
 * - Only AW, W, and B channels are implemented.
 * - Clock and reset are shared; resetn is active LOW.
 *
 * USED / OMITTED / SIMPLIFIED:
 * - AR/R read channels, pipelining, and multiple outstanding operations are absent.
 * - Protection/user signals not present in the instructor ports remain omitted.
 * - BRESP is present but ignored; BVALID alone marks write completion.
 *
 * BEHAVIORAL CONSEQUENCE:
 * - This unit demonstrates write sequencing only.
 * - A subordinate error response is not reported to the local interface.
 * - The instructor FSM is documented, not replaced.
 */
`timescale 1ns / 1ps


module m_axi (
 // Signal definition - i_clk: rising-edge clock for the retained FSM and handshakes.
 input wire i_clk,
 i_resetn,

 // Signal definition - i_wr: local operation control; asserted starts writes in write lessons, while deasserted selects reads in the read-only lesson.
 input wire i_wr,
 // Signal definition - i_din: local write payload loaded into the AXI write-data channel when a write is requested.
 input wire [31:0] i_din,
 // Signal definition - i_strb: byte-lane strobe associated with the write payload.
 input wire [3:0] i_strb,
 // Signal definition - i_addrin: local command address loaded into the manager's AXI address channel.
 input wire [31:0] i_addrin,

 ///////////////Write Address Channel
 // Signal definition - m_axi_awvalid: AXI write-address VALID.
 output reg m_axi_awvalid,
 // Signal definition - m_axi_awready: AXI write-address READY.
 input wire m_axi_awready,
 // Signal definition - m_axi_awaddr: AXI write address offered with AWVALID.
 output reg [31:0] m_axi_awaddr,
 //////////////Write Data Channel
 // Signal definition - m_axi_wvalid: AXI write-data VALID.
 output reg m_axi_wvalid,
 // Signal definition - m_axi_wready: AXI write-data READY.
 input wire m_axi_wready,
 // Signal definition - m_axi_wdata: AXI write payload.
 output reg [31:0] m_axi_wdata,
 // Signal definition - m_axi_wstrb: AXI write byte-lane strobes.
 output reg [ 3:0] m_axi_wstrb,
 ////////////Write Response Channel
 // Signal definition - m_axi_bvalid: AXI write-response VALID.
 input wire m_axi_bvalid,
 // Signal definition - m_axi_bready: AXI write-response READY.
 output reg m_axi_bready,
 // Signal definition - m_axi_bresp: AXI write-response status input; the course master ignores it and treats BVALID as completion.
 input wire [ 1:0] m_axi_bresp

);

 ///Write Opeartion


 initial m_axi_awvalid = 0;
 initial m_axi_wvalid = 0;
 initial m_axi_bready = 0;

 always @(posedge i_clk) begin
 if (i_resetn == 1'b0) begin
 m_axi_awvalid <= 0;
 m_axi_wvalid <= 0;
 m_axi_bready <= 0;
 end else if (m_axi_bready) begin
 if (m_axi_awready) m_axi_awvalid <= 0;

 if (m_axi_wready) m_axi_wvalid <= 0;

 if (m_axi_bvalid) m_axi_bready <= 0;

 end else if (i_wr) begin
 m_axi_awvalid <= 1;
 m_axi_wvalid <= 1;
 m_axi_bready <= 1;

 end

 end
 ////// Write Data

 initial m_axi_awaddr = 0;

 always @(posedge i_clk) begin
 if (i_resetn == 1'b0) m_axi_awaddr <= 0;
 else if (i_wr) m_axi_awaddr <= i_addrin;
 else if (m_axi_awvalid && m_axi_awready) m_axi_awaddr <= 0;
 end


 initial m_axi_wdata = 0;
 initial m_axi_wstrb = 0;

 always @(posedge i_clk) begin
 if (i_resetn == 1'b0) begin
 m_axi_wdata <= 0;
 m_axi_wstrb <= 0;
 end else if (i_wr) begin
 m_axi_wdata <= i_din;
 m_axi_wstrb <= i_strb;
 end else if (m_axi_wvalid && m_axi_wready) begin
 m_axi_wdata <= 0;
 m_axi_wstrb <= 0;
 end
 end


endmodule
