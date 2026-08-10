/*
 * REVISION ATLAS - INSTRUCTOR COURSE CODE (COMMENTS ADDED ONLY)
 * Section 07: AXI-Lite GPIO
 * Lecture path: Lessons 95-100 - AXI-Lite GPIO Peripheral
 * Downloadable source page: Lesson 100
 * Module: axilite_s
 * Role: Instructor design RTL
 *
 * PRESERVATION:
 * - Module/signal names, executable statements, FSM architecture, and stimulus
 *   are retained. Only comments and one-module-per-file organization were added.
 *
 * ASSUMPTIONS:
 * - Single-beat AXI-Lite accesses control/read GPIO state.
 * - WSTRB enables written byte lanes.
 * - GPIO input uses the instructor debounce/sample logic.
 *
 * USED / OMITTED / SIMPLIFIED:
 * - Pipelining, multiple outstanding requests, bursts, IDs, and absent optional sidebands are not added.
 * - The non-AXI-Lite BID output is declared by the lesson but never assigned.
 *
 * BEHAVIORAL CONSEQUENCE:
 * - Register and GPIO behavior follows the lecture FSM exactly.
 * - BID is undriven/unknown in simulation and must not be used as status.
 */
////////////////Design Code:

module axilite_s
(
 // Signal definition - s_axi_aclk: rising-edge clock for the retained FSM and handshakes.
 input wire s_axi_aclk,
 // Signal definition - s_axi_aresetn: active-LOW reset for the course state/output logic.
 input wire s_axi_aresetn,

 // Signal definition - s_axi_awvalid: AXI write-address VALID.
 input wire s_axi_awvalid,
 // Signal definition - s_axi_awready: AXI write-address READY.
 output reg s_axi_awready,
 // Signal definition - s_axi_awaddr: AXI write address offered with AWVALID.
 input wire [31:0] s_axi_awaddr,


 // Signal definition - s_axi_wvalid: AXI write-data VALID.
 input wire s_axi_wvalid,
 // Signal definition - s_axi_wready: AXI write-data READY.
 output reg s_axi_wready,
 // Signal definition - s_axi_wdata: AXI write payload.
 input wire [31:0] s_axi_wdata,
 // Signal definition - s_axi_wstrb: AXI write byte-lane strobes.
 input wire [3:0] s_axi_wstrb,

 // Signal definition - s_axi_bid: lesson 100 declares this non-AXI-Lite response ID but never drives it; its value is unknown.
 output reg [2:0] s_axi_bid,
 // Signal definition - s_axi_bvalid: AXI write-response VALID.
 output reg s_axi_bvalid,
 // Signal definition - s_axi_bready: AXI write-response READY.
 input wire s_axi_bready,
 // Signal definition - s_axi_bresp: AXI write-response status.
 output reg [1:0] s_axi_bresp,

 // Signal definition - s_axi_arvalid: AXI read-address VALID.
 input wire s_axi_arvalid,
 // Signal definition - s_axi_arready: AXI read-address READY.
 output reg s_axi_arready,
 // Signal definition - s_axi_araddr: AXI read address offered with ARVALID.
 input wire [31:0] s_axi_araddr,

 // Signal definition - s_axi_rvalid: AXI read-data VALID.
 output reg s_axi_rvalid,
 // Signal definition - s_axi_rready: AXI read-data READY.
 input wire s_axi_rready,
 // Signal definition - s_axi_rdata: AXI read payload.
 output reg [31:0] s_axi_rdata,
 // Signal definition - s_axi_rresp: AXI read-response status.
 output reg [1:0] s_axi_rresp,

 // Signal definition - led: GPIO output register updated by writes to the lesson's LED address.
 output reg [31:0] led,
 // Signal definition - sw: raw GPIO switch input sampled by the lesson's debounce logic.
 input wire [31:0] sw
);


// Signal definition - idle: numeric encoding of the FSM's inactive state, where no new AXI transfer is being advanced.
localparam idle = 0,
 predict_op = 1,
 accept_wr = 2,
 wait_wdata = 3,
 accept_wdata = 4,
 gen_data = 5,
 update_reg = 6,
 send_ack =7,
 accept_rd = 8,
 fetch_rdata = 9,
 send_rdata =10;

 initial begin
 s_axi_awready = 0;
 s_axi_wready = 0;
 s_axi_bvalid = 0;
 s_axi_bresp = 0;
 s_axi_arready = 0;
 s_axi_rvalid = 0;
 s_axi_rdata = 0;
 s_axi_rresp = 0;
 end


// Signal definition - state: current/next state used by the instructor FSM.
reg [3:0] state = 0;
// Signal definition - waddr: accepted write address retained for GPIO decode or memory access.
// Signal definition - wdata: accepted AXI write payload retained until the course FSM applies it.
// Signal definition - data_write: WSTRB-masked write payload produced before the GPIO or memory update.
// Signal definition - raddr: accepted read address retained for GPIO decode or memory access.
// Signal definition - sw_reg: accepted debounced switch value returned by reads of the switch register.
// Signal definition - rdata: AXI read payload.
// Signal definition - sw_reg_deb: candidate switch sample retained while the debounce interval is checked.
reg [31:0] waddr = 0, wdata = 0, data_write = 0, raddr = 0, sw_reg = 0, rdata = 0, sw_reg_deb = 0;
// Signal definition - wstrb: accepted AXI byte-lane strobes retained with WDATA.
reg [3:0] wstrb = 0;
// Signal definition - count: two-cycle lesson-FSM pacing counter used before register-update/read-response states.
reg [1:0] count = 0;

// Signal definition - offset_led: GPIO LED register byte offset; the course literal resolves to address offset 4.
parameter offset_led = 6'h004;
// Signal definition - offset_sw: GPIO switch register byte offset; the course literal resolves to address offset 8.
parameter offset_sw = 6'h008;

// Signal definition - dcount: GPIO debounce sample counter; a candidate switch value is accepted after the lesson's five-count check.
integer dcount = 0;

///debounce logic
 always@(posedge s_axi_aclk)
 begin
 if (s_axi_aresetn == 0)
 begin
 sw_reg <= 32'h0;
 sw_reg_deb <= 32'h0;
 dcount <= 0;
 end
 else if (dcount == 0)
 begin
 sw_reg_deb <= sw;
 dcount <= dcount + 1;
 end
 else if(dcount == 5)
 begin
 if(sw_reg_deb == sw)
 begin
 sw_reg <= sw_reg_deb;
 dcount <= 0;
 end
 else
 begin
 dcount <= 0;
 end
 end
 else
 begin
 dcount <= dcount + 1;
 end
 end

always @(posedge s_axi_aclk) begin
 if (s_axi_aresetn == 0)
 begin
 state <= idle;
 led <= 0;
 end else begin
 case (state)
 idle: begin
 s_axi_awready <= 1'b0;
 s_axi_wready <= 1'b0;
 s_axi_bvalid <= 1'b0;
 s_axi_bresp <= 2'b00;
 s_axi_arready <= 1'b0;
 s_axi_rvalid <= 1'b0;
 s_axi_rresp <= 2'b00;
 s_axi_rdata <= 32'h0;
 waddr <= 0;
 wdata <= 0;
 wstrb <= 0;
 state <= predict_op;
 led <= led;
 end

 predict_op: begin
 if (s_axi_awvalid && s_axi_awaddr == 4)
 state <= accept_wr;
 else if (s_axi_arvalid && (s_axi_araddr == 8 | s_axi_araddr == 4))
 state <= accept_rd;
 else
 state <= idle;
 end

 accept_wr:
 begin
 waddr <= s_axi_awaddr;
 s_axi_awready <= 1'b1;
 state <= wait_wdata;
 end

 wait_wdata:
 begin
 s_axi_awready <= 1'b0;
 if (s_axi_wvalid)
 begin
 state <= accept_wdata;
 wdata <= s_axi_wdata;
 wstrb <= s_axi_wstrb;
 end else
 begin
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
 state <= update_reg;
 end

 update_reg: begin
 led <= data_write;
 if (count < 2) begin
 count <= count + 1;
 state <= update_reg;
 end else begin
 count <= 0;
 state <= send_ack;
 end
 end


 send_ack: begin
 if (s_axi_bready) begin
 s_axi_bvalid <= 1'b1;
 s_axi_bresp <= 2'b00;
 state <= idle;
 end else begin
 state <= send_ack;
 end
 end

 accept_rd:
 begin
 raddr <= s_axi_araddr;
 state <= fetch_rdata;
 s_axi_arready <= 1'b1;
 end


 fetch_rdata: begin
 s_axi_arready <= 1'b0;

 if (count < 2) begin
 count <= count + 1;
 state <= fetch_rdata;
 rdata <= (raddr == 4) ? led : ((raddr == 8) ? sw_reg : 32'h0) ;
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
 state <= idle;
 end else begin
 state <= send_rdata;
 end
 end

 default: state <= idle;
 endcase
 end
end



endmodule
