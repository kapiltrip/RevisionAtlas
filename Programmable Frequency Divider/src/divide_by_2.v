`timescale 1ns/1ps

module divide_by_2 (
    input  wire clk,
    input  wire reset,
    output wire clk_out_25,
    output wire clk_out_50,
    output wire clk_out_75
);

    reg posphase;
    reg negphase;

    always @(posedge clk or posedge reset) begin
        if (reset)
            posphase <= 1'b0;
        else
            posphase <= ~posphase;
    end

    always @(negedge clk or posedge reset) begin
        if (reset)
            negphase <= 1'b0;
        else
            negphase <= posphase;
    end

    // All three divide-by-2 waveforms are generated at the same time.
    assign clk_out_25 = reset ? 1'b0 :
                        posphase & ~negphase;
    assign clk_out_50 = reset ? 1'b0 :
                        posphase;
    assign clk_out_75 = reset ? 1'b0 :
                        posphase | negphase;

endmodule
