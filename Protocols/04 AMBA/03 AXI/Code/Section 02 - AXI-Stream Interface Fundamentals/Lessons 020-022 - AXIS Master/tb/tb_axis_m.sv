/*
 * REVISION ATLAS - INSTRUCTOR COURSE CODE (COMMENTS ADDED ONLY)
 * Section 02: AXI-Stream Interface Fundamentals
 * Lecture path: Lessons 20-22 - AXI-Stream Master
 * Downloadable source page: Lesson 022
 * Module: tb_axis_m
 * Role: Instructor-supplied testbench/stimulus
 *
 * PRESERVATION:
 * - Module name, port/signal names, architecture, state flow, and executable
 *   statements are the instructor's. The repository adds comments and splits
 *   multi-module lesson blocks into named files only.
 *
 * ASSUMPTIONS:
 * - newd starts a packet and din remains stable for the complete packet.
 * - The packet always contains four 8-bit beats: din multiplied by count 0, 1, 2, and 3.
 * - m_axis_aresetn is sampled synchronously and is active LOW.
 *
 * USED / OMITTED / SIMPLIFIED:
 * - TKEEP, TSTRB, TID, TDEST, TUSER, and configurable packet length are not implemented.
 * - There is no local ready/acknowledge signal for newd and no input payload buffer.
 *
 * BEHAVIORAL CONSEQUENCE:
 * - Changing din during a stall can change the offered TDATA even though the beat was not accepted.
 * - Arithmetic truncates naturally to eight bits.
 */
module tb_axis_m;
    // Define testbench ports
    // Signal definition - m_axis_tdata: AXI-Stream output payload for the currently offered beat.
    wire [7:0] m_axis_tdata;
    // Signal definition - m_axis_tlast: AXI-Stream output packet-end marker paired with the current beat.
    wire m_axis_tlast;
    // Signal definition - m_axis_tready: AXI-Stream output READY returned by the downstream Receiver.
    reg m_axis_tready;
    // Signal definition - m_axis_tvalid: AXI-Stream output VALID presented to the downstream Receiver.
    wire m_axis_tvalid;
    // Signal definition - m_axis_aclk: clock used to sample the course FSM and interface handshakes on rising edges.
    reg m_axis_aclk = 0;
    // Signal definition - m_axis_aresetn: active-LOW reset used by the course state and output logic.
    reg m_axis_aresetn;
    // Signal definition - newd: local request that tells the AXI-Stream source to start a new fixed packet.
    reg newd;
    // Signal definition - din: local payload/data input consumed by the course transaction generator.
    reg [7:0] din;

    // Instantiate the axis_m module
    axis_m dut (
        .m_axis_tdata(m_axis_tdata),
        .m_axis_tlast(m_axis_tlast),
        .m_axis_tready(m_axis_tready),
        .m_axis_tvalid(m_axis_tvalid),
        .m_axis_aclk(m_axis_aclk),
        .m_axis_aresetn(m_axis_aresetn),
        .newd(newd),
        .din(din)
    );


    always #10 m_axis_aclk = ~m_axis_aclk;

    initial begin
    m_axis_aresetn = 0;
    repeat(10) @(posedge m_axis_aclk);
    for(int i = 0; i < 5; i++)
    begin
    @(posedge m_axis_aclk);
    m_axis_aresetn = 1;
    m_axis_tready  = 1'b1;
    newd = 1;
    din = $random();
    @(negedge m_axis_tlast);
    m_axis_tready = 1'b0;
    end

    end

endmodule
