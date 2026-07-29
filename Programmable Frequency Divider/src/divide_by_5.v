`timescale 1ns/1ps

module divide_by_5 (
    input  wire       clk,
    input  wire       reset,
    input  wire [3:0] duty_select,
    output reg        clk_out
);

    localparam DUTY_10 = 4'd0;
    localparam DUTY_20 = 4'd1;
    localparam DUTY_30 = 4'd2;
    localparam DUTY_40 = 4'd3;
    localparam DUTY_50 = 4'd4;
    localparam DUTY_60 = 4'd5;
    localparam DUTY_70 = 4'd6;
    localparam DUTY_80 = 4'd7;
    localparam DUTY_90 = 4'd8;

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
    // Change duty_select only while reset is asserted.
    always @(*) begin
        if (reset) begin
            clk_out = 1'b0;
        end else begin
            case (duty_select)
                DUTY_10: clk_out = one_cycle_posedge &
                                   ~one_cycle_negedge;
                DUTY_20: clk_out = one_cycle_posedge;
                DUTY_30: clk_out = one_cycle_posedge |
                                   one_cycle_negedge;
                DUTY_40: clk_out = two_cycles_posedge;
                DUTY_50: clk_out = two_cycles_posedge |
                                   two_cycles_negedge;
                DUTY_60: clk_out = three_cycles_posedge;
                DUTY_70: clk_out = three_cycles_posedge |
                                   three_cycles_negedge;
                DUTY_80: clk_out = four_cycles_posedge;
                DUTY_90: clk_out = four_cycles_posedge |
                                   four_cycles_negedge;
                default: clk_out = 1'b0;
            endcase
        end
    end

endmodule
