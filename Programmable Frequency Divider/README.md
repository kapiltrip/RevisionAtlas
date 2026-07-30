# Frequency Divider RTL Practice — `/2` Through `/5`

[Back to Revision Atlas](../README.md) | [Frequency-divider theory](../Frequency%20Dividers/README.md)

> **Status:** The standalone `/2`, `/3`, `/4`, and `/5` dividers are complete. The agreed custom-duty and fractional-pulse cases are also implemented with simple parameterized RTL and self-checking testbenches. Vivado synthesis is next.

## Goal

Build easy-to-follow Verilog modules covering:

- divide-by-2, `/3`, `/4`, and `/5`;
- all normal duty cycles listed below;
- the agreed miscellaneous custom-duty cases;
- fractional pulse outputs `/1.5`, `/2.5`, `/3.5`, and `/4.5`; and
- simulation followed by Vivado synthesis.

The normal divide ratios remain separate modules. The miscellaneous cases use two small parameterized modules because the counter logic is the same for every listed case.

## Duty cycles covered

| Division | Using rising edges only | Using half-cycle transitions |
|---:|---|---|
| `/2` | 50% | 25%, 50%, 75% |
| `/3` | 33.33%, 66.67% | 16.67%, 33.33%, 50%, 66.67%, 83.33% |
| `/4` | 25%, 50%, 75% | 12.5%, 25%, 37.5%, 50%, 62.5%, 75%, 87.5% |
| `/5` | 20%, 40%, 60%, 80% | 10%, 20%, 30%, 40%, 50%, 60%, 70%, 80%, 90% |

`/2` and `/4` at 75% stay in the normal table. `/3` at 75% is implemented as a miscellaneous custom-duty case because it needs quarter-period resolution.

## File structure

```text
Programmable Frequency Divider/
|-- README.md
|-- src/
|   |-- divide_by_2.v
|   |-- divide_by_3.v
|   |-- divide_by_4.v
|   |-- divide_by_5.v
|   |-- custom_duty_divider.v
|   `-- fractional_pulse_divider.v
`-- sim/
    |-- divide_by_2_tb.v
    |-- divide_by_3_tb.v
    |-- divide_by_4_tb.v
    |-- divide_by_5_tb.v
    |-- custom_duty_divider_tb.v
    `-- fractional_pulse_divider_tb.v
```

## Normal divider outputs

| Module | Output ports generated together |
|---|---|
| `divide_by_2` | `clk_out_25`, `clk_out_50`, `clk_out_75` |
| `divide_by_3` | `clk_out_16_67`, `clk_out_33_33`, `clk_out_50`, `clk_out_66_67`, `clk_out_83_33` |
| `divide_by_4` | `clk_out_12_5`, `clk_out_25`, `clk_out_37_5`, `clk_out_50`, `clk_out_62_5`, `clk_out_75`, `clk_out_87_5` |
| `divide_by_5` | `clk_out_10`, `clk_out_20`, ..., `clk_out_90` |

## Editable EDA Playground references

Each divider has its own public playground using Icarus Verilog 12.0, a minimal clock/reset-only testbench, `dump.vcd`, and automatic EPWave opening.

| Divider | Duty-cycle waveforms included | Editable playground |
|---:|---|---|
| `/2` | 25%, 50%, 75% | [Open `/2` in EDA Playground](https://www.edaplayground.com/x/tAyC) |
| `/3` | 16.67%, 33.33%, 50%, 66.67%, 83.33% | [Open `/3` in EDA Playground](https://www.edaplayground.com/x/TQhD) |
| `/4` | 12.5%, 25%, 37.5%, 50%, 62.5%, 75%, 87.5% | [Open `/4` in EDA Playground](https://www.edaplayground.com/x/NYgj) |
| `/5` | 10%, 20%, 30%, 40%, 50%, 60%, 70%, 80%, 90% | [Open `/5` in EDA Playground](https://www.edaplayground.com/x/BpW_) |

## Miscellaneous RTL

| Module | Parameters | Input requirement |
|---|---|---|
| `custom_duty_divider` | `TOTAL_COUNTS`, `HIGH_COUNTS` | External `3x`, `4x`, or `5x` clock specified in the table below |
| `fractional_pulse_divider` | `TOTAL_COUNTS = 3, 5, 7, 9` | External `2x` clock |

Neither module creates a faster clock in Verilog. The required faster clock must already be available at the module input.

The fractional cases generate one-cycle pulse outputs, not 50% duty-cycle square-wave clocks.

## Why a clock divider still needs a testbench

For simply viewing a clock-divider waveform, a complex self-checking testbench is unnecessary. However, the simulation still needs a small testbench because the divider requires an input clock and reset:

- The **divider design** receives `clk` and `reset`, then generates the 25%, 50%, and 75% outputs.
- The **testbench** imitates the external clock and reset that real hardware would provide.
- **EPWave or GTKWave** only displays signal activity; it does not generate the input clock.

A signal merely declared as `reg clk;` does not change automatically. The following statement makes it oscillate during simulation:

```verilog
always #5 clk = ~clk;
```

In real hardware, an oscillator, PLL, or another clock source supplies this input clock. In simulation, the testbench must supply it. The testbench must also apply reset so the divider's internal state starts from known values instead of unknown `x` values.

The signal flow is:

```text
Testbench clock ---> divide_by_2 ---> 25% output
                                |--> 50% output
                                `--> 75% output
```

The divider creates all three divided outputs. The testbench does not construct or select them. A minimal waveform-viewing testbench is enough:

```verilog
`timescale 1ns/1ps

module divide_by_2_tb;

    reg clk = 0;
    reg reset = 1;

    wire clk_out_25;
    wire clk_out_50;
    wire clk_out_75;

    divide_by_2 dut (
        .clk(clk),
        .reset(reset),
        .clk_out_25(clk_out_25),
        .clk_out_50(clk_out_50),
        .clk_out_75(clk_out_75)
    );

    // Generate the input clock.
    always #5 clk = ~clk;

    initial begin
        // Record the signals for EPWave or GTKWave.
        $dumpfile("dump.vcd");
        $dumpvars(0, divide_by_2_tb);

        // Release reset, observe several periods, and stop.
        #12 reset = 0;
        #80 $finish;
    end

endmodule
```

This minimal testbench does only four jobs:

1. It creates the input clock.
2. It applies and releases reset.
3. It records the signals in a VCD file for the waveform viewer.
4. It stops the simulation after enough time has passed.

Self-checking code is optional. It is useful for automated regression tests because it prints `PASS` or `FAIL` without requiring visual inspection. For learning the divider and inspecting its timing manually, the minimal testbench above is sufficient.

## Main TODO

| Order | What we will do | Status |
|---:|---|:---:|
| 1 | Implement standalone `/2` with 25%, 50%, and 75% duty cycles | DONE |
| 2 | Implement standalone `/3` with all five listed duty cycles | DONE |
| 3 | Implement standalone `/4` with all seven listed duty cycles | DONE |
| 4 | Implement standalone `/5` with all nine listed duty cycles | DONE |
| 5 | Create one clock/reset-only self-checking testbench per normal divider | DONE |
| 6 | Simulate every normal configuration with Icarus Verilog | DONE |
| 7 | Implement and test all agreed custom-duty cases | DONE |
| 8 | Implement and test `/1.5`, `/2.5`, `/3.5`, and `/4.5` pulse outputs | DONE |
| 9 | Synthesize and inspect each design in Vivado | NEXT |

## Miscellaneous cases completed

| Type | Target | Implemented counts | Status |
|---|---|---|:---:|
| Custom duty | `/2` at 33.33% | `3x` clock, modulo-6, two HIGH counts | DONE |
| Custom duty | `/2` at 60% | `5x` clock, modulo-10, six HIGH counts | DONE |
| Custom duty | `/3` at 25% | `4x` clock, modulo-12, three HIGH counts | DONE |
| Custom duty | `/3` at 40% | `5x` clock, modulo-15, six HIGH counts | DONE |
| Custom duty | `/3` at 75% | `4x` clock, modulo-12, nine HIGH counts | DONE |
| Custom duty | `/4` at 33.33% | `3x` clock, modulo-12, four HIGH counts | DONE |
| Custom duty | `/4` at 80% | `5x` clock, modulo-20, sixteen HIGH counts | DONE |
| Custom duty | `/5` at 25% | `4x` clock, modulo-20, five HIGH counts | DONE |
| Custom duty | `/5` at 33.33% | `3x` clock, modulo-15, five HIGH counts | DONE |
| Custom duty | `/5` at 75% | `4x` clock, modulo-20, fifteen HIGH counts | DONE |
| Fractional pulse | `/1.5` | `2x` clock and modulo-3 | DONE |
| Fractional pulse | `/2.5` | `2x` clock and modulo-5 | DONE |
| Fractional pulse | `/3.5` | `2x` clock and modulo-7 | DONE |
| Fractional pulse | `/4.5` | `2x` clock and modulo-9 | DONE |

## Still later

| Feature | Plan | Status |
|---|---|:---:|
| Other exact custom duty cycle | Calculate its required clock resolution and HIGH/total counts first | Later |
| Live reconfiguration | Apply new settings only at a clean output-period boundary | Later |

## Not included

- No 0% or 100% case because those are constant outputs.
- No live configuration changes.
- No combined programmable top-level joining `/2` through `/5`.
- No separate RTL file for every individual duty cycle.
- No clock multiplier written in ordinary Verilog.

## Checks for every configuration

- Correct divide ratio or fractional pulse rate.
- Correct HIGH and LOW time.
- Correct duty cycle.
- Correct reset behavior.
- No missing, extra, or shortened pulse.
- Explicit testbench `PASS` with zero errors.

## Next task

Synthesize the four normal divider modules and the two miscellaneous parameterized modules in Vivado, one top module at a time.
