`timescale 1ns/1ps

module divide_by_3 (
    input  wire clk,
    input  wire reset,
    output wire clk_out_16_67,
    output wire clk_out_33_33,
    output wire clk_out_50,
    output wire clk_out_66_67,
    output wire clk_out_83_33
);

    reg [1:0] count_posedge;
    reg [1:0] count_negedge;

    wire one_cycle_posedge;
    wire one_cycle_negedge;
    wire two_cycles_posedge;
    wire two_cycles_negedge;

    assign one_cycle_posedge  = (count_posedge < 2'd1);
    assign one_cycle_negedge  = (count_negedge < 2'd1);
    assign two_cycles_posedge = (count_posedge < 2'd2);
    assign two_cycles_negedge = (count_negedge < 2'd2);

    always @(posedge clk or posedge reset) begin
        if (reset)
            count_posedge <= 2'd2;
        else if (count_posedge == 2'd2)
            count_posedge <= 2'd0;
        else
            count_posedge <= count_posedge + 1'b1;
    end

    always @(negedge clk or posedge reset) begin
        if (reset)
            count_negedge <= 2'd2;
        else
            count_negedge <= count_posedge;
    end

    // One divide-by-3 period contains six input half-cycles.
    // All valid duty-cycle waveforms are generated simultaneously.
    assign clk_out_16_67 = reset ? 1'b0 :
                           one_cycle_posedge & ~one_cycle_negedge;
    assign clk_out_33_33 = reset ? 1'b0 :
                           one_cycle_posedge;
    assign clk_out_50    = reset ? 1'b0 :
                           one_cycle_posedge | one_cycle_negedge;
    assign clk_out_66_67 = reset ? 1'b0 :
                           two_cycles_posedge;
    assign clk_out_83_33 = reset ? 1'b0 :
                           two_cycles_posedge | two_cycles_negedge;

endmodule
