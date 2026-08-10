/*
 * REVISION ATLAS - INSTRUCTOR COURSE CODE (COMMENTS ADDED ONLY)
 * Section 08: AXI4 Single Beat
 * Lecture path: Lessons 103-112 - AXI4 Single-Beat Master/Slave
 * Downloadable source page: Lesson 110
 * Module: axi4_slave
 * Role: Instructor design RTL
 *
 * PRESERVATION:
 * - Module/signal names, executable statements, FSM architecture, and stimulus
 *   are retained. Only comments and one-module-per-file organization were added.
 *
 * ASSUMPTIONS:
 * - One transaction is active at a time.
 * - Course fields describe a single transfer.
 * - Manager and subordinate share one clock and active-LOW reset.
 *
 * USED / OMITTED / SIMPLIFIED:
 * - No alternative pipeline, multi-outstanding engine, CDC, or absent USER fields are added.
 * - AWID, WID, ARID, LOCK, CACHE, PROT, QOS, USER, AWSIZE, AWBURST,
 *   ARSIZE, ARBURST, and WLAST inputs are declared but ignored.
 * - BID and RID are always returned as zero.
 *
 * BEHAVIORAL CONSEQUENCE:
 * - This is the instructor's AXI4 teaching subset.
 * - Transfer size/type and WLAST do not control this subordinate; response IDs
 *   cannot identify independent transactions.
 * - Only fields wired by connect_m_s propagate end to end.
 */
`timescale 1ns / 1ps
module axi4_slave
(
 // Signal definition - s_axi_aclk: rising-edge clock for the retained FSM and handshakes.
 input wire s_axi_aclk,
 // Signal definition - s_axi_aresetn: active-LOW reset for the course state/output logic.
 input wire s_axi_aresetn,

 // Signal definition - s_axi_awid: AXI write-address ID input; the course slave ignores it and returns a fixed response ID.
 input wire [2:0] s_axi_awid,
 // Signal definition - s_axi_awvalid: AXI write-address VALID.
 input wire s_axi_awvalid,
 // Signal definition - s_axi_awready: AXI write-address READY.
 output reg s_axi_awready,
 // Signal definition - s_axi_awaddr: AXI write address offered with AWVALID.
 input wire [31:0] s_axi_awaddr,
 // Signal definition - s_axi_awlen: AXI write burst length encoded as beats minus one.
 input wire [7:0] s_axi_awlen,
 // Signal definition - s_axi_awsize: write beat-size input declared but ignored by this lesson 110 subordinate.
 input wire [2:0] s_axi_awsize,
 // Signal definition - s_axi_awburst: write burst-type input declared but ignored by this lesson 110 subordinate.
 input wire [1:0] s_axi_awburst,
 // Signal definition - s_axi_awlock: AXI write lock/exclusive attribute input; it is connected but ignored by the course slave.
 input wire [1:0] s_axi_awlock,
 // Signal definition - s_axi_awcache: AXI write cache/buffer attribute input; it is connected but ignored by the course slave.
 input wire [3:0] s_axi_awcache,
 // Signal definition - s_axi_awprot: write protection attributes are connected but ignored by the course subordinate.
 input wire [2:0] s_axi_awprot,
 // Signal definition - s_axi_awqos: AXI write quality-of-service input; it is connected but ignored by the course slave.
 input wire [3:0] s_axi_awqos,
 // Signal definition - s_axi_awuser: AXI write-address user sideband input; it is connected but ignored by the course slave.
 input wire [4:0] s_axi_awuser,

 // Signal definition - s_axi_wid: write-data transaction ID input; the course slave ignores it.
 input wire [2:0] s_axi_wid,
 // Signal definition - s_axi_wvalid: AXI write-data VALID.
 input wire s_axi_wvalid,
 // Signal definition - s_axi_wready: AXI write-data READY.
 output reg s_axi_wready,
 // Signal definition - s_axi_wdata: AXI write payload.
 input wire [31:0] s_axi_wdata,
 // Signal definition - s_axi_wstrb: AXI write byte-lane strobes.
 input wire [3:0] s_axi_wstrb,
 // Signal definition - s_axi_wlast: final write-beat marker input; the course slave ignores it and instead follows its captured length/count.
 input wire s_axi_wlast,

 // Signal definition - s_axi_bid: write-response ID forced to zero rather than copied from AWID.
 output reg [2:0] s_axi_bid,
 // Signal definition - s_axi_bvalid: AXI write-response VALID.
 output reg s_axi_bvalid,
 // Signal definition - s_axi_bready: AXI write-response READY.
 input wire s_axi_bready,
 // Signal definition - s_axi_bresp: AXI write-response status.
 output reg [1:0] s_axi_bresp,

 // Signal definition - s_axi_arid: AXI read-address ID input; the course slave ignores it and returns a fixed response ID.
 input wire [2:0] s_axi_arid,
 // Signal definition - s_axi_arvalid: AXI read-address VALID.
 input wire s_axi_arvalid,
 // Signal definition - s_axi_arready: AXI read-address READY.
 output reg s_axi_arready,
 // Signal definition - s_axi_araddr: AXI read address offered with ARVALID.
 input wire [31:0] s_axi_araddr,
 // Signal definition - s_axi_arlen: AXI read burst length encoded as beats minus one.
 input wire [7:0] s_axi_arlen,
 // Signal definition - s_axi_arsize: read beat-size input declared but ignored by this lesson 110 subordinate.
 input wire [2:0] s_axi_arsize,
 // Signal definition - s_axi_arburst: read burst-type input declared but ignored by this lesson 110 subordinate.
 input wire [1:0] s_axi_arburst,
 // Signal definition - s_axi_arlock: AXI read lock/exclusive attribute input; it is connected but ignored by the course slave.
 input wire [1:0] s_axi_arlock,
 // Signal definition - s_axi_arcache: AXI read cache/buffer attribute input; it is connected but ignored by the course slave.
 input wire [3:0] s_axi_arcache,
 // Signal definition - s_axi_arprot: read protection attributes are connected but ignored by the course subordinate.
 input wire [2:0] s_axi_arprot,
 // Signal definition - s_axi_arqos: AXI read quality-of-service input; it is connected but ignored by the course slave.
 input wire [3:0] s_axi_arqos,
 // Signal definition - s_axi_aruser: AXI read-address user sideband input; it is connected but ignored by the course slave.
 input wire [4:0] s_axi_aruser,

 // Signal definition - s_axi_rid: read-data ID forced to zero rather than copied from ARID.
 output reg [2:0] s_axi_rid,
 // Signal definition - s_axi_rvalid: AXI read-data VALID.
 output reg s_axi_rvalid,
 // Signal definition - s_axi_rready: AXI read-data READY.
 input wire s_axi_rready,
 // Signal definition - s_axi_rdata: AXI read payload.
 output reg [31:0] s_axi_rdata,
 // Signal definition - s_axi_rlast: AXI final read-beat marker.
 output reg s_axi_rlast,
 // Signal definition - s_axi_rresp: AXI read-response status.
 output reg [1:0] s_axi_rresp
	);

// Signal definition - idle: numeric encoding of the FSM's inactive state, where no new AXI transfer is being advanced.
localparam idle = 0,
 predict_op = 1,
 accept_wr = 2,
 wait_wdata = 3,
 accept_wdata = 4,
 gen_data = 5,
 update_mem = 6,
 check_br_len = 7,
 send_ack = 8,
 accept_rd = 9,
 fetch_rdata = 10,
 send_rdata =11,
 rcheck_br_len = 12,
 fetch_ldata = 13,
 send_rlast = 14,
 write_err = 15;




 initial begin
 s_axi_awready = 0;
 s_axi_wready = 0;
 s_axi_bid =0;
 s_axi_bvalid = 0;
 s_axi_bresp = 0;
 s_axi_arready = 0;
 s_axi_rid = 0;
 s_axi_rvalid = 0;
 s_axi_rdata = 0;
 s_axi_rlast = 0;
 s_axi_rresp = 0;
 end


// Signal definition - mem: sixteen-entry, 32-bit teaching memory updated by accepted AXI-Lite writes.
reg [31:0] mem [15:0];

// Signal definition - state: current/next state used by the instructor FSM.
reg [4:0] state = 0;
// Signal definition - i: loop index used by initialization or TB stimulus.
integer i = 0;
// Signal definition - burst_len: latched AWLEN value used by the slave's write-burst control.
// Signal definition - rburst_len: latched ARLEN value used by the slave's read-burst control.
reg [7:0] burst_len = 0,rburst_len = 0;
// Signal definition - waddr: accepted write address retained for GPIO decode or memory access.
// Signal definition - wdata: accepted AXI write payload retained until the course FSM applies it.
// Signal definition - raddr: accepted read address retained for GPIO decode or memory access.
// Signal definition - rdata: AXI read payload.
reg [31:0] waddr = 0, wdata = 0,raddr = 0, rdata = 0;
// Signal definition - wstrb: accepted AXI byte-lane strobes retained with WDATA.
reg [3:0] wstrb = 0;
// Signal definition - timer: handshake timeout counter; reaching 15 sends the retained course FSM to its no-acknowledgement path.
integer timer = 0;
// Signal definition - data_write: WSTRB-masked write payload produced before the GPIO or memory update.
reg [31:0] data_write = 0;
// Signal definition - count: two-cycle lesson-FSM pacing counter used before memory-update/read-response states.
reg [1:0] count = 0;

always @(posedge s_axi_aclk) begin
 if (s_axi_aresetn == 0) begin
 for (i = 0; i < 16; i = i + 1) begin
 mem[i] <= 0;
 end
 end else begin
 case (state)
 idle: begin
 s_axi_awready <= 1'b0;
 s_axi_wready <= 1'b0;
 s_axi_bid <= 3'b000;
 s_axi_bvalid <= 1'b0;
 s_axi_bresp <= 2'b00;
 s_axi_arready <= 1'b0;
 s_axi_rvalid <= 1'b0;
 s_axi_rresp <= 2'b00;
 s_axi_rid <= 3'b000;
 s_axi_rlast <= 1'b0;
 s_axi_rdata <= 32'h0;
 state <= predict_op;
 end

 predict_op: begin
 if (s_axi_awvalid)
 state <= accept_wr;
 else if (s_axi_arvalid)
 state <= accept_rd;
 end

 accept_wr: begin
 if (s_axi_awaddr < 16 && ((s_axi_awaddr + s_axi_awlen) < 16)) begin
 burst_len <= s_axi_awlen + 1;
 waddr <= s_axi_awaddr;
 state <= wait_wdata;
 s_axi_awready <= 1'b1;
 end else begin
 s_axi_awready <= 1'b0;
 state <= idle;
 end
 end

 wait_wdata: begin
 s_axi_awready <= 1'b0;
 if (s_axi_wvalid) begin
 state <= accept_wdata;
 wdata <= s_axi_wdata;
 wstrb <= s_axi_wstrb;
 end else if (timer == 15) begin
 state <= write_err;
 timer <= 0;
 end else begin
 timer <= timer + 1;
 state <= wait_wdata;
 end
 end

 accept_wdata: begin
 s_axi_wready <= 1'b1;
 state <= gen_data;
 end

 gen_data: begin
 s_axi_wready <= 1'b0;
 data_write <= {(wdata[31:24] & {8{wstrb[3]}}), 24'h0} |
 {8'h0, (wdata[23:16] & {8{wstrb[2]}}), 16'h0} |
 {16'h0, (wdata[15:8] & {8{wstrb[1]}}), 8'h0} |
 {24'h0, (wdata[7:0] & {8{wstrb[0]}})};
 state <= update_mem;
 end

 update_mem: begin
 if (count < 2) begin
 count <= count + 1;
 state <= update_mem;
 mem[waddr] <= data_write;
 end else begin
 burst_len <= burst_len - 1;
 count <= 0;
 state <= check_br_len;
 end
 end

 check_br_len: begin
 if (burst_len == 0)
 state <= send_ack;
 else
 state <= wait_wdata;
 end

 send_ack: begin
 if (s_axi_bready) begin
 s_axi_bvalid <= 1'b1;
 s_axi_bresp <= 2'b00;
 state <= idle;
 end else if (timer == 15) begin
 state <= idle;
 end else begin
 timer <= timer + 1;
 state <= send_ack;
 end
 end

 accept_rd: begin
 if (s_axi_araddr < 16 && ((s_axi_araddr + s_axi_arlen) < 16)) begin
 rburst_len <= s_axi_arlen;
 raddr <= s_axi_araddr;
 state <= fetch_rdata;
 s_axi_arready <= 1'b1;
 end else begin
 s_axi_arready <= 1'b0;
 state <= idle;
 end
 end

 fetch_rdata: begin
 s_axi_arready <= 1'b0;
 if (count < 2) begin
 count <= count + 1;
 state <= fetch_rdata;
 rdata <= mem[raddr];
 end else begin
 count <= 0;
 state <= send_rdata;
 end
 end

 send_rdata: begin
 s_axi_rvalid <= 1'b1;
 s_axi_rdata <= rdata;
 s_axi_rresp <= 2'b00;
 if (s_axi_rready) begin
 state <= rcheck_br_len;
 end else if (timer == 15) begin
 state <= idle;
 timer <= 0;
 end else begin
 state <= send_rdata;
 timer <= timer + 1;
 end
 end

 rcheck_br_len: begin
 rburst_len <= rburst_len - 1;
 s_axi_rvalid <= 1'b0;

 if (rburst_len == 1) begin
 state <= fetch_ldata;
 end else begin
 state <= fetch_rdata;
 end
 end

 fetch_ldata: begin
 if (count < 2) begin
 count <= count + 1;
 state <= fetch_ldata;
 rdata <= mem[raddr];
 end else begin
 count <= 0;
 state <= send_rlast;
 s_axi_rvalid <= 1'b1;
 s_axi_rdata <= rdata;
 s_axi_rresp <= 2'b00;
 s_axi_rlast <= 1'b1;
 end
 end

 send_rlast: begin
 if (s_axi_rready) begin
 state <= idle;
 s_axi_rvalid <= 1'b0;
 s_axi_rdata <= 0;
 s_axi_rresp <= 2'b00;
 s_axi_rlast <= 1'b0;
 timer <= 0;
 end else if (timer == 15) begin
 state <= idle;
 timer <= 0;
 end else begin
 state <= send_rlast;
 timer <= timer + 1;
 end
 end

 default: state <= idle;
 endcase
 end
end


endmodule
