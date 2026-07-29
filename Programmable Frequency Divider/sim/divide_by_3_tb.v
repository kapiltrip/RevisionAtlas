`timescale 1ns/1ps

module divide_by_3_tb;

    reg        clk;
    reg        reset;
    reg  [2:0] duty_select;
    wire       clk_out;

    integer errors;

    divide_by_3 dut (
        .clk         (clk),
        .reset       (reset),
        .duty_select (duty_select),
        .clk_out     (clk_out)
    );

    always #5 clk = ~clk;

    task check_mode;
        input [2:0] selected_duty;
        input integer expected_high_slots;
        integer slot;
        begin
            reset       = 1'b1;
            duty_select = selected_duty;
            repeat (2) @(negedge clk);
            #1;

            if (clk_out !== 1'b0) begin
                $display("ERROR /3: output is not LOW during reset");
                errors = errors + 1;
            end

            reset = 1'b0;

            // Check two complete periods of six half-cycle slots each.
            for (slot = 0; slot < 12; slot = slot + 1) begin
                @(clk);
                #1;
                if (clk_out !== ((slot % 6) < expected_high_slots)) begin
                    $display("ERROR /3: select=%0d slot=%0d expected=%0d got=%0b",
                             selected_duty, slot,
                             ((slot % 6) < expected_high_slots), clk_out);
                    errors = errors + 1;
                end
            end
        end
    endtask

    initial begin
        clk         = 1'b0;
        reset       = 1'b1;
        duty_select = 3'd0;
        errors      = 0;

        check_mode(3'd0, 1); // 16.67%
        check_mode(3'd1, 2); // 33.33%
        check_mode(3'd2, 3); // 50%
        check_mode(3'd3, 4); // 66.67%
        check_mode(3'd4, 5); // 83.33%

        if (errors == 0)
            $display("PASS: all divide-by-3 duty-cycle modes");
        else
            $fatal(1, "FAIL: divide-by-3 produced %0d errors", errors);

        $finish;
    end

endmodule
