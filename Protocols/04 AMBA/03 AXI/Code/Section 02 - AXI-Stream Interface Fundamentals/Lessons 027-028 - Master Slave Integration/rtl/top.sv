/*
 * REVISION ATLAS - INSTRUCTOR COURSE CODE (COMMENTS ADDED ONLY)
 * Section 02: AXI-Stream Interface Fundamentals
 * Lecture path: Lessons 27-28 - AXI-Stream Master/Slave Integration
 * Downloadable source page: Lesson 028
 * Module: top
 * Role: Instructor integration/top-level RTL
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
module top
(
// Signal definition - clk: clock used to sample the course FSM and interface handshakes on rising edges.
// Signal definition - rst: top-level reset wired directly to the active-LOW ARESETn ports.
// Signal definition - newd: local request that tells the AXI-Stream source to start a new fixed packet.
input clk,rst, newd,
// Signal definition - din: local payload/data input consumed by the course transaction generator.
input [7:0] din,
// Signal definition - dout: local data output exposed by the receiver or completed read path.
output [7:0] dout,
// Signal definition - last: packet/burst completion marker exposed by the retained course wiring.
output last
);
// Signal definition - last_t: internal AXI-Stream TLAST wire passed from the master to the slave and exposed as `last`.
// Signal definition - valid_t: validity control indicating that the matching course payload or response is offered.
// Signal definition - ready_t: readiness/acceptance control used by the matching course handshake.
wire last_t, valid_t, ready_t;
// Signal definition - data: internal payload wire joining the course source and receiver path.
wire [7:0] data;

axis_m m1 (clk,rst,newd,din, ready_t, valid_t, data, last_t);
axis_s s1 (clk, rst,ready_t,valid_t,data,last_t, dout);

assign last = last_t;

endmodule
