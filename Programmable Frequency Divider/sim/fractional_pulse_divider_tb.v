`timescale 1ns/1ps

module fractional_pulse_divider_tb;

    reg clk_2x;
    reg reset;

    wire pulse_div_1_5;
    wire pulse_div_2_5;
    wire pulse_div_3_5;
    wire pulse_div_4_5;

    integer errors;
    integer cycle;

    fractional_pulse_divider #(
        .TOTAL_COUNTS(3)
    ) div1_5_dut (
        .clk_2x   (clk_2x),
        .reset    (reset),
        .pulse_out(pulse_div_1_5)
    );

    fractional_pulse_divider #(
        .TOTAL_COUNTS(5)
    ) div2_5_dut (
        .clk_2x   (clk_2x),
        .reset    (reset),
        .pulse_out(pulse_div_2_5)
    );

    fractional_pulse_divider #(
        .TOTAL_COUNTS(7)
    ) div3_5_dut (
        .clk_2x   (clk_2x),
        .reset    (reset),
        .pulse_out(pulse_div_3_5)
    );

    fractional_pulse_divider #(
        .TOTAL_COUNTS(9)
    ) div4_5_dut (
        .clk_2x   (clk_2x),
        .reset    (reset),
        .pulse_out(pulse_div_4_5)
    );

    always #5 clk_2x = ~clk_2x;

    task check_pulse;
        input actual;
        input integer total_counts;
        input integer case_number;
        reg expected;
        begin
            expected = ((cycle % total_counts) == 0);
            if (actual !== expected) begin
                $display("ERROR case=%0d at %0t: cycle=%0d expected=%0b got=%0b",
                         case_number, $time, cycle, expected, actual);
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        $timeformat(-9, 0, " ns", 8);
`ifdef __ICARUS__
        $dumpfile("fractional_pulse_divider.vcd");
        $dumpvars(0, fractional_pulse_divider_tb);
`endif

        clk_2x = 1'b0;
        reset  = 1'b1;
        errors = 0;

        repeat (2) @(negedge clk_2x);
        #1;
        if ({
            pulse_div_4_5,
            pulse_div_3_5,
            pulse_div_2_5,
            pulse_div_1_5
        } !== 4'b0000) begin
            $display("ERROR: fractional pulse outputs are not LOW during reset");
            errors = errors + 1;
        end

        reset = 1'b0;

        for (cycle = 0; cycle < 36; cycle = cycle + 1) begin
            @(posedge clk_2x);
            #1;
            check_pulse(pulse_div_1_5, 3, 1);
            check_pulse(pulse_div_2_5, 5, 2);
            check_pulse(pulse_div_3_5, 7, 3);
            check_pulse(pulse_div_4_5, 9, 4);
        end

        if (errors == 0)
            $display("PASS: /1.5, /2.5, /3.5, and /4.5 pulse outputs");
        else
            $fatal(1, "FAIL: fractional pulse divider produced %0d errors",
                   errors);

        $finish;
    end

endmodule
