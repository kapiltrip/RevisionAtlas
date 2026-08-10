/*
 * REVISION ATLAS - INSTRUCTOR COURSE CODE (COMMENTS ADDED ONLY)
 * Section 07: AXI-Lite GPIO
 * Lecture path: Lessons 95-100 - AXI-Lite GPIO Peripheral
 * Downloadable source page: Lesson 100
 * Module: tb_axi_gpio_slave
 * Role: Instructor-supplied testbench/stimulus
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
 * - Lesson 100 names the available GPIO design module `axilite_s`, but this
 *   supplied testbench instantiates `axilite_m`. The mismatch is retained.
 *
 * BEHAVIORAL CONSEQUENCE:
 * - Register and GPIO behavior follows the lecture FSM exactly.
 * - This exact supplied testbench cannot elaborate with the supplied GPIO
 *   design until the instructor's DUT module-name mismatch is resolved.
 */
////////////////////////// Testbench Code


module tb_axi_gpio_slave;

 // Signal definition - s_axi_aclk: rising-edge clock for the retained FSM and handshakes.
 reg s_axi_aclk;
 // Signal definition - s_axi_aresetn: active-LOW reset for the course state/output logic.
 reg s_axi_aresetn;

 // Write Address Channel
 // Signal definition - s_axi_awvalid: AXI write-address VALID.
 reg s_axi_awvalid;
 // Signal definition - s_axi_awready: AXI write-address READY.
 wire s_axi_awready;
 // Signal definition - s_axi_awaddr: AXI write address offered with AWVALID.
 reg [31:0] s_axi_awaddr;

 // Write Data Channel
 // Signal definition - s_axi_wvalid: AXI write-data VALID.
 reg s_axi_wvalid;
 // Signal definition - s_axi_wready: AXI write-data READY.
 wire s_axi_wready;
 // Signal definition - s_axi_wdata: AXI write payload.
 reg [31:0] s_axi_wdata;
 // Signal definition - s_axi_wstrb: AXI write byte-lane strobes.
 reg [3:0] s_axi_wstrb;

 // Write Response Channel
 // Signal definition - s_axi_bvalid: AXI write-response VALID.
 wire s_axi_bvalid;
 // Signal definition - s_axi_bready: AXI write-response READY.
 reg s_axi_bready;
 // Signal definition - s_axi_bresp: AXI write-response status.
 wire [1:0] s_axi_bresp;

 // Read Address Channel
 // Signal definition - s_axi_araddr: AXI read address offered with ARVALID.
 reg [31:0] s_axi_araddr;
 // Signal definition - s_axi_arvalid: AXI read-address VALID.
 reg s_axi_arvalid;
 // Signal definition - s_axi_arready: AXI read-address READY.
 wire s_axi_arready;

 // Read Data Channel
 // Signal definition - s_axi_rdata: AXI read payload.
 wire [31:0] s_axi_rdata;
 // Signal definition - s_axi_rresp: AXI read-response status.
 wire [1:0] s_axi_rresp;
 // Signal definition - s_axi_rvalid: AXI read-data VALID.
 wire s_axi_rvalid;
 // Signal definition - s_axi_rready: AXI read-data READY.
 reg s_axi_rready;

 // Output LEDs
 // Signal definition - led: GPIO output register updated by writes to the lesson's LED address.
 wire [31:0] led;
 // Signal definition - sw: raw GPIO switch input sampled by the lesson's debounce logic.
 reg [31:0] sw = 15;

 // Instantiate the DUT (Device Under Test)
 // Lesson 100 retained mismatch: this names axilite_m, while the supplied GPIO
 // design declares axilite_s. Consequence: elaboration stops with an unknown
 // axilite_m module; changing it here would no longer be the exact course source.
 axilite_m uut (
 .s_axi_aclk(s_axi_aclk),
 .s_axi_aresetn(s_axi_aresetn),
 .s_axi_awvalid(s_axi_awvalid),
 .s_axi_awready(s_axi_awready),
 .s_axi_awaddr(s_axi_awaddr),
 .s_axi_wvalid(s_axi_wvalid),
 .s_axi_wready(s_axi_wready),
 .s_axi_wdata(s_axi_wdata),
 .s_axi_wstrb(s_axi_wstrb),
 .s_axi_bvalid(s_axi_bvalid),
 .s_axi_bready(s_axi_bready),
 .s_axi_bresp(s_axi_bresp),
 .s_axi_araddr(s_axi_araddr),
 .s_axi_arvalid(s_axi_arvalid),
 .s_axi_arready(s_axi_arready),
 .s_axi_rdata(s_axi_rdata),
 .s_axi_rresp(s_axi_rresp),
 .s_axi_rvalid(s_axi_rvalid),
 .s_axi_rready(s_axi_rready),
 .led(led),
 .sw(sw)
 );

 // Clock generation
 always #5 s_axi_aclk = ~s_axi_aclk;

 initial begin
 // Initialize signals
 s_axi_aclk = 0;
 s_axi_aresetn = 0;
 s_axi_awvalid = 0;
 s_axi_awaddr = 32'h0;
 s_axi_wvalid = 0;
 s_axi_wdata = 32'h0;
 s_axi_wstrb = 4'b0000;
 s_axi_bready = 0;
 s_axi_araddr = 32'h0;
 s_axi_arvalid = 0;
 s_axi_rready = 0;

 // Apply reset
 #10;
 s_axi_aresetn = 1;

 // Write operation
 s_axi_awaddr = 32'h00000004;
 s_axi_awvalid = 1;
 s_axi_wdata = 32'h0000ABCD;
 s_axi_wvalid = 1;
 s_axi_wstrb = 4'b1111;
 s_axi_bready = 1;
 @(posedge s_axi_aclk);
 s_axi_awvalid = 1;
 @(posedge s_axi_awready);
 @(posedge s_axi_aclk);
 s_axi_awvalid = 0;
 s_axi_awaddr = 0;
 @(posedge s_axi_wready);
 @(posedge s_axi_aclk);
 s_axi_wvalid = 0;
 s_axi_wdata = 32'h0;
 s_axi_wstrb = 4'b0;
 @(posedge s_axi_bvalid);
 @(posedge s_axi_aclk);
 s_axi_bready = 0;
 @(posedge s_axi_aclk);

 @(posedge s_axi_aclk)
 // Read operation
 s_axi_araddr = 32'h00000004;
 s_axi_arvalid = 1;
 @(posedge s_axi_arready);
 @(posedge s_axi_aclk);
 s_axi_arvalid = 0;
 s_axi_rready = 1;
 @(posedge s_axi_rvalid);
 @(posedge s_axi_aclk);
 s_axi_rready = 0;
 @(posedge s_axi_aclk);
 @(posedge s_axi_aclk);

 s_axi_araddr = 32'h00000008;
 s_axi_arvalid = 1;
 @(posedge s_axi_arready);
 @(posedge s_axi_aclk);
 s_axi_arvalid = 0;
 s_axi_rready = 1;
 @(posedge s_axi_rvalid);
 @(posedge s_axi_aclk);
 s_axi_rready = 0;
 @(posedge s_axi_aclk);
 @(posedge s_axi_aclk);


 $finish;
 end

endmodule
