/*
 * REVISION ATLAS - INSTRUCTOR COURSE CODE (COMMENTS ADDED ONLY)
 * Section 05: AXI-Lite Single Beat without Pipeline
 * Lecture path: Lessons 60-67 - AXI-Lite Write-Only Master/Slave
 * Downloadable source page: Lesson 066
 * Module: s_axi
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
 * - WSTRB and BREADY are declared but ignored by this supplied subordinate.
 *
 * BEHAVIORAL CONSEQUENCE:
 * - This unit demonstrates write sequencing only.
 * - Every accepted write replaces all 32 bits, and BVALID is a one-cycle pulse
 *   that is not held until BREADY.
 * - The instructor FSM is documented, not replaced.
 */
`timescale 1ns / 1ps

////////////////////////////////////////////////////////////

module s_axi (
 // Signal definition - i_clk: rising-edge clock for the retained FSM and handshakes.
 input wire i_clk,
 i_resetn,

 ///////////////Write Address Channel
 // Signal definition - s_axi_awvalid: AXI write-address VALID.
 input wire s_axi_awvalid,
 // Signal definition - s_axi_awready: AXI write-address READY.
 output reg s_axi_awready,
 // Signal definition - s_axi_awaddr: AXI write address offered with AWVALID.
 input wire [31:0] s_axi_awaddr,
 //////////////Write Data Channel
 // Signal definition - s_axi_wvalid: AXI write-data VALID.
 input wire s_axi_wvalid,
 // Signal definition - s_axi_wready: AXI write-data READY.
 output reg s_axi_wready,
 // Signal definition - s_axi_wdata: AXI write payload.
 input wire [31:0] s_axi_wdata,
 // Signal definition - s_axi_wstrb: AXI byte strobes are declared but ignored; the lesson writes all 32 data bits.
 input wire [ 3:0] s_axi_wstrb,
 ////////////Write Response Channel
 // Signal definition - s_axi_bvalid: AXI write-response VALID.
 output reg s_axi_bvalid,
 // Signal definition - s_axi_bready: response READY is ignored; BVALID is cleared after one cycle regardless of acceptance.
 input wire s_axi_bready,
 // Signal definition - s_axi_bresp: AXI write-response status.
 output reg [ 1:0] s_axi_bresp

);


 ///////////// slave write address
 initial s_axi_awready = 0;
 always @(posedge i_clk) begin
 if (i_resetn == 1'b0) s_axi_awready <= 0;
 else if (s_axi_awready) s_axi_awready <= 1'b0;
 else if (s_axi_awvalid) s_axi_awready <= 1'b1;
 end


 ///////////// slave write data
 initial s_axi_wready = 0;
 always @(posedge i_clk) begin
 if (i_resetn == 1'b0) s_axi_wready <= 0;
 else if (s_axi_wready) s_axi_wready <= 1'b0;
 else if (s_axi_wvalid) s_axi_wready <= 1'b1;
 end



 //// register addr logic
 // Signal definition - addr_in: latched AXI-Lite write address captured from the AW channel and used to index the teaching memory.
 reg [31:0] addr_in = 0;
 // Signal definition - valid_a: latched flag indicating that a write address has been captured from an AW handshake.
 reg valid_a = 0;


 always @(posedge i_clk) begin
 if (i_resetn == 1'b0) begin
 addr_in <= 0;
 valid_a <= 0;

 end else if (s_axi_bvalid) begin
 addr_in <= 0;
 valid_a <= 0;
 end else if (s_axi_awvalid) begin
 addr_in <= s_axi_awaddr;
 valid_a <= 1'b1;
 end

 end



 /////// register data
 // Signal definition - data_in: latched AXI-Lite WDATA value written after both address and data have been captured.
 reg [31:0] data_in;
 // Signal definition - valid_d: latched flag indicating that write data has been captured from a W handshake.
 reg valid_d = 0;

 always @(posedge i_clk) begin
 if (i_resetn == 1'b0) begin
 data_in <= 0;
 valid_d <= 0;
 end else if (s_axi_bvalid) begin
 data_in <= 0;
 valid_d <= 0;
 end else if (s_axi_wvalid) begin
 data_in <= s_axi_wdata;
 valid_d <= 1;
 end

 end


 ///////////// update memory
 // Signal definition - mem: sixteen-entry, 32-bit teaching memory updated by accepted AXI-Lite writes.
 reg [31:0] mem[16];

 always @(posedge i_clk) begin
 if (i_resetn == 1'b0) begin
 for (int i = 0; i < 16; i++) begin
 mem[i] <= 0;
 end
 end else if (valid_a && valid_d & addr_in <= 15) begin
 mem[addr_in] <= data_in;
 end
 end

 /////////////// generate transaction response
 initial s_axi_bvalid = 0;
 initial s_axi_bresp = 0;

 always @(posedge i_clk) begin
 if (i_resetn == 1'b0) begin
 s_axi_bvalid <= 0;
 s_axi_bresp <= 0;
 end else if (valid_a && valid_d && !s_axi_bvalid) begin
 s_axi_bvalid <= 1;
 if (addr_in <= 15) s_axi_bresp <= 2'b00;
 else s_axi_bresp <= 2'b11;
 end else if (s_axi_bvalid) begin
 s_axi_bvalid <= 0;
 s_axi_bresp <= 2'b00;
 end else begin
 s_axi_bvalid <= 0;
 s_axi_bresp <= 2'b00;
 end
 end


endmodule
