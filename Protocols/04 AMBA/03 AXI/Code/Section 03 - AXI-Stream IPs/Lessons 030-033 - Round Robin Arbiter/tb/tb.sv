/*
 * REVISION ATLAS - INSTRUCTOR COURSE CODE (COMMENTS ADDED ONLY)
 * Section 03: AXI-Stream IPs
 * Lecture path: Lessons 30-33 - Two-Requester Round-Robin Arbiter
 * Downloadable source page: Lesson 033
 * Module: tb
 * Role: Instructor-supplied testbench/stimulus
 *
 * PRESERVATION:
 * - Module name, port/signal names, architecture, state flow, and executable
 *   statements are the instructor's. The repository adds comments and splits
 *   multi-module lesson blocks into named files only.
 *
 * ASSUMPTIONS:
 * - A requester holds req1 or req2 until its grant is observed.
 * - rst is active HIGH.
 * - The initial idle tie-break selects requester 1.
 *
 * USED / OMITTED / SIMPLIFIED:
 * - There is no ready, completion, packet, or payload signal; this is not yet an AXI-Stream arbiter.
 * - The supplied testbench has no scoreboard or assertions.
 *
 * BEHAVIORAL CONSEQUENCE:
 * - Persistent simultaneous requests alternate grants after the initial tie-break.
 * - A request pulse that disappears before service can be missed.
 */
module tb;

// Signal definition - clk: clock used to sample the course FSM and interface handshakes on rising edges.
reg clk = 0;
// Signal definition - rst: active-HIGH reset for the round-robin state register.
reg rst = 0;
// Signal definition - req1: request input for the numbered arbiter client; assumed held until service.
// Signal definition - req2: request input for the numbered arbiter client; assumed held until service.
reg req1, req2;
// Signal definition - gnt1: grant output selecting the numbered arbiter client.
// Signal definition - gnt2: grant output selecting the numbered arbiter client.
wire gnt1, gnt2;

robin dut (
    .clk(clk),
    .rst(rst),
    .req1(req1),
    .req2(req2),
    .gnt1(gnt1),
    .gnt2(gnt2)
);

always #5 clk = ~clk;

initial begin
    rst = 1;
    repeat (5) @(posedge clk);
    rst = 0;
    req1 = 1;
    req2 = 0;
    @(posedge clk);
    req1 = 0;
    req2 = 1;
    @(posedge clk);
    req1 = 1;
    req2 = 1;
    repeat (5) @(posedge clk);
    $stop;
end

endmodule
