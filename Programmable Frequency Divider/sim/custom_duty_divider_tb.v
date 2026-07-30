`timescale 1ns/1ps

module custom_duty_divider_tb;

    reg clk_fast;
    reg reset;

    wire div2_duty_33_33;
    wire div2_duty_60;
    wire div3_duty_25;
    wire div3_duty_40;
    wire div3_duty_75;
    wire div4_duty_33_33;
    wire div4_duty_80;
    wire div5_duty_25;
    wire div5_duty_33_33;
    wire div5_duty_75;

    integer errors;
    integer cycle;

    custom_duty_divider #(
        .TOTAL_COUNTS(6),
        .HIGH_COUNTS (2)
    ) div2_33_33_dut (
        .clk_fast(clk_fast),
        .reset   (reset),
        .clk_out (div2_duty_33_33)
    );

    custom_duty_divider #(
        .TOTAL_COUNTS(10),
        .HIGH_COUNTS (6)
    ) div2_60_dut (
        .clk_fast(clk_fast),
        .reset   (reset),
        .clk_out (div2_duty_60)
    );

    custom_duty_divider #(
        .TOTAL_COUNTS(12),
        .HIGH_COUNTS (3)
    ) div3_25_dut (
        .clk_fast(clk_fast),
        .reset   (reset),
        .clk_out (div3_duty_25)
    );

    custom_duty_divider #(
        .TOTAL_COUNTS(15),
        .HIGH_COUNTS (6)
    ) div3_40_dut (
        .clk_fast(clk_fast),
        .reset   (reset),
        .clk_out (div3_duty_40)
    );

    custom_duty_divider #(
        .TOTAL_COUNTS(12),
        .HIGH_COUNTS (9)
    ) div3_75_dut (
        .clk_fast(clk_fast),
        .reset   (reset),
        .clk_out (div3_duty_75)
    );

    custom_duty_divider #(
        .TOTAL_COUNTS(12),
        .HIGH_COUNTS (4)
    ) div4_33_33_dut (
        .clk_fast(clk_fast),
        .reset   (reset),
        .clk_out (div4_duty_33_33)
    );

    custom_duty_divider #(
        .TOTAL_COUNTS(20),
        .HIGH_COUNTS (16)
    ) div4_80_dut (
        .clk_fast(clk_fast),
        .reset   (reset),
        .clk_out (div4_duty_80)
    );

    custom_duty_divider #(
        .TOTAL_COUNTS(20),
        .HIGH_COUNTS (5)
    ) div5_25_dut (
        .clk_fast(clk_fast),
        .reset   (reset),
        .clk_out (div5_duty_25)
    );

    custom_duty_divider #(
        .TOTAL_COUNTS(15),
        .HIGH_COUNTS (5)
    ) div5_33_33_dut (
        .clk_fast(clk_fast),
        .reset   (reset),
        .clk_out (div5_duty_33_33)
    );

    custom_duty_divider #(
        .TOTAL_COUNTS(20),
        .HIGH_COUNTS (15)
    ) div5_75_dut (
        .clk_fast(clk_fast),
        .reset   (reset),
        .clk_out (div5_duty_75)
    );

    always #5 clk_fast = ~clk_fast;

    task check_case;
        input actual;
        input integer total_counts;
        input integer high_counts;
        input integer case_number;
        reg expected;
        begin
            expected = ((cycle % total_counts) < high_counts);
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
        $dumpfile("custom_duty_divider.vcd");
        $dumpvars(0, custom_duty_divider_tb);
`endif

        clk_fast = 1'b0;
        reset    = 1'b1;
        errors   = 0;

        repeat (2) @(negedge clk_fast);
        #1;
        if ({
            div5_duty_75,
            div5_duty_33_33,
            div5_duty_25,
            div4_duty_80,
            div4_duty_33_33,
            div3_duty_75,
            div3_duty_40,
            div3_duty_25,
            div2_duty_60,
            div2_duty_33_33
        } !== 10'b0000000000) begin
            $display("ERROR: custom-duty outputs are not LOW during reset");
            errors = errors + 1;
        end

        reset = 1'b0;

        for (cycle = 0; cycle < 40; cycle = cycle + 1) begin
            @(posedge clk_fast);
            #1;
            check_case(div2_duty_33_33, 6,  2,  1);
            check_case(div2_duty_60,    10, 6,  2);
            check_case(div3_duty_25,    12, 3,  3);
            check_case(div3_duty_40,    15, 6,  4);
            check_case(div3_duty_75,    12, 9,  5);
            check_case(div4_duty_33_33, 12, 4,  6);
            check_case(div4_duty_80,    20, 16, 7);
            check_case(div5_duty_25,    20, 5,  8);
            check_case(div5_duty_33_33, 15, 5,  9);
            check_case(div5_duty_75,    20, 15, 10);
        end

        if (errors == 0)
            $display("PASS: all ten custom-duty divider cases");
        else
            $fatal(1, "FAIL: custom-duty divider produced %0d errors", errors);

        $finish;
    end

endmodule
