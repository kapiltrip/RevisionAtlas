/*
 * REVISION ATLAS - INSTRUCTOR COURSE CODE (COMMENTS ADDED ONLY)
 * Section 06: AXI-Lite Combined Read and Write
 * Lecture path: Lessons 86-93 - Combined AXI-Lite Read/Write Master
 * Downloadable source page: Lesson 093
 * Module: tb_axilite_m
 * Role: Instructor-supplied testbench/stimulus
 *
 * PRESERVATION:
 * - Module/signal names, executable statements, FSM architecture, and stimulus
 *   are retained. Only comments and one-module-per-file organization were added.
 *
 * ASSUMPTIONS:
 * - new_tx starts one operation; wr HIGH selects write and LOW selects read.
 * - Finite counters report missing acknowledgements.
 * - The design is non-pipelined and single-outstanding.
 *
 * USED / OMITTED / SIMPLIFIED:
 * - Bursts and IDs do not exist in AXI-Lite.
 * - AWPROT/ARPROT wires in the TB are unconnected because the DUT has no corresponding ports.
 *
 * BEHAVIORAL CONSEQUENCE:
 * - Timeouts are course FSM policy, not an AXI requirement.
 * - Only one selected read or write path progresses at a time.
 */
module tb_axilite_m;

  // Signal definition - new_tx: local pulse/level that requests one new transaction.
  reg     new_tx = 0;
  // Signal definition - wr_timeout: course timeout flag asserted when the matching wait counter expires.
  // Signal definition - rd_timeout: course timeout flag asserted when the matching wait counter expires.
  wire    wr_timeout, rd_timeout;
  // Signal definition - wr: operation selector; HIGH chooses write and LOW chooses read.
  reg     wr;
  // Signal definition - waddr: accepted write address retained for GPIO decode or memory access.
  reg [31:0] waddr;
  // Signal definition - raddr: accepted read address retained for GPIO decode or memory access.
  reg [31:0] raddr;
  // Signal definition - din: local write/payload data supplied to the manager.
  reg [31:0] din;
  // Signal definition - dout: local read/receiver data returned by the design.
  wire [31:0] dout;
  // Signal definition - resp: local copy of the completed AXI response.
  wire [1:0] resp;

  // Signal definition - m_axi_aclk: rising-edge clock for the retained FSM and handshakes.
  reg     m_axi_aclk;
  // Signal definition - m_axi_aresetn: active-LOW reset for the course state/output logic.
  reg     m_axi_aresetn;
  // Signal definition - m_axi_awvalid: AXI write-address VALID.
  wire    m_axi_awvalid;
  // Signal definition - m_axi_awready: AXI write-address READY.
  reg     m_axi_awready;
  // Signal definition - m_axi_awaddr: AXI write address offered with AWVALID.
  wire [31:0] m_axi_awaddr;
  // Signal definition - m_axi_awprot: testbench-only protection wire with no matching DUT port in this lesson.
  wire [1:0] m_axi_awprot;

  // Signal definition - m_axi_wvalid: AXI write-data VALID.
  wire    m_axi_wvalid;
  // Signal definition - m_axi_wready: AXI write-data READY.
  reg     m_axi_wready;
  // Signal definition - m_axi_wdata: AXI write payload.
  wire [31:0] m_axi_wdata;
  // Signal definition - m_axi_wstrb: AXI write byte-lane strobes.
  wire [3:0] m_axi_wstrb;

  // Signal definition - m_axi_bvalid: AXI write-response VALID.
  reg     m_axi_bvalid;
  // Signal definition - m_axi_bready: AXI write-response READY.
  wire    m_axi_bready;
  // Signal definition - m_axi_bresp: AXI write-response status input; the course master ignores it and treats BVALID as completion.
  reg [1:0] m_axi_bresp;

  // Signal definition - m_axi_arvalid: AXI read-address VALID.
  wire    m_axi_arvalid;
  // Signal definition - m_axi_arready: AXI read-address READY.
  reg     m_axi_arready;
  // Signal definition - m_axi_araddr: AXI read address offered with ARVALID.
  wire [31:0] m_axi_araddr;
  // Signal definition - m_axi_arprot: testbench-only protection wire with no matching DUT port in this lesson.
  wire [1:0] m_axi_arprot;

  // Signal definition - m_axi_rvalid: AXI read-data VALID.
  reg     m_axi_rvalid;
  // Signal definition - m_axi_rready: AXI read-data READY.
  wire    m_axi_rready;
  // Signal definition - m_axi_rdata: AXI read payload.
  reg [31:0] m_axi_rdata;
  // Signal definition - m_axi_rresp: AXI read-response status.
  reg [1:0] m_axi_rresp;

  // Instantiate the DUT (Device Under Test)
  axilite_m uut (
    .new_tx(new_tx),
    .wr_timeout(wr_timeout),
    .rd_timeout(rd_timeout),
    .wr(wr),
    .waddr(waddr),
    .raddr(raddr),
    .din(din),
    .dout(dout),
    .resp(resp),
    .m_axi_aclk(m_axi_aclk),
    .m_axi_aresetn(m_axi_aresetn),
    .m_axi_awvalid(m_axi_awvalid),
    .m_axi_awready(m_axi_awready),
    .m_axi_awaddr(m_axi_awaddr),
    .m_axi_wvalid(m_axi_wvalid),
    .m_axi_wready(m_axi_wready),
    .m_axi_wdata(m_axi_wdata),
    .m_axi_wstrb(m_axi_wstrb),
    .m_axi_bvalid(m_axi_bvalid),
    .m_axi_bready(m_axi_bready),
    .m_axi_bresp(m_axi_bresp),
    .m_axi_arvalid(m_axi_arvalid),
    .m_axi_arready(m_axi_arready),
    .m_axi_araddr(m_axi_araddr),
    .m_axi_rvalid(m_axi_rvalid),
    .m_axi_rready(m_axi_rready),
    .m_axi_rdata(m_axi_rdata),
    .m_axi_rresp(m_axi_rresp)
  );

  // Clock generation
  always #5 m_axi_aclk = ~m_axi_aclk;

  // Signal definition - i: loop index used by initialization or TB stimulus.
  integer i = 0;
  initial begin
    // Initialize signals
    m_axi_aclk = 0;
    m_axi_aresetn = 0;
    wr = 0;
    waddr = 32'h0;
    raddr = 32'h0;
    din = 32'h0;
    m_axi_awready = 0;
    m_axi_wready = 0;
    m_axi_bvalid = 0;
    m_axi_bresp = 2'b00;
    m_axi_arready = 0;
    m_axi_rvalid = 0;
    m_axi_rdata = 32'h0;
    m_axi_rresp = 2'b00;

    // Reset sequence
    #10;
    m_axi_aresetn = 1;

    // Write operation
    for (i = 0; i < 10; i = i + 1) begin
      @(posedge m_axi_aclk);
      new_tx = 1'b1;
      wr = 1;
      waddr = i;
      din = i;
      repeat(7) @(posedge m_axi_aclk);
      new_tx = 0;
      m_axi_awready = 1;
      m_axi_wready = 1;
      repeat(7) @(posedge m_axi_aclk);
      m_axi_awready = 0;
      m_axi_wready = 0;
      m_axi_bvalid = 1;
      m_axi_bresp = 2'b00;
      @(posedge m_axi_aclk);
      m_axi_bvalid = 0;
    end

    // Read operation
    for (i = 0; i < 10; i = i + 1) begin
      @(posedge m_axi_aclk);
      new_tx = 1;
      wr = 0;
      raddr = i;
      repeat(8) @(posedge m_axi_aclk);
      new_tx = 0;
      m_axi_arready = 1;
      m_axi_rdata = 5;
      m_axi_rresp = 2'b00;
      m_axi_rvalid = 1;
      @(posedge m_axi_aclk);
      m_axi_arready = 0;
      m_axi_rvalid = 0;
      m_axi_rdata = 0;
      m_axi_rresp = 2'b00;
    end

    $finish;
  end

endmodule
