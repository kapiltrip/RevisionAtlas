/*
 * REVISION ATLAS - INSTRUCTOR COURSE CODE (COMMENTS ADDED ONLY)
 * Section 05: AXI-Lite Single Beat without Pipeline
 * Lecture path: Lessons 60-67 - AXI-Lite Write-Only Master/Slave
 * Downloadable source page: Lesson 067
 * Module: tb
 * Role: Instructor-supplied testbench/stimulus
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
 *
 * BEHAVIORAL CONSEQUENCE:
 * - This unit demonstrates write sequencing only.
 * - The instructor FSM is documented, not replaced.
 */
module tb;

  // Signal definition - clk: rising-edge clock for the retained FSM and handshakes.
  reg clk = 0;
  // Signal definition - resetn: active-LOW reset for the course state/output logic.
  reg resetn = 0;
  // Signal definition - wr: operation selector; HIGH chooses write and LOW chooses read.
  reg wr;
  // Signal definition - din: local write/payload data supplied to the manager.
  reg [31:0] din;
  // Signal definition - strbin: byte-lane strobe associated with the write payload.
  reg [3:0] strbin;
  // Signal definition - addrin: local command address driven by the testbench into the course manager.
  reg [31:0] addrin;

  // Signal definition - awvalid: AXI write-address VALID.
  // Signal definition - awready: AXI write-address READY.
  // Signal definition - wvalid: AXI write-data VALID.
  // Signal definition - wready: AXI write-data READY.
  // Signal definition - bvalid: AXI write-response VALID.
  // Signal definition - bready: AXI write-response READY.
  wire awvalid, awready, wvalid, wready, bvalid, bready;
  // Signal definition - awaddr: AXI write address offered with AWVALID.
  // Signal definition - wdata: accepted AXI write payload retained until the course FSM applies it.
  wire [31:0] awaddr, wdata;
  // Signal definition - strb: byte-lane strobe associated with the write payload.
  wire [3:0] strb;
  // Signal definition - resp: local copy of the completed AXI response.
  wire [1:0] resp;




  m_axi dut_m_axi (
      .i_clk   (clk),
      .i_resetn(resetn),
      .i_wr    (wr),
      .i_din   (din),
      .i_strb  (strbin),
      .i_addrin(addrin),

      .m_axi_awvalid(awvalid),
      .m_axi_awready(awready),
      .m_axi_awaddr (awaddr),

      .m_axi_wvalid(wvalid),
      .m_axi_wready(wready),
      .m_axi_wdata (wdata),
      .m_axi_wstrb (strb),

      .m_axi_bvalid(bvalid),
      .m_axi_bready(bready),
      .m_axi_bresp (resp)
  );



  s_axi dut_s_axi (
      .i_clk(clk),
      .i_resetn(resetn),

      .s_axi_awvalid(awvalid),
      .s_axi_awready(awready),
      .s_axi_awaddr (awaddr),

      .s_axi_wvalid(wvalid),
      .s_axi_wready(wready),
      .s_axi_wdata (wdata),
      .s_axi_wstrb (strb),

      .s_axi_bvalid(bvalid),
      .s_axi_bready(bready),
      .s_axi_bresp (resp)
  );

  always #10 clk = ~clk;

  initial begin
    resetn = 0;
    #20;
    resetn = 1;
  end

  initial begin
    @(posedge resetn);
    @(posedge clk);

    for (int i = 0; i < 10; i++) begin
      @(posedge clk);
      wr     = 1'b1;
      addrin = $urandom_range(0, 20);
      din    = $urandom_range(1, 10);
      strbin = 4'b1111;
      @(posedge bvalid);
      @(posedge clk);
    end
    $stop;
  end


endmodule
