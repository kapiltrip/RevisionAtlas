`timescale 1ns/1ps

module fractional_pulse_divider #(
    parameter integer TOTAL_COUNTS = 3,
    parameter integer COUNT_WIDTH  = 4
) (
    input  wire clk_2x,
    input  wire reset,
    output wire pulse_out
);

    reg [COUNT_WIDTH-1:0] count;

    always @(posedge clk_2x or posedge reset) begin
        if (reset)
            count <= TOTAL_COUNTS - 1;
        else if (count == TOTAL_COUNTS - 1)
            count <= {COUNT_WIDTH{1'b0}};
        else
            count <= count + 1'b1;
    end

    // One pulse every TOTAL_COUNTS cycles of the external 2x clock.
    assign pulse_out = reset ? 1'b0 : (count == 0);

endmodule
