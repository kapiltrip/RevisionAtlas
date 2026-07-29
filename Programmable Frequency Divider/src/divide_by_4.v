`timescale 1ns/1ps

module divide_by_4 (
    input  wire       clk,
    input  wire       reset,
    input  wire [2:0] duty_select,
    output reg        clk_out
);

    localparam DUTY_12_5 = 3'd0;
    localparam DUTY_25   = 3'd1;
    localparam DUTY_37_5 = 3'd2;
    localparam DUTY_50   = 3'd3;
    localparam DUTY_62_5 = 3'd4;
    localparam DUTY_75   = 3'd5;
    localparam DUTY_87_5 = 3'd6;

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
    // Change duty_select only while reset is asserted.
    always @(*) begin
        if (reset) begin
            clk_out = 1'b0;
        end else begin
            case (duty_select)
                DUTY_12_5: clk_out = one_cycle_posedge &
                                     ~one_cycle_negedge;
                DUTY_25:   clk_out = one_cycle_posedge;
                DUTY_37_5: clk_out = one_cycle_posedge |
                                     one_cycle_negedge;
                DUTY_50:   clk_out = two_cycles_posedge;
                DUTY_62_5: clk_out = two_cycles_posedge |
                                     two_cycles_negedge;
                DUTY_75:   clk_out = three_cycles_posedge;
                DUTY_87_5: clk_out = three_cycles_posedge |
                                     three_cycles_negedge;
                default:   clk_out = 1'b0;
            endcase
        end
    end

endmodule
