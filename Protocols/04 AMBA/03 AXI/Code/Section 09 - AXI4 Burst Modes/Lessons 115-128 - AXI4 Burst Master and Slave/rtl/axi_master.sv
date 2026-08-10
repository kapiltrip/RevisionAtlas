/*
 * REVISION ATLAS - INSTRUCTOR COURSE CODE (COMMENTS ADDED ONLY)
 * Section 09: AXI4 Burst Modes
 * Lecture path: Lessons 115-128 - AXI4 FIXED, INCR, and WRAP Bursts
 * Downloadable source page: Lesson 122
 * Module: axi_master
 * Role: Instructor design RTL
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
 * - AWID, WID, ARID, LOCK, CACHE, PROT, QOS, and USER outputs are held at zero.
 * - BID, RID, and BRESP inputs are ignored by the supplied manager.
 *
 * BEHAVIORAL CONSEQUENCE:
 * - WRAP behavior is limited to the supported aligned cases exercised in the course.
 * - It assumes one outstanding transaction and cannot validate response IDs or
 *   report a write-response error.
 * - System legality depends on the surrounding AXI configuration.
 */
module axi_master
(
 // Signal definition - m_axi_aclk: rising-edge clock for the retained FSM and handshakes.
 input wire m_axi_aclk,
 // Signal definition - m_axi_aresetn: active-LOW reset for the course state/output logic.
 input wire m_axi_aresetn,
 /////////write data channel
 // Signal definition - m_axi_awid: AXI write-address ID output; the course master holds it at zero, so it does not track multiple IDs.
 output reg [2:0] m_axi_awid ,
 // Signal definition - m_axi_awaddr: AXI write address offered with AWVALID.
 output reg [31:0] m_axi_awaddr,
 // Signal definition - m_axi_awsize: AXI write beat-size encoding.
 output reg [2:0] m_axi_awsize,
 // Signal definition - m_axi_awburst: AXI write burst type encoding.
 output reg [1:0] m_axi_awburst,
 // Signal definition - m_axi_awlen: AXI write burst length encoded as beats minus one.
 output reg [7:0] m_axi_awlen,
 // Signal definition - m_axi_awlock: AXI write lock/exclusive attribute; the course master holds it at zero, requesting a normal access.
 output reg [1:0] m_axi_awlock ,
 // Signal definition - m_axi_awcache: AXI write cache/buffer attribute; the course master holds it at zero and the slave does not use it.
 output reg [3:0] m_axi_awcache,
 // Signal definition - m_axi_awprot: write protection attributes held at zero by the course manager.
 output reg [2:0] m_axi_awprot,
 // Signal definition - m_axi_awqos: AXI write quality-of-service tag; the course master holds it at zero and performs no QoS arbitration.
 output reg [3:0] m_axi_awqos,
 // Signal definition - m_axi_awuser: AXI write-address user sideband; the course master holds it at zero and the slave ignores it.
 output reg [4:0] m_axi_awuser,
 // Signal definition - m_axi_awvalid: AXI write-address VALID.
 output reg m_axi_awvalid,
 // Signal definition - m_axi_awready: AXI write-address READY.
 input wire m_axi_awready,
 // Write data channel signals
 // Signal definition - m_axi_wid: write-data transaction ID carried by the course wiring; the master holds it at zero and the slave does not use it.
 output reg [2:0] m_axi_wid ,
 // Signal definition - m_axi_wdata: AXI write payload.
 output reg [31:0] m_axi_wdata,
 // Signal definition - m_axi_wstrb: AXI write byte-lane strobes.
 output reg [3:0] m_axi_wstrb,
 // Signal definition - m_axi_wlast: AXI final write-beat marker.
 output reg m_axi_wlast,
 // Signal definition - m_axi_wvalid: AXI write-data VALID.
 output reg m_axi_wvalid,
 // Signal definition - m_axi_wready: AXI write-data READY.
 input wire m_axi_wready,
 // Write response channel signals
 // Signal definition - m_axi_bid: AXI write-response ID input; the course master ignores it and completes from BVALID alone.
 input wire m_axi_bid,
 // Signal definition - m_axi_bresp: AXI write-response status input; the course master ignores it and treats BVALID as completion.
 input wire m_axi_bresp,
 // Signal definition - m_axi_bvalid: AXI write-response VALID.
 input wire m_axi_bvalid,
 // Signal definition - m_axi_bready: AXI write-response READY.
 output reg m_axi_bready,
 // Read address channel signals
 // Signal definition - m_axi_arid: AXI read-address ID output; the course master holds it at zero, so it does not track multiple IDs.
 output reg [2:0] m_axi_arid,
 // Signal definition - m_axi_araddr: AXI read address offered with ARVALID.
 output reg [31:0] m_axi_araddr,
 // Signal definition - m_axi_arlen: AXI read burst length encoded as beats minus one.
 output reg [7:0] m_axi_arlen,
 // Signal definition - m_axi_arsize: AXI read beat-size encoding.
 output reg [2:0] m_axi_arsize,
 // Signal definition - m_axi_arburst: AXI read burst type encoding.
 output reg [1:0] m_axi_arburst,
 // Signal definition - m_axi_arlock: AXI read lock/exclusive attribute; the course master holds it at zero, requesting a normal access.
 output reg [1:0] m_axi_arlock,
 // Signal definition - m_axi_arcache: AXI read cache/buffer attribute; the course master holds it at zero and the slave does not use it.
 output reg [3:0] m_axi_arcache,
 // Signal definition - m_axi_arprot: read protection attributes held at zero by the course manager.
 output reg [2:0] m_axi_arprot,
 // Signal definition - m_axi_arqos: AXI read quality-of-service tag; the course master holds it at zero and performs no QoS arbitration.
 output reg [3:0] m_axi_arqos,
 // Signal definition - m_axi_aruser: AXI read-address user sideband; the course master holds it at zero and the slave ignores it.
 output reg [4:0] m_axi_aruser,
 // Signal definition - m_axi_arvalid: AXI read-address VALID.
 output reg m_axi_arvalid,
 // Signal definition - m_axi_arready: AXI read-address READY.
 input wire m_axi_arready,
 // Read data channel signals
 // Signal definition - m_axi_rid: AXI read-data ID input; the course master ignores it and accepts data from a single outstanding read.
 input wire [2:0] m_axi_rid ,
 // Signal definition - m_axi_rdata: AXI read payload.
 input wire [31:0] m_axi_rdata,
 // Signal definition - m_axi_rresp: AXI read-response status.
 input wire [1:0] m_axi_rresp ,
 // Signal definition - m_axi_rlast: AXI final read-beat marker.
 input wire m_axi_rlast,
 // Signal definition - m_axi_rvalid: AXI read-data VALID.
 input wire m_axi_rvalid,
 // Signal definition - m_axi_rready: AXI read-data READY.
 output reg m_axi_rready,
 // Signal definition - wr: operation selector; HIGH chooses write and LOW chooses read.
 input wire wr,
 // Signal definition - wr_addr: local starting address supplied for the requested AXI write.
 input wire [23:0] wr_addr,
 // Signal definition - wr_burst_len: requested AXI AWLEN value, encoded as write beats minus one.
 input wire [7:0] wr_burst_len,
 // Signal definition - wr_burst_type: requested AXI AWBURST mode: FIXED, INCR, or WRAP.
 input wire [1:0] wr_burst_type,
 // Signal definition - wr_din: local 32-bit payload supplied to the master for the requested write transfer.
 input wire [31:0] wr_din,
 // Signal definition - wr_strbin: byte-lane strobe associated with the write payload.
 input wire [3:0] wr_strbin,
 // Signal definition - rd_addr: local starting address supplied for the requested AXI read.
 input wire [23:0] rd_addr,
 // Signal definition - rd_burst_len: requested AXI ARLEN value, encoded as read beats minus one.
 input wire [7:0] rd_burst_len,
 // Signal definition - rd_burst_type: requested AXI ARBURST mode: FIXED, INCR, or WRAP.
 input wire [1:0] rd_burst_type,
 // Signal definition - rout: local read-data result captured from the AXI R channel and exposed to the caller/testbench.
 output reg [31:0] rout,
 // Signal definition - resp: local copy of the completed AXI response.
 output reg [1:0] resp
	);

// Signal definition - idle: numeric encoding of the FSM's inactive state, where no new AXI transfer is being advanced.
localparam idle = 0,
 detect_op = 1,
 send_waddr = 2,
 send_wdata = 3,
 wdata_last = 4,
 wait_for_wr_resp = 5,
 comp_wr_tx = 6,
 no_ack_waddr = 7,
 no_ack_wdata = 8,
 send_raddr = 9,
 read_rdata = 10,
 no_ack_raddr = 11,
 no_ack_rdata = 12,
 comp_rd_tx = 13;



// Signal definition - burst_count: remaining write-beat counter loaded from AWLEN and decremented as W beats are accepted.
// Signal definition - wr_count: write-channel no-acknowledgement timer; the course FSM times out at its terminal count.
// Signal definition - rd_count: read-channel no-acknowledgement timer; the course FSM times out at its terminal count.
integer burst_count = 0, wr_count = 0, rd_count = 0;
// Signal definition - state: current/next state used by the instructor FSM.
// Signal definition - next_state: current/next state used by the instructor FSM.
reg [3:0] state = idle, next_state = idle;
// Signal definition - din: local write/payload data supplied to the manager.
reg [31:0] din = 0;



 initial
 begin
 m_axi_awvalid = 0;
 m_axi_awid = 0;
 m_axi_awaddr = 0;
 m_axi_awprot = 0;
 m_axi_wvalid = 0;
 m_axi_awlen = 0;
 m_axi_awsize = 0;
 m_axi_awburst = 0;
 m_axi_awlock = 0;
 m_axi_awcache = 0;
 m_axi_awqos = 0;
 m_axi_awuser = 0;
 m_axi_wid = 0;
 m_axi_wstrb = 0;
 m_axi_wlast = 0;
 m_axi_bready = 0;
 m_axi_arvalid = 0;
 m_axi_arid = 0;
 m_axi_araddr = 0;
 m_axi_arlen = 0;
 m_axi_arsize = 0;
 m_axi_arburst = 0;
 m_axi_arqos = 0;
 m_axi_arprot = 0;
 m_axi_arlock = 0;
 m_axi_arcache = 0;
 m_axi_aruser = 0;
 m_axi_rready = 0;
 burst_count = 0;
 din = 0;
 m_axi_wdata = 0;
 state = idle;
 rout = 0;
 resp = 0;
 end










always @(posedge m_axi_aclk) begin
 if (!m_axi_aresetn) begin
 state <= idle;
 end else begin
 case (state)
 idle: begin
 m_axi_awvalid <= 0;
 m_axi_awid <= 0;
 m_axi_awaddr <= 0;
 m_axi_awprot <= 0;
 m_axi_wvalid <= 0;
 m_axi_awlen <= 0;
 m_axi_awsize <= 0;
 m_axi_awburst <= 0;
 m_axi_awlock <= 0;
 m_axi_awcache <= 0;
 m_axi_awqos <= 0;
 m_axi_awuser <= 0;
 m_axi_wid <= 0;
 m_axi_wstrb <= 0;
 m_axi_wlast <= 0;
 m_axi_wdata <= 0;
 m_axi_bready <= 0;
 m_axi_arvalid <= 0;
 m_axi_arid <= 0;
 m_axi_araddr <= 0;
 m_axi_arlen <= 0;
 m_axi_arsize <= 0;
 m_axi_arburst <= 0;
 m_axi_arqos <= 0;
 m_axi_arprot <= 0;
 m_axi_arlock <= 0;
 m_axi_arcache <= 0;
 m_axi_aruser <= 0;
 m_axi_rready <= 0;
 burst_count <= 0;
 din <= 0;
 state <= detect_op;
 end

 detect_op: begin
 if (wr)
 state <= send_waddr;
 else
 state <= send_raddr;
 end

 send_waddr: begin
 din <= wr_din * 5;
 m_axi_awaddr <= wr_addr;
 m_axi_awvalid <= 1;
 m_axi_wvalid <= 1;
 m_axi_awlen <= wr_burst_len;
 m_axi_awsize <= 3'b010;
 m_axi_awburst <= wr_burst_type;
 m_axi_wdata <= wr_din;
 m_axi_wstrb <= wr_strbin << 1;
 m_axi_wlast <= 0;
 burst_count <= wr_burst_len;
 m_axi_bready <= 1;

 if (m_axi_awready == 1) begin
 state <= send_wdata;
 wr_count <= 0;
 m_axi_awvalid <= 0;
 m_axi_awaddr <= 0;
 m_axi_awlen <= 0;
 m_axi_awsize <= 0;
 m_axi_awburst <= 0;
 end else if (wr_count == 15) begin
 state <= no_ack_waddr;
 wr_count <= 0;
 end else begin
 state <= send_waddr;
 wr_count <= wr_count + 1;
 end
 end

 send_wdata: begin
 if (m_axi_wready && burst_count != 1) begin
 burst_count <= burst_count - 1;
 din <= din * 5;
 m_axi_wdata <= din;
 state <= send_wdata;
 wr_count <= 0;
 end else if (m_axi_wready && burst_count == 1) begin
 burst_count <= burst_count - 1;
 m_axi_wdata <= din;
 state <= wdata_last;
 m_axi_wlast <= 1;
 wr_count <= 0;
 end else if (wr_count == 15) begin
 state <= no_ack_wdata;
 end else begin
 state <= send_wdata;
 wr_count <= wr_count + 1;
 end
 end

 wdata_last: begin
 if (m_axi_wready && burst_count == 0) begin
 state <= wait_for_wr_resp;
 m_axi_wvalid <= 0;
 burst_count <= 0;
 m_axi_wlast <= 0;
 m_axi_wdata <= 0;
 end
 end

 no_ack_wdata, no_ack_waddr: begin
 state <= wait_for_wr_resp;
 end

 wait_for_wr_resp: begin
 if (m_axi_bvalid == 1) begin
 state <= comp_wr_tx;
 m_axi_bready <= 0;
 end else if (wr_count == 15) begin
 state <= idle;
 wr_count <= 0;
 end else begin
 state <= wait_for_wr_resp;
 wr_count <= wr_count + 1;
 end
 end

 comp_wr_tx: begin
 m_axi_awaddr <= 0;
 m_axi_awvalid <= 0;
 m_axi_wvalid <= 0;
 m_axi_wlast <= 0;
 m_axi_wdata <= 0;
 burst_count <= 0;
 m_axi_bready <= 0;
 state <= idle;
 end

 send_raddr: begin
 m_axi_araddr <= rd_addr;
 m_axi_arlen <= rd_burst_len;
 m_axi_arsize <= 3'b010;
 m_axi_arburst <= rd_burst_type;
 m_axi_arvalid <= 1;
 m_axi_rready <= 0;

 if (m_axi_arready == 1) begin
 state <= read_rdata;
 m_axi_arvalid <= 0;
 rd_count <= 0;
 end else if (rd_count == 15) begin
 state <= no_ack_raddr;
 rd_count <= 0;
 end else begin
 state <= send_raddr;
 rd_count <= rd_count + 1;
 end
 end

 read_rdata: begin
 m_axi_araddr <= 0;
 m_axi_arlen <= 0;
 m_axi_arsize <= 0;
 m_axi_arburst <= 0;
 m_axi_arvalid <= 0;
 m_axi_rready <= 1;

 if ((m_axi_rvalid == 1'b1) && (m_axi_rlast != 1)) begin
 rout <= m_axi_rdata;
 resp <= m_axi_rresp;
 state <= read_rdata;
 rd_count <= 0;
 end else if ((m_axi_rvalid == 1'b1) && (m_axi_rlast == 1)) begin
 rout <= m_axi_rdata;
 resp <= m_axi_rresp;
 state <= comp_rd_tx;
 rd_count <= 0;
 end else if (rd_count == 15) begin
 state <= no_ack_rdata;
 rd_count <= 0;
 end else begin
 rd_count <= rd_count + 1;
 state <= read_rdata;
 end
 end

 no_ack_raddr, no_ack_rdata: begin
 m_axi_rready <= 0;
 state <= idle;
 rout <= 0;
 resp <= 0;
 end

 comp_rd_tx: begin
 m_axi_rready <= 0;
 state <= idle;
 rout <= 0;
 resp <= 0;
 end

 default: state <= idle;
 endcase
 end
end





endmodule
