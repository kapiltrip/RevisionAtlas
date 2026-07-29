`timescale 1ns/1ps

module divide_by_3_tb;

    reg  clk;
    reg  reset;
    wire clk_out_16_67;
    wire clk_out_33_33;
    wire clk_out_50;
    wire clk_out_66_67;
    wire clk_out_83_33;

    wire [4:0] divided_clocks;
    integer errors;
    integer slot;
    integer high_slots;

    assign divided_clocks = {
        clk_out_83_33,
        clk_out_66_67,
        clk_out_50,
        clk_out_33_33,
        clk_out_16_67
    };

    divide_by_3 dut (
        .clk          (clk),
        .reset        (reset),
        .clk_out_16_67(clk_out_16_67),
        .clk_out_33_33(clk_out_33_33),
        .clk_out_50   (clk_out_50),
        .clk_out_66_67(clk_out_66_67),
        .clk_out_83_33(clk_out_83_33)
    );

    always #5 clk = ~clk;

    initial begin
        $timeformat(-9, 0, " ns", 8);
`ifdef __ICARUS__
        $dumpfile("divide_by_3.vcd");
        $dumpvars(0, clk, reset,
                     clk_out_16_67, clk_out_33_33, clk_out_50,
                     clk_out_66_67, clk_out_83_33);
`endif

        clk    = 1'b0;
        reset  = 1'b1;
        errors = 0;

        repeat (2) @(negedge clk);
        #1;
        if (divided_clocks !== 5'b00000) begin
            $display("ERROR /3 at %0t: outputs are not LOW during reset", $time);
            errors = errors + 1;
        end

        reset = 1'b0;

        // Observe and check two complete divide-by-3 periods.
        for (slot = 0; slot < 12; slot = slot + 1) begin
            @(clk);
            #1;
            for (high_slots = 1; high_slots <= 5;
                 high_slots = high_slots + 1) begin
                if (divided_clocks[high_slots - 1] !==
                    ((slot % 6) < high_slots)) begin
                    $display("ERROR /3 at %0t: high_slots=%0d slot=%0d expected=%0d got=%0b",
                             $time, high_slots, slot,
                             ((slot % 6) < high_slots),
                             divided_clocks[high_slots - 1]);
                    errors = errors + 1;
                end
            end
        end

        if (errors == 0)
            $display("PASS: divide-by-3 generated all five duty-cycle waveforms");
        else
            $fatal(1, "FAIL: divide-by-3 produced %0d errors", errors);

        $finish;
    end

endmodule
