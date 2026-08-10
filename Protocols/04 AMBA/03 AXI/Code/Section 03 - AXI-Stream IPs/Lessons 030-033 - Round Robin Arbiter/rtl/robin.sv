/*
 * REVISION ATLAS - INSTRUCTOR COURSE CODE (COMMENTS ADDED ONLY)
 * Section 03: AXI-Stream IPs
 * Lecture path: Lessons 30-33 - Two-Requester Round-Robin Arbiter
 * Downloadable source page: Lesson 033
 * Module: robin
 * Role: Instructor design RTL
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
`timescale 1ns / 1ps

module robin(
    // Signal definition - clk: clock used to sample the course FSM and interface handshakes on rising edges.
    // Signal definition - rst: active-HIGH reset for the round-robin state register.
    input  clk, rst,
    // Signal definition - req1: request input for the numbered arbiter client; assumed held until service.
    // Signal definition - req2: request input for the numbered arbiter client; assumed held until service.
    input  req1, req2,
    // Signal definition - gnt1: grant output selecting the numbered arbiter client.
    // Signal definition - gnt2: grant output selecting the numbered arbiter client.
    output reg gnt1, gnt2
);

// State definition - encoded FSM states used by the instructor's next-state logic.
typedef enum bit [1:0] {idle = 2'b00, s1 = 2'b01, s2 = 2'b10} state_type;
state_type state, next_state;

always @(posedge clk) begin
    if (rst)
        state <= idle;
    else
        state <= next_state;
end

always @(*) begin
    case (state)
        idle: begin
            if (req1)
                next_state = s1;
            else if (req2)
                next_state = s2;
            else
                next_state = idle;
        end

        s1: begin
            if (req2)
                next_state = s2;
            else if (req1)
                next_state = s1;
            else
                next_state = idle;
        end

        s2: begin
            if (req1)
                next_state = s1;
            else if (req2)
                next_state = s2;
            else
                next_state = idle;
        end

        default: begin
            next_state = idle;
        end
    endcase
end

always @(*) begin
    case (state)
        idle: begin
            gnt1 = 1'b0;
            gnt2 = 1'b0;
        end

        s1: begin
            gnt1 = 1'b1;
            gnt2 = 1'b0;
        end

        s2: begin
            gnt1 = 1'b0;
            gnt2 = 1'b1;
        end

        default: begin
            gnt1 = 1'b0;
            gnt2 = 1'b0;
        end
    endcase
end

endmodule
