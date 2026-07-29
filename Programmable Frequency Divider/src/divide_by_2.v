`timescale 1ns/1ps

module divide_by_2 (
    input  wire clk,
    input  wire reset,
    output wire clk_out_25,
    output wire clk_out_50,
    output wire clk_out_75
);

    reg phase_posedge;
    reg phase_negedge;

    always @(posedge clk or posedge reset) begin
        if (reset)
            phase_posedge <= 1'b0;
        else
            phase_posedge <= ~phase_posedge;
    end

    always @(negedge clk or posedge reset) begin
        if (reset)
            phase_negedge <= 1'b0;
        else
            phase_negedge <= phase_posedge;
    end

    // All three divide-by-2 waveforms are generated at the same time.
    assign clk_out_25 = reset ? 1'b0 :
                        phase_posedge & ~phase_negedge;
    assign clk_out_50 = reset ? 1'b0 :
                        phase_posedge;
    assign clk_out_75 = reset ? 1'b0 :
                        phase_posedge | phase_negedge;

endmodule
