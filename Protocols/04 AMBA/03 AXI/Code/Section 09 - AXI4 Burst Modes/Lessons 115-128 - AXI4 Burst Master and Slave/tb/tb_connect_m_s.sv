/*
 * REVISION ATLAS - INSTRUCTOR COURSE CODE (COMMENTS ADDED ONLY)
 * Section 09: AXI4 Burst Modes
 * Lecture path: Lessons 115-128 - AXI4 FIXED, INCR, and WRAP Bursts
 * Downloadable source page: Lesson 128
 * Module: tb_connect_m_s
 * Role: Instructor-supplied testbench/stimulus
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
 *
 * BEHAVIORAL CONSEQUENCE:
 * - WRAP behavior is limited to the supported aligned cases exercised in the course.
 * - System legality depends on the surrounding AXI configuration.
 */
module tb_connect_m_s;

    // Declare testbench signals
    // Signal definition - clk: rising-edge clock for the retained FSM and handshakes.
    reg         clk;
    // Signal definition - resetn: active-LOW reset for the course state/output logic.
    reg         resetn;
    // Signal definition - wr: operation selector; HIGH chooses write and LOW chooses read.
    reg         wr;
    // Signal definition - wr_addr: local starting address supplied for the requested AXI write.
    reg  [31:0] wr_addr;
    // Signal definition - wr_burst_len: requested AXI AWLEN value, encoded as write beats minus one.
    reg  [7:0]  wr_burst_len;
    // Signal definition - wr_burst_type: requested AXI AWBURST mode: FIXED, INCR, or WRAP.
    reg  [1:0]  wr_burst_type;
    // Signal definition - wr_din: local 32-bit payload supplied to the master for the requested write transfer.
    reg  [31:0] wr_din;
    // Signal definition - wr_strbin: byte-lane strobe associated with the write payload.
    reg  [3:0]  wr_strbin;
    // Signal definition - rd_addr: local starting address supplied for the requested AXI read.
    reg  [31:0] rd_addr;
    // Signal definition - rd_burst_len: requested AXI ARLEN value, encoded as read beats minus one.
    reg  [7:0]  rd_burst_len;
    // Signal definition - rd_burst_type: requested AXI ARBURST mode: FIXED, INCR, or WRAP.
    reg  [1:0]  rd_burst_type;
    // Signal definition - rout: local read-data result captured from the AXI R channel and exposed to the caller/testbench.
    wire [31:0] rout;
    // Signal definition - resp: local copy of the completed AXI response.
    wire [1:0]  resp;
    // Signal definition - pc_status: summary status returned by the external AXI Protocol Checker.
    wire [159:0] pc_status;
    // Signal definition - pc_asserted: vector of assertion bits reported by the external AXI Protocol Checker.
    wire pc_asserted;

    // Instantiate the DUT (Device Under Test)
    connect_m_s dut (
        .clk(clk),
        .resetn(resetn),
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
        .resp(resp),
        .pc_status(pc_status),
        .pc_asserted(pc_asserted)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100 MHz clock
    end

    // Test sequence
    initial begin
        // Initial reset
        resetn = 0;
        #20 resetn = 1;

        @(posedge clk);
        wr = 1;

        wr_addr = 24'h000001;
        wr_burst_len = 8'h4;
        wr_burst_type = 2'b01;
        wr_din = 32'h5;
        wr_strbin = 4'b1111;

        rd_addr = 0;
        rd_burst_len  = 0;
        rd_burst_type = 0;

        @(posedge dut.uut.m_axi_bvalid);
        @(posedge clk);
        wr = 0;
        rd_addr = 1;
        rd_burst_len  = 4;
        rd_burst_type = 0;
        @(posedge dut.uut.m_axi_rlast);
        @(posedge clk);
        $stop;
    end


endmodule
