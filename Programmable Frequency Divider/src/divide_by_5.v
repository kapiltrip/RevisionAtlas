`timescale 1ns/1ps

module divide_by_5 (
    input  wire clk,
    input  wire reset,
    output wire clk_out_10,
    output wire clk_out_20,
    output wire clk_out_30,
    output wire clk_out_40,
    output wire clk_out_50,
    output wire clk_out_60,
    output wire clk_out_70,
    output wire clk_out_80,
    output wire clk_out_90
);

    reg [2:0] count_posedge;
    reg [2:0] count_negedge;

    wire one_cycle_posedge;
    wire one_cycle_negedge;
    wire two_cycles_posedge;
    wire two_cycles_negedge;
    wire three_cycles_posedge;
    wire three_cycles_negedge;
    wire four_cycles_posedge;
    wire four_cycles_negedge;

    assign one_cycle_posedge    = (count_posedge < 3'd1);
    assign one_cycle_negedge    = (count_negedge < 3'd1);
    assign two_cycles_posedge   = (count_posedge < 3'd2);
    assign two_cycles_negedge   = (count_negedge < 3'd2);
    assign three_cycles_posedge = (count_posedge < 3'd3);
    assign three_cycles_negedge = (count_negedge < 3'd3);
    assign four_cycles_posedge  = (count_posedge < 3'd4);
    assign four_cycles_negedge  = (count_negedge < 3'd4);

    always @(posedge clk or posedge reset) begin
        if (reset)
            count_posedge <= 3'd4;
        else if (count_posedge == 3'd4)
            count_posedge <= 3'd0;
        else
            count_posedge <= count_posedge + 1'b1;
    end

    always @(negedge clk or posedge reset) begin
        if (reset)
            count_negedge <= 3'd4;
        else
            count_negedge <= count_posedge;
    end

    // One divide-by-5 period contains ten input half-cycles.
    // All valid duty-cycle waveforms are generated simultaneously.
    assign clk_out_10 = reset ? 1'b0 :
                        one_cycle_posedge & ~one_cycle_negedge;
    assign clk_out_20 = reset ? 1'b0 :
                        one_cycle_posedge;
    assign clk_out_30 = reset ? 1'b0 :
                        one_cycle_posedge | one_cycle_negedge;
    assign clk_out_40 = reset ? 1'b0 :
                        two_cycles_posedge;
    assign clk_out_50 = reset ? 1'b0 :
                        two_cycles_posedge | two_cycles_negedge;
    assign clk_out_60 = reset ? 1'b0 :
                        three_cycles_posedge;
    assign clk_out_70 = reset ? 1'b0 :
                        three_cycles_posedge | three_cycles_negedge;
    assign clk_out_80 = reset ? 1'b0 :
                        four_cycles_posedge;
    assign clk_out_90 = reset ? 1'b0 :
                        four_cycles_posedge | four_cycles_negedge;

endmodule
