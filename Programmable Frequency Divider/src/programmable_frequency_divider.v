module programmable_frequency_divider (
    input  wire       clk,
    input  wire       reset,
    input  wire [1:0] duty_select,
    output reg        clk_out
);

    localparam DUTY_25 = 2'b00;
    localparam DUTY_50 = 2'b01;
    localparam DUTY_75 = 2'b10;

    reg phase_posedge;
    reg phase_negedge;

    // Divide-by-2 phase: toggles on every rising edge.
    always @(posedge clk or posedge reset) begin
        if (reset)
            phase_posedge <= 1'b0;
        else
            phase_posedge <= ~phase_posedge;
    end

    // Half-cycle delayed copy for the 25% and 75% outputs.
    always @(negedge clk or posedge reset) begin
        if (reset)
            phase_negedge <= 1'b1;
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
                DUTY_75: clk_out = phase_posedge | ~phase_negedge;
                default: clk_out = 1'b0;
            endcase
        end
    end

endmodule
