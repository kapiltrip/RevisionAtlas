`timescale 1ns/1ps

module divide_by_2 (
    input  wire       clk,
    input  wire       reset,
    input  wire [1:0] duty_select,
    output reg        clk_out
);

    localparam DUTY_25 = 2'd0;
    localparam DUTY_50 = 2'd1;
    localparam DUTY_75 = 2'd2;

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

    // Change duty_select only while reset is asserted.
    always @(*) begin
        if (reset) begin
            clk_out = 1'b0;
        end else begin
            case (duty_select)
                DUTY_25: clk_out = phase_posedge & ~phase_negedge;
                DUTY_50: clk_out = phase_posedge;
                DUTY_75: clk_out = phase_posedge | phase_negedge;
                default: clk_out = 1'b0;
            endcase
        end
    end

endmodule
