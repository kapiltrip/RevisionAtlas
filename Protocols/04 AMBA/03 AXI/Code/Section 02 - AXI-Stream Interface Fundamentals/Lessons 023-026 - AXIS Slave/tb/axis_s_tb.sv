/*
 * REVISION ATLAS - INSTRUCTOR COURSE CODE (COMMENTS ADDED ONLY)
 * Section 02: AXI-Stream Interface Fundamentals
 * Lecture path: Lessons 23-26 - AXI-Stream Slave
 * Downloadable source page: Lesson 026
 * Module: axis_s_tb
 * Role: Instructor-supplied testbench/stimulus
 *
 * PRESERVATION:
 * - Module name, port/signal names, architecture, state flow, and executable
 *   statements are the instructor's. The repository adds comments and splits
 *   multi-module lesson blocks into named files only.
 *
 * ASSUMPTIONS:
 * - The interface carries 8-bit TDATA plus TVALID, TREADY, and TLAST.
 * - s_axis_aresetn is active LOW and sampled by the course state register.
 * - The source is expected to hold a beat until the Receiver raises TREADY.
 *
 * USED / OMITTED / SIMPLIFIED:
 * - TKEEP, TSTRB, TID, TDEST, TUSER, buffering, and a downstream output handshake are absent.
 * - dout is a combinational view in the store state, not a retained payload register.
 *
 * BEHAVIORAL CONSEQUENCE:
 * - A consumer cannot treat dout as stored data after the state leaves store.
 * - The implementation is a teaching endpoint and can insert readiness bubbles.
 */
`timescale 1ns / 1ps

module axis_s_tb;

    // Parameters
    // State/control definition - CLK_PERIOD: testbench clock period in nanoseconds; the generated clock toggles every half period.
    localparam CLK_PERIOD = 10; // Clock period in ns

    // Signals
    // Signal definition - s_axis_aclk: clock used to sample the course FSM and interface handshakes on rising edges.
    logic s_axis_aclk = 0;
    // Signal definition - s_axis_aresetn: active-LOW reset used by the course state and output logic.
    logic s_axis_aresetn;
    // Signal definition - s_axis_tvalid: AXI-Stream input VALID driven by the upstream Transmitter.
    logic s_axis_tvalid;
    // Signal definition - s_axis_tdata: AXI-Stream input payload associated with the current offered beat.
    logic [7:0] s_axis_tdata;
    // Signal definition - s_axis_tlast: AXI-Stream input packet-end marker associated with the current beat.
    logic s_axis_tlast;
    // Signal definition - s_axis_tready: AXI-Stream input READY returned by this Receiver/path.
    logic s_axis_tready;
    // Signal definition - dout: local data output exposed by the receiver or completed read path.
    reg [7:0] dout;

    // Instantiate the axis_s module
    axis_s uut (
        .s_axis_aclk(s_axis_aclk),
        .s_axis_aresetn(s_axis_aresetn),
        .s_axis_tready(s_axis_tready),
        .s_axis_tvalid(s_axis_tvalid),
        .s_axis_tdata(s_axis_tdata),
        .s_axis_tlast(s_axis_tlast),
        .dout(dout)
    );

    // Clock generation
    always #10 s_axis_aclk = ~s_axis_aclk;

    // Stimulus generation
    initial begin
        // Initialize inputs
        s_axis_tvalid = 0;
        s_axis_tdata = 8'h00;
        s_axis_tlast = 0;
        s_axis_aresetn = 0;
        repeat(5)@(posedge s_axis_aclk);
        s_axis_aresetn = 1;
        for(int i = 0; i<10;i++)
        begin
        @(posedge s_axis_aclk);
        s_axis_tvalid = 1;
        s_axis_tdata = $urandom;
        end
        @(posedge s_axis_aclk);
        s_axis_tlast = 1;
        @(posedge s_axis_aclk);
        s_axis_tlast = 0;
        s_axis_tvalid = 0;
        $finish;
    end


endmodule
