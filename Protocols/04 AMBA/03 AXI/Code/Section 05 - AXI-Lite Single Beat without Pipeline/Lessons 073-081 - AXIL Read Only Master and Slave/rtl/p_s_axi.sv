/*
 * REVISION ATLAS - INSTRUCTOR COURSE CODE (COMMENTS ADDED ONLY)
 * Section 05: AXI-Lite Single Beat without Pipeline
 * Lecture path: Lessons 73-81 - AXI-Lite Read-Only Master/Slave
 * Downloadable source page: Lesson 081
 * Module: p_s_axi
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

////////////////////////////////////////////////////////////

module p_s_axi (
 // Signal definition - s_axi_aclk: rising-edge clock for the retained FSM and handshakes.
 // Signal definition - s_axi_aresetn: active-LOW reset for the course state/output logic.
 input wire s_axi_aclk, s_axi_aresetn,
 // Read Address Channel
 // Signal definition - s_axi_arvalid: AXI read-address VALID.
 input wire s_axi_arvalid,
 // Signal definition - s_axi_arready: AXI read-address READY.
 output reg s_axi_arready,
 // Signal definition - s_axi_araddr: AXI read address offered with ARVALID.
 input wire [31:0] s_axi_araddr,
 // Read Data Channel
 // Signal definition - s_axi_rvalid: AXI read-data VALID.
 output reg s_axi_rvalid,
 // Signal definition - s_axi_rready: AXI read-data READY.
 input wire s_axi_rready,
 // Signal definition - s_axi_rdata: AXI read payload.
 output wire [31:0] s_axi_rdata,
 // Signal definition - s_axi_rresp: AXI read-response status.
 output wire [1:0] s_axi_rresp
);

// Update Memory
// Signal definition - mem: sixteen-entry, 32-bit teaching memory updated by accepted AXI-Lite writes.
reg [31:0] mem [15:0];
// Signal definition - i: loop index used by initialization or TB stimulus.
integer i;

always @(posedge s_axi_aclk) begin
 if (s_axi_aresetn == 1'b0) begin
 for (i = 0; i < 16; i = i + 1) begin
 mem[i] <= i * 5;
 end
 end
end

// Read Operation
// Signal definition - araddr: AXI read address offered with ARVALID.
reg [31:0] araddr;
// Signal definition - state: current/next state used by the instructor FSM.
reg [1:0] state = 0;
// Signal definition - rdata: AXI read payload.
reg [31:0] rdata;
// Signal definition - data_ready: READY/acceptance control for the matching retained channel.
reg data_ready = 0;

initial s_axi_arready = 0;

always @(posedge s_axi_aclk) begin
 if (s_axi_aresetn == 1'b0) begin
 s_axi_arready <= 1'b0;
 end else if (s_axi_arready) begin
 s_axi_arready <= 1'b0;
 end else if (s_axi_arvalid) begin
 s_axi_arready <= 1'b1;
 end
end

initial s_axi_rvalid = 0;
always @(posedge s_axi_aclk) begin
 if (s_axi_aresetn == 1'b0) begin
 s_axi_rvalid <= 1'b0;
 end else if (data_ready && !s_axi_rvalid) begin
 s_axi_rvalid <= 1;
 end else if (s_axi_rready) begin
 s_axi_rvalid <= 0;
 end
end

always @(posedge s_axi_aclk) begin
 if (s_axi_aresetn == 1'b0) begin
 state <= 0;
 data_ready <= 1'b0;
 araddr <= 0;
 rdata <= 0;
 end else begin
 case(state)
 0: begin
 if (s_axi_arvalid) begin
 state <= 1;
 araddr <= s_axi_araddr;
 end else begin
 state <= 0;
 end
 end
 1: begin
 rdata <= mem[araddr];
 state <= 2;
 end
 2: begin
 rdata <= mem[araddr];
 data_ready <= 1'b1;
 if (s_axi_rready) begin
 state <= 0;
 data_ready <= 1'b0;
 end
 end
 endcase
 end
end

// Signal definition - rresp: AXI read-response status.
reg [1:0] rresp;
always @(posedge s_axi_aclk) begin
 if (s_axi_aresetn == 1'b0) begin
 rresp <= 2'b00;
 end else if (data_ready) begin
 if (araddr <= 15) begin
 rresp <= 2'b00;
 end else begin
 rresp <= 2'b11;
 end
 end else begin
 rresp <= 2'b00;
 end
end

assign s_axi_rdata = (s_axi_rvalid) ? rdata : 0;
assign s_axi_rresp = (s_axi_rvalid) ? rresp : 0;

endmodule
