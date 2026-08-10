/*
 * REVISION ATLAS - INSTRUCTOR COURSE CODE (COMMENTS ADDED ONLY)
 * Section 02: AXI-Stream Interface Fundamentals
 * Lecture path: Lessons 27-28 - AXI-Stream Master/Slave Integration
 * Downloadable source page: Lesson 028
 * Module: top_tb
 * Role: Instructor-supplied testbench/stimulus
 *
 * PRESERVATION:
 * - Module name, port/signal names, architecture, state flow, and executable
 *   statements are the instructor's. The repository adds comments and splits
 *   multi-module lesson blocks into named files only.
 *
 * ASSUMPTIONS:
 * - Both endpoints share one clock and the rst port is wired as active-LOW ARESETn.
 * - axis_m from lesson 22 and axis_s from lesson 26 are compiled with this top level.
 * - Only one Transmitter and one Receiver are connected.
 *
 * USED / OMITTED / SIMPLIFIED:
 * - No clock-domain crossing, stream width conversion, packet buffering, or optional sideband routing is provided.
 *
 * BEHAVIORAL CONSEQUENCE:
 * - Direct wiring is valid only in the shared clock domain used by the course.
 * - The link inherits every simplification of the lesson 22 and lesson 26 endpoints.
 */
module top_tb();


// Signal definition - clk: clock used to sample the course FSM and interface handshakes on rising edges.
reg clk = 0;
// Signal definition - rst: top-level reset wired directly to the active-LOW ARESETn ports.
reg rst;
// Signal definition - newd: local request that tells the AXI-Stream source to start a new fixed packet.
reg newd;
// Signal definition - din: local payload/data input consumed by the course transaction generator.
reg [7:0] din;
// Signal definition - dout: local data output exposed by the receiver or completed read path.
wire [7:0] dout;
// Signal definition - last: packet/burst completion marker exposed by the retained course wiring.
wire last;


top dut(clk,rst, newd, din, dout, last);


 always #10 clk = ~clk;

 initial
    begin
        // Initialize inputs
        rst = 1'b0;
        repeat(10) @(posedge clk);
        rst = 1'b1;
        for(int i = 0; i <10; i++)
        begin
        @(posedge clk);
        newd = 1;
        din = $urandom_range(0,15);
        @(negedge last);
        end
        $finish;
    end

endmodule
