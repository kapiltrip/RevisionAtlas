module counter_75_98 (
    input  wire       clk,
    input  wire       rst,
    output wire [6:0] count
);
    reg state;

    // T flip-flop behavior with T permanently equal to 1.
    always @(posedge clk or posedge rst) begin
        if (rst)
            state <= 1'b0;
        else
            state <= ~state;
    end

    // state = 0 selects 75; state = 1 selects 98.
    assign count = state ? 7'd98 : 7'd75;
endmodule
