/*
 * REVISION ATLAS - INSTRUCTOR COURSE CODE (COMMENTS ADDED ONLY)
 * Section 09: AXI4 Burst Modes
 * Lecture path: Lessons 115-128 - AXI4 FIXED, INCR, and WRAP Bursts
 * Downloadable source page: Lesson 127
 * Module: connect_m_s
 * Role: Instructor integration/top-level RTL
 *
 * PRESERVATION:
 * - Module/signal names, executable statements, FSM architecture, and stimulus
 *   are retained. Only comments and one-module-per-file organization were added.
 *
 * ASSUMPTIONS:
 * - The course FSMs implement the demonstrated FIXED, INCR, and WRAP modes.
 * - Length, size, and alignment follow the course stimulus.
 * - One manager/subordinate pair shares one clock and active-LOW reset.
 *
 * USED / OMITTED / SIMPLIFIED:
 * - No alternate burst engine, CDC, multi-outstanding scheduler, or absent LOCK/CACHE/PROT/QOS/REGION/USER fields are added.
 * - `axi_protocol_checker_0` is referenced exactly as in lesson 127; its
 *   Vivado-generated implementation is not supplied by the course resource.
 *
 * BEHAVIORAL CONSEQUENCE:
 * - WRAP behavior is limited to the supported aligned cases exercised in the course.
 * - Standalone elaboration requires the external checker IP; without it the
 *   manager and subordinate still compile separately, but this top does not.
 * - System legality depends on the surrounding AXI configuration.
 */
`timescale 1ns / 1ps


module connect_m_s(
    // Signal definition - clk: rising-edge clock for the retained FSM and handshakes.
    // Signal definition - resetn: active-LOW reset for the course state/output logic.
    input clk, resetn,
    // Signal definition - wr: operation selector; HIGH chooses write and LOW chooses read.
    input wr,
    // Signal definition - wr_addr: local starting address supplied for the requested AXI write.
    input [31:0] wr_addr,
    // Signal definition - wr_burst_len: requested AXI AWLEN value, encoded as write beats minus one.
    input [7:0]  wr_burst_len,
    // Signal definition - wr_burst_type: requested AXI AWBURST mode: FIXED, INCR, or WRAP.
    input [1:0]  wr_burst_type,
    // Signal definition - wr_din: local 32-bit payload supplied to the master for the requested write transfer.
    input [31:0] wr_din,
    // Signal definition - wr_strbin: byte-lane strobe associated with the write payload.
    input [3:0]  wr_strbin,
    // Signal definition - rd_addr: local starting address supplied for the requested AXI read.
    input [31:0] rd_addr,
    // Signal definition - rd_burst_len: requested AXI ARLEN value, encoded as read beats minus one.
    input [7:0]  rd_burst_len,
    // Signal definition - rd_burst_type: requested AXI ARBURST mode: FIXED, INCR, or WRAP.
    input [1:0]  rd_burst_type,
    // Signal definition - rout: local read-data result captured from the AXI R channel and exposed to the caller/testbench.
    output [31:0] rout,
    // Signal definition - resp: local copy of the completed AXI response.
    output [1:0]  resp,
    // Signal definition - pc_status: summary status returned by the external AXI Protocol Checker.
    output [159:0] pc_status,
    // Signal definition - pc_asserted: vector of assertion bits reported by the external AXI Protocol Checker.
    output pc_asserted
    );

    // AXI signals
    // Signal definition - m_axi_awid: AXI write-address ID output; the course master holds it at zero, so it does not track multiple IDs.
    wire [2:0] m_axi_awid;
    // Signal definition - m_axi_awaddr: AXI write address offered with AWVALID.
    wire [31:0] m_axi_awaddr;
    // Signal definition - m_axi_awsize: AXI write beat-size encoding.
    wire [2:0] m_axi_awsize;
    // Signal definition - m_axi_awburst: AXI write burst type encoding.
    wire [1:0] m_axi_awburst;
    // Signal definition - m_axi_awlen: AXI write burst length encoded as beats minus one.
    wire [7:0] m_axi_awlen;
    // Signal definition - m_axi_awlock: AXI write lock/exclusive attribute; the course master holds it at zero, requesting a normal access.
    wire [1:0] m_axi_awlock;
    // Signal definition - m_axi_awcache: AXI write cache/buffer attribute; the course master holds it at zero and the slave does not use it.
    wire [3:0] m_axi_awcache;
    // Signal definition - m_axi_awprot: write protection wire carrying the manager's fixed-zero value to an ignored slave input.
    wire [2:0] m_axi_awprot;
    // Signal definition - m_axi_awqos: AXI write quality-of-service tag; the course master holds it at zero and performs no QoS arbitration.
    wire [3:0] m_axi_awqos;
    // Signal definition - m_axi_awuser: AXI write-address user sideband; the course master holds it at zero and the slave ignores it.
    wire [4:0] m_axi_awuser;
    // Signal definition - m_axi_awvalid: AXI write-address VALID.
    wire m_axi_awvalid;
    // Signal definition - m_axi_awready: AXI write-address READY.
    wire m_axi_awready;
    // Signal definition - m_axi_wid: write-data transaction ID carried by the course wiring; the master holds it at zero and the slave does not use it.
    wire [2:0] m_axi_wid;
    // Signal definition - m_axi_wdata: AXI write payload.
    wire [31:0] m_axi_wdata;
    // Signal definition - m_axi_wstrb: AXI write byte-lane strobes.
    wire [3:0] m_axi_wstrb;
    // Signal definition - m_axi_wlast: AXI final write-beat marker.
    wire m_axi_wlast;
    // Signal definition - m_axi_wvalid: AXI write-data VALID.
    wire m_axi_wvalid;
    // Signal definition - m_axi_wready: AXI write-data READY.
    wire m_axi_wready;
    // Signal definition - m_axi_bid: AXI write-response ID input; the course master ignores it and completes from BVALID alone.
    wire [2:0] m_axi_bid;
    // Signal definition - m_axi_bresp: AXI write-response status input; the course master ignores it and treats BVALID as completion.
    wire [1:0] m_axi_bresp;
    // Signal definition - m_axi_bvalid: AXI write-response VALID.
    wire m_axi_bvalid;
    // Signal definition - m_axi_bready: AXI write-response READY.
    wire m_axi_bready;
    // Signal definition - m_axi_arid: AXI read-address ID output; the course master holds it at zero, so it does not track multiple IDs.
    wire [2:0] m_axi_arid;
    // Signal definition - m_axi_araddr: AXI read address offered with ARVALID.
    wire [31:0] m_axi_araddr;
    // Signal definition - m_axi_arlen: AXI read burst length encoded as beats minus one.
    wire [7:0] m_axi_arlen;
    // Signal definition - m_axi_arsize: AXI read beat-size encoding.
    wire [2:0] m_axi_arsize;
    // Signal definition - m_axi_arburst: AXI read burst type encoding.
    wire [1:0] m_axi_arburst;
    // Signal definition - m_axi_arlock: AXI read lock/exclusive attribute; the course master holds it at zero, requesting a normal access.
    wire [1:0] m_axi_arlock;
    // Signal definition - m_axi_arcache: AXI read cache/buffer attribute; the course master holds it at zero and the slave does not use it.
    wire [3:0] m_axi_arcache;
    // Signal definition - m_axi_arprot: read protection wire carrying the manager's fixed-zero value to an ignored slave input.
    wire [2:0] m_axi_arprot;
    // Signal definition - m_axi_arqos: AXI read quality-of-service tag; the course master holds it at zero and performs no QoS arbitration.
    wire [3:0] m_axi_arqos;
    // Signal definition - m_axi_aruser: AXI read-address user sideband; the course master holds it at zero and the slave ignores it.
    wire [4:0] m_axi_aruser;
    // Signal definition - m_axi_arvalid: AXI read-address VALID.
    wire m_axi_arvalid;
    // Signal definition - m_axi_arready: AXI read-address READY.
    wire m_axi_arready;
    // Signal definition - m_axi_rid: AXI read-data ID input; the course master ignores it and accepts data from a single outstanding read.
    wire [2:0] m_axi_rid;
    // Signal definition - m_axi_rdata: AXI read payload.
    wire [31:0] m_axi_rdata;
    // Signal definition - m_axi_rresp: AXI read-response status.
    wire [1:0] m_axi_rresp;
    // Signal definition - m_axi_rlast: AXI final read-beat marker.
    wire m_axi_rlast;
    // Signal definition - m_axi_rvalid: AXI read-data VALID.
    wire m_axi_rvalid;
    // Signal definition - m_axi_rready: AXI read-data READY.
    wire m_axi_rready;





axi_master uut (
        .m_axi_aclk(clk),
        .m_axi_aresetn(resetn),
        .m_axi_awid(m_axi_awid),
        .m_axi_awaddr(m_axi_awaddr),
        .m_axi_awsize(m_axi_awsize),
        .m_axi_awburst(m_axi_awburst),
        .m_axi_awlen(m_axi_awlen),
        .m_axi_awlock(m_axi_awlock),
        .m_axi_awcache(m_axi_awcache),
        .m_axi_awprot(m_axi_awprot),
        .m_axi_awqos(m_axi_awqos),
        .m_axi_awuser(m_axi_awuser),
        .m_axi_awvalid(m_axi_awvalid),
        .m_axi_awready(m_axi_awready),
        .m_axi_wid(m_axi_wid),
        .m_axi_wdata(m_axi_wdata),
        .m_axi_wstrb(m_axi_wstrb),
        .m_axi_wlast(m_axi_wlast),
        .m_axi_wvalid(m_axi_wvalid),
        .m_axi_wready(m_axi_wready),
        .m_axi_bid(m_axi_bid),
        .m_axi_bresp(m_axi_bresp),
        .m_axi_bvalid(m_axi_bvalid),
        .m_axi_bready(m_axi_bready),
        .m_axi_arid(m_axi_arid),
        .m_axi_araddr(m_axi_araddr),
        .m_axi_arlen(m_axi_arlen),
        .m_axi_arsize(m_axi_arsize),
        .m_axi_arburst(m_axi_arburst),
        .m_axi_arlock(m_axi_arlock),
        .m_axi_arcache(m_axi_arcache),
        .m_axi_arprot(m_axi_arprot),
        .m_axi_arqos(m_axi_arqos),
        .m_axi_aruser(m_axi_aruser),
        .m_axi_arvalid(m_axi_arvalid),
        .m_axi_arready(m_axi_arready),
        .m_axi_rid(m_axi_rid),
        .m_axi_rdata(m_axi_rdata),
        .m_axi_rresp(m_axi_rresp),
        .m_axi_rlast(m_axi_rlast),
        .m_axi_rvalid(m_axi_rvalid),
        .m_axi_rready(m_axi_rready),
        .wr(wr),
        .wr_addr(wr_addr),
        .wr_burst_len(wr_burst_len),
        .wr_burst_type(wr_burst_type),
        .wr_din(wr_din),
        .wr_strbin(wr_strbin),
        .rd_addr(rd_addr),
        .rd_burst_len(rd_burst_len),
        .rd_burst_type(rd_burst_type),
        .rout(rout),
        .resp(resp)
    );


// Lesson 127 external dependency: this Vivado-generated checker module is not
// present in the downloadable source, so standalone elaboration stops here.
axi_protocol_checker_0  checker_inst (
  .pc_status(pc_status),
  .pc_asserted(pc_asserted),
  .aclk(clk),
  .aresetn(resetn),
  .pc_axi_awaddr(m_axi_awaddr),
  .pc_axi_awlen(m_axi_awlen),
  .pc_axi_awsize(2),
  .pc_axi_awburst(m_axi_awburst),
  .pc_axi_awlock(0),
  .pc_axi_awcache(0),
  .pc_axi_awprot(0),
  .pc_axi_awqos(0),
  .pc_axi_awregion(0),
  .pc_axi_awvalid(m_axi_awvalid),
  .pc_axi_awready(m_axi_awready),
  .pc_axi_wlast(m_axi_wlast),
  .pc_axi_wdata(m_axi_wdata),
  .pc_axi_wstrb(m_axi_wstrb),
  .pc_axi_wvalid(m_axi_wvalid),
  .pc_axi_wready(m_axi_wready),
  .pc_axi_bresp(m_axi_bresp),
  .pc_axi_bvalid(m_axi_bvalid),
  .pc_axi_bready(m_axi_bready),
  .pc_axi_araddr(m_axi_araddr),
  .pc_axi_arlen(m_axi_arlen),
  .pc_axi_arsize(m_axi_arsize),
  .pc_axi_arburst(m_axi_arburst),
  .pc_axi_arlock(0),
  .pc_axi_arcache(0),
  .pc_axi_arprot(0),
  .pc_axi_arqos(0),
  .pc_axi_arregion(0),
  .pc_axi_arvalid(m_axi_arvalid),
  .pc_axi_arready(m_axi_arready),
  .pc_axi_rlast(m_axi_rlast),
  .pc_axi_rdata(m_axi_rdata),
  .pc_axi_rresp(m_axi_rresp),
  .pc_axi_rvalid(m_axi_rvalid),
  .pc_axi_rready(m_axi_rready)
);


axi4_slave dut (
        .s_axi_aclk(clk),
        .s_axi_aresetn(resetn),

        .s_axi_awid(m_axi_awid),
        .s_axi_awvalid(m_axi_awvalid),
        .s_axi_awready(m_axi_awready),
        .s_axi_awaddr(m_axi_awaddr),
        .s_axi_awlen(m_axi_awlen),
        .s_axi_awsize(m_axi_awsize),
        .s_axi_awburst(m_axi_awburst),
        .s_axi_awlock(m_axi_awlock),
        .s_axi_awcache(m_axi_awcache),
        .s_axi_awprot(m_axi_awprot),
        .s_axi_awqos(m_axi_awqos),
        .s_axi_awuser(m_axi_awuser),

        .s_axi_wid(m_axi_wid),
        .s_axi_wvalid(m_axi_wvalid),
        .s_axi_wready(m_axi_wready),
        .s_axi_wdata(m_axi_wdata),
        .s_axi_wstrb(m_axi_wstrb),
        .s_axi_wlast(m_axi_wlast),

        .s_axi_bid(m_axi_bid),
        .s_axi_bvalid(m_axi_bvalid),
        .s_axi_bready(m_axi_bready),
        .s_axi_bresp(m_axi_bresp),

        .s_axi_arid(m_axi_arid),
        .s_axi_arvalid(m_axi_arvalid),
        .s_axi_arready(m_axi_arready),
        .s_axi_araddr(m_axi_araddr),
        .s_axi_arlen(m_axi_arlen),
        .s_axi_arsize(m_axi_arsize),
        .s_axi_arburst(m_axi_arburst),
        .s_axi_arlock(m_axi_arlock),
        .s_axi_arcache(m_axi_arcache),
        .s_axi_arprot(m_axi_arprot),
        .s_axi_arqos(m_axi_arqos),
        .s_axi_aruser(m_axi_aruser),

        .s_axi_rid(m_axi_rid),
        .s_axi_rvalid(m_axi_rvalid),
        .s_axi_rready(m_axi_rready),
        .s_axi_rdata(m_axi_rdata),
        .s_axi_rlast(m_axi_rlast),
        .s_axi_rresp(m_axi_rresp)
    );


endmodule
