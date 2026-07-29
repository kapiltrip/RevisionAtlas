`timescale 1ns/1ps

module divide_by_4 (
    input  wire clk,
    input  wire reset,
    output wire clk_out_12_5,
    output wire clk_out_25,
    output wire clk_out_37_5,
    output wire clk_out_50,
    output wire clk_out_62_5,
    output wire clk_out_75,
    output wire clk_out_87_5
);

    reg [1:0] count_posedge;
    reg [1:0] count_negedge;

    wire one_cycle_posedge;
    wire one_cycle_negedge;
    wire two_cycles_posedge;
    wire two_cycles_negedge;
    wire three_cycles_posedge;
    wire three_cycles_negedge;

    assign one_cycle_posedge    = (count_posedge < 2'd1);
    assign one_cycle_negedge    = (count_negedge < 2'd1);
    assign two_cycles_posedge   = (count_posedge < 2'd2);
    assign two_cycles_negedge   = (count_negedge < 2'd2);
    assign three_cycles_posedge = (count_posedge < 2'd3);
    assign three_cycles_negedge = (count_negedge < 2'd3);

    always @(posedge clk or posedge reset) begin
        if (reset)
            count_posedge <= 2'd3;
        else
            count_posedge <= count_posedge + 1'b1;
    end

    always @(negedge clk or posedge reset) begin
        if (reset)
            count_negedge <= 2'd3;
        else
            count_negedge <= count_posedge;
    end

    // One divide-by-4 period contains eight input half-cycles.
    // All valid duty-cycle waveforms are generated simultaneously.
    assign clk_out_12_5 = reset ? 1'b0 :
                          one_cycle_posedge & ~one_cycle_negedge;
    assign clk_out_25   = reset ? 1'b0 :
                          one_cycle_posedge;
    assign clk_out_37_5 = reset ? 1'b0 :
                          one_cycle_posedge | one_cycle_negedge;
    assign clk_out_50   = reset ? 1'b0 :
                          two_cycles_posedge;
    assign clk_out_62_5 = reset ? 1'b0 :
                          two_cycles_posedge | two_cycles_negedge;
    assign clk_out_75   = reset ? 1'b0 :
                          three_cycles_posedge;
    assign clk_out_87_5 = reset ? 1'b0 :
                          three_cycles_posedge | three_cycles_negedge;

endmodule
