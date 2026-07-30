`timescale 1ns/1ps

module custom_duty_divider #(
    parameter integer TOTAL_COUNTS = 6,
    parameter integer HIGH_COUNTS  = 2,
    parameter integer COUNT_WIDTH  = 5
) (
    input  wire clk_fast,
    input  wire reset,
    output wire clk_out
);

    reg [COUNT_WIDTH-1:0] count;

    always @(posedge clk_fast or posedge reset) begin
        if (reset)
            count <= TOTAL_COUNTS - 1;
        else if (count == TOTAL_COUNTS - 1)
            count <= {COUNT_WIDTH{1'b0}};
        else
            count <= count + 1'b1;
    end

    assign clk_out = reset ? 1'b0 : (count < HIGH_COUNTS);

endmodule
