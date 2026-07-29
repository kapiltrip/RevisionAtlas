`timescale 1ns/1ps

module divide_by_4_tb;

    reg  clk;
    reg  reset;
    wire clk_out_12_5;
    wire clk_out_25;
    wire clk_out_37_5;
    wire clk_out_50;
    wire clk_out_62_5;
    wire clk_out_75;
    wire clk_out_87_5;

    wire [6:0] divided_clocks;
    integer errors;
    integer slot;
    integer high_slots;

    assign divided_clocks = {
        clk_out_87_5,
        clk_out_75,
        clk_out_62_5,
        clk_out_50,
        clk_out_37_5,
        clk_out_25,
        clk_out_12_5
    };

    divide_by_4 dut (
        .clk         (clk),
        .reset       (reset),
        .clk_out_12_5(clk_out_12_5),
        .clk_out_25  (clk_out_25),
        .clk_out_37_5(clk_out_37_5),
        .clk_out_50  (clk_out_50),
        .clk_out_62_5(clk_out_62_5),
        .clk_out_75  (clk_out_75),
        .clk_out_87_5(clk_out_87_5)
    );

    always #5 clk = ~clk;

    initial begin
        $timeformat(-9, 0, " ns", 8);
`ifdef __ICARUS__
        $dumpfile("divide_by_4.vcd");
        $dumpvars(0, clk, reset,
                     clk_out_12_5, clk_out_25, clk_out_37_5,
                     clk_out_50, clk_out_62_5, clk_out_75,
                     clk_out_87_5);
`endif

        clk    = 1'b0;
        reset  = 1'b1;
        errors = 0;

        repeat (2) @(negedge clk);
        #1;
        if (divided_clocks !== 7'b0000000) begin
            $display("ERROR /4 at %0t: outputs are not LOW during reset", $time);
            errors = errors + 1;
        end

        reset = 1'b0;

        // Observe and check two complete divide-by-4 periods.
        for (slot = 0; slot < 16; slot = slot + 1) begin
            @(clk);
            #1;
            for (high_slots = 1; high_slots <= 7;
                 high_slots = high_slots + 1) begin
                if (divided_clocks[high_slots - 1] !==
                    ((slot % 8) < high_slots)) begin
                    $display("ERROR /4 at %0t: high_slots=%0d slot=%0d expected=%0d got=%0b",
                             $time, high_slots, slot,
                             ((slot % 8) < high_slots),
                             divided_clocks[high_slots - 1]);
                    errors = errors + 1;
                end
            end
        end

        if (errors == 0)
            $display("PASS: divide-by-4 generated all seven duty-cycle waveforms");
        else
            $fatal(1, "FAIL: divide-by-4 produced %0d errors", errors);

        $finish;
    end

endmodule
