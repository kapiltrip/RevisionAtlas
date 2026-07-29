`timescale 1ns/1ps

module divide_by_5_tb;

    reg  clk;
    reg  reset;
    wire clk_out_10;
    wire clk_out_20;
    wire clk_out_30;
    wire clk_out_40;
    wire clk_out_50;
    wire clk_out_60;
    wire clk_out_70;
    wire clk_out_80;
    wire clk_out_90;

    wire [8:0] divided_clocks;
    integer errors;
    integer slot;
    integer high_slots;

    assign divided_clocks = {
        clk_out_90,
        clk_out_80,
        clk_out_70,
        clk_out_60,
        clk_out_50,
        clk_out_40,
        clk_out_30,
        clk_out_20,
        clk_out_10
    };

    divide_by_5 dut (
        .clk       (clk),
        .reset     (reset),
        .clk_out_10(clk_out_10),
        .clk_out_20(clk_out_20),
        .clk_out_30(clk_out_30),
        .clk_out_40(clk_out_40),
        .clk_out_50(clk_out_50),
        .clk_out_60(clk_out_60),
        .clk_out_70(clk_out_70),
        .clk_out_80(clk_out_80),
        .clk_out_90(clk_out_90)
    );

    always #5 clk = ~clk;

    initial begin
        $timeformat(-9, 0, " ns", 8);
`ifdef __ICARUS__
        $dumpfile("divide_by_5.vcd");
        $dumpvars(0, clk, reset,
                     clk_out_10, clk_out_20, clk_out_30,
                     clk_out_40, clk_out_50, clk_out_60,
                     clk_out_70, clk_out_80, clk_out_90);
`endif

        clk    = 1'b0;
        reset  = 1'b1;
        errors = 0;

        repeat (2) @(negedge clk);
        #1;
        if (divided_clocks !== 9'b000000000) begin
            $display("ERROR /5 at %0t: outputs are not LOW during reset", $time);
            errors = errors + 1;
        end

        reset = 1'b0;

        // Observe and check two complete divide-by-5 periods.
        for (slot = 0; slot < 20; slot = slot + 1) begin
            @(clk);
            #1;
            for (high_slots = 1; high_slots <= 9;
                 high_slots = high_slots + 1) begin
                if (divided_clocks[high_slots - 1] !==
                    ((slot % 10) < high_slots)) begin
                    $display("ERROR /5 at %0t: duty=%0d%% slot=%0d expected=%0d got=%0b",
                             $time, high_slots * 10, slot,
                             ((slot % 10) < high_slots),
                             divided_clocks[high_slots - 1]);
                    errors = errors + 1;
                end
            end
        end

        if (errors == 0)
            $display("PASS: divide-by-5 generated all nine duty-cycle waveforms");
        else
            $fatal(1, "FAIL: divide-by-5 produced %0d errors", errors);

        $finish;
    end

endmodule
