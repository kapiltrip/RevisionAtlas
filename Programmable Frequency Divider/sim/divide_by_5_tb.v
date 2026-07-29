`timescale 1ns/1ps

module divide_by_5_tb;

    reg        clk;
    reg        reset;
    reg  [3:0] duty_select;
    wire       clk_out;

    integer errors;

    divide_by_5 dut (
        .clk         (clk),
        .reset       (reset),
        .duty_select (duty_select),
        .clk_out     (clk_out)
    );

    always #5 clk = ~clk;

    task check_mode;
        input [3:0] selected_duty;
        input integer expected_high_slots;
        integer slot;
        begin
            reset       = 1'b1;
            duty_select = selected_duty;
            repeat (2) @(negedge clk);
            #1;

            if (clk_out !== 1'b0) begin
                $display("ERROR /5: output is not LOW during reset");
                errors = errors + 1;
            end

            reset = 1'b0;

            // Check two complete periods of ten half-cycle slots each.
            for (slot = 0; slot < 20; slot = slot + 1) begin
                @(clk);
                #1;
                if (clk_out !== ((slot % 10) < expected_high_slots)) begin
                    $display("ERROR /5: select=%0d slot=%0d expected=%0d got=%0b",
                             selected_duty, slot,
                             ((slot % 10) < expected_high_slots), clk_out);
                    errors = errors + 1;
                end
            end
        end
    endtask

    initial begin
        clk         = 1'b0;
        reset       = 1'b1;
        duty_select = 4'd0;
        errors      = 0;

        check_mode(4'd0, 1); // 10%
        check_mode(4'd1, 2); // 20%
        check_mode(4'd2, 3); // 30%
        check_mode(4'd3, 4); // 40%
        check_mode(4'd4, 5); // 50%
        check_mode(4'd5, 6); // 60%
        check_mode(4'd6, 7); // 70%
        check_mode(4'd7, 8); // 80%
        check_mode(4'd8, 9); // 90%

        if (errors == 0)
            $display("PASS: all divide-by-5 duty-cycle modes");
        else
            $fatal(1, "FAIL: divide-by-5 produced %0d errors", errors);

        $finish;
    end

endmodule
