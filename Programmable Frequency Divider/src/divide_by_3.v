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

    reg [1:0] posphase;
    reg [1:0] negphase;

    wire one_cycle_posphase;
    wire one_cycle_negphase;
    wire two_cycles_posphase;
    wire two_cycles_negphase;

    assign one_cycle_posphase  = (posphase < 2'd1);
    assign one_cycle_negphase  = (negphase < 2'd1);
    assign two_cycles_posphase = (posphase < 2'd2);
    assign two_cycles_negphase = (negphase < 2'd2);

    always @(posedge clk or posedge reset) begin
        if (reset)
            posphase <= 2'd2;
        else if (posphase == 2'd2)
            posphase <= 2'd0;
        else
            posphase <= posphase + 1'b1;
    end

    always @(negedge clk or posedge reset) begin
        if (reset)
            negphase <= 2'd2;
        else
            negphase <= posphase;
    end

    // One divide-by-3 period contains six input half-cycles.
    // All valid duty-cycle waveforms are generated simultaneously.
    assign clk_out_16_67 = reset ? 1'b0 :
                           one_cycle_posphase & ~one_cycle_negphase;
    assign clk_out_33_33 = reset ? 1'b0 :
                           one_cycle_posphase;
    assign clk_out_50    = reset ? 1'b0 :
                           one_cycle_posphase | one_cycle_negphase;
    assign clk_out_66_67 = reset ? 1'b0 :
                           two_cycles_posphase;
    assign clk_out_83_33 = reset ? 1'b0 :
                           two_cycles_posphase | two_cycles_negphase;

endmodule
