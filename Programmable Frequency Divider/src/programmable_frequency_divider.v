module programmable_frequency_divider (
    input  wire       clk,
    input  wire       reset,
    input  wire [2:0] divide_value,
    input  wire [3:0] high_half_cycles,
    output reg        clk_out
);

    localparam DIVIDE_BY_2 = 3'd2;
    localparam DIVIDE_BY_3 = 3'd3;

    reg div2_posedge;
    reg div2_negedge;

    reg [1:0] div3_count;
    reg       div3_one_cycle_posedge;
    reg       div3_one_cycle_negedge;
    reg       div3_two_cycles_posedge;
    reg       div3_two_cycles_negedge;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            div2_posedge            <= 1'b0;
            div3_count              <= 2'd2;
            div3_one_cycle_posedge  <= 1'b0;
            div3_two_cycles_posedge <= 1'b0;
        end else begin
            div2_posedge <= ~div2_posedge;

            case (div3_count)
                2'd0: begin
                    div3_count              <= 2'd1;
                    div3_one_cycle_posedge  <= 1'b0;
                    div3_two_cycles_posedge <= 1'b1;
                end

                2'd1: begin
                    div3_count              <= 2'd2;
                    div3_one_cycle_posedge  <= 1'b0;
                    div3_two_cycles_posedge <= 1'b0;
                end

                default: begin
                    div3_count              <= 2'd0;
                    div3_one_cycle_posedge  <= 1'b1;
                    div3_two_cycles_posedge <= 1'b1;
                end
            endcase
        end
    end

    always @(negedge clk or posedge reset) begin
        if (reset) begin
            div2_negedge            <= 1'b0;
            div3_one_cycle_negedge  <= 1'b0;
            div3_two_cycles_negedge <= 1'b0;
        end else begin
            div2_negedge            <= div2_posedge;
            div3_one_cycle_negedge  <= div3_one_cycle_posedge;
            div3_two_cycles_negedge <= div3_two_cycles_posedge;
        end
    end

    // One /N period contains 2N input half-cycles.
    // Change divide_value and high_half_cycles only while reset is asserted.
    always @(*) begin
        if (reset) begin
            clk_out = 1'b0;
        end else begin
            case (divide_value)
                DIVIDE_BY_2: begin
                    case (high_half_cycles)
                        4'd1: clk_out = div2_posedge & ~div2_negedge; // 25%
                        4'd2: clk_out = div2_posedge;                 // 50%
                        4'd3: clk_out = div2_posedge | div2_negedge;  // 75%
                        default: clk_out = 1'b0;
                    endcase
                end

                DIVIDE_BY_3: begin
                    case (high_half_cycles)
                        4'd1: clk_out = div3_one_cycle_posedge &
                                             ~div3_one_cycle_negedge; // 16.67%
                        4'd2: clk_out = div3_one_cycle_posedge;         // 33.33%
                        4'd3: clk_out = div3_one_cycle_posedge |
                                             div3_one_cycle_negedge;  // 50%
                        4'd4: clk_out = div3_two_cycles_posedge;        // 66.67%
                        4'd5: clk_out = div3_two_cycles_posedge |
                                             div3_two_cycles_negedge; // 83.33%
                        default: clk_out = 1'b0;
                    endcase
                end

                default: clk_out = 1'b0;
            endcase
        end
    end

endmodule
