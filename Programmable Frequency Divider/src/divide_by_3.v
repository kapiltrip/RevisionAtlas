`timescale 1ns/1ps

module divide_by_3 (
    input  wire       clk,
    input  wire       reset,
    input  wire [2:0] duty_select,
    output reg        clk_out
);

    localparam DUTY_16_67 = 3'd0;
    localparam DUTY_33_33 = 3'd1;
    localparam DUTY_50    = 3'd2;
    localparam DUTY_66_67 = 3'd3;
    localparam DUTY_83_33 = 3'd4;

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
    // Change duty_select only while reset is asserted.
    always @(*) begin
        if (reset) begin
            clk_out = 1'b0;
        end else begin
            case (duty_select)
                DUTY_16_67: clk_out = one_cycle_posedge &
                                      ~one_cycle_negedge;
                DUTY_33_33: clk_out = one_cycle_posedge;
                DUTY_50:    clk_out = one_cycle_posedge |
                                      one_cycle_negedge;
                DUTY_66_67: clk_out = two_cycles_posedge;
                DUTY_83_33: clk_out = two_cycles_posedge |
                                      two_cycles_negedge;
                default:    clk_out = 1'b0;
            endcase
        end
    end

endmodule
