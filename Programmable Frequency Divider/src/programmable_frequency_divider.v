module programmable_frequency_divider (
    input  wire clk,
    input  wire reset,
    output reg  clk_out
);

    // Toggle on every rising edge: one output cycle takes two input cycles.
    always @(posedge clk or posedge reset) begin
        if (reset)
            clk_out <= 1'b0;
        else
            clk_out <= ~clk_out;
    end

endmodule
