# Frequency Divider RTL Practice — `/2` Through `/5`

[Back to Revision Atlas](../README.md) | [Frequency-divider theory](../Frequency%20Dividers/README.md)

> **Status:** Separate `/2`, `/3`, `/4`, and `/5` RTL modules generate every supported duty-cycle waveform directly. Their clock/reset-only testbenches verify all outputs and write VCD waveform files when run with Icarus Verilog. Vivado synthesis is next.

## Goal

Build the divider ratios as separate, easy-to-follow Verilog modules covering:

- divide-by-2, `/3`, `/4`, and `/5`;
- all duty cycles listed below;
- one RTL file and one testbench for each divide ratio; and
- simulation followed by Vivado synthesis.

The divide ratios are intentionally **not mixed into one programmable top-level module**. Each file contains one counter sequence and exposes every duty-cycle waveform belonging to that ratio as a separate output.

## Duty cycles to cover

| Division | Using rising edges only | Using half-cycle transitions |
|---:|---|---|
| `/2` | 50% | 25%, 50%, 75% |
| `/3` | 33.33%, 66.67% | 16.67%, 33.33%, 50%, 66.67%, 83.33% |
| `/4` | 25%, 50%, 75% | 12.5%, 25%, 37.5%, 50%, 62.5%, 75%, 87.5% |
| `/5` | 20%, 40%, 60%, 80% | 10%, 20%, 30%, 40%, 50%, 60%, 70%, 80%, 90% |

`/2` and `/4` at 75% stay in the normal table. Only `/3` at 75% is kept as a later special case.

## File structure

```text
Programmable Frequency Divider/
|-- README.md
|-- src/
|   |-- divide_by_2.v
|   |-- divide_by_3.v
|   |-- divide_by_4.v
|   `-- divide_by_5.v
`-- sim/
    |-- divide_by_2_tb.v
    |-- divide_by_3_tb.v
    |-- divide_by_4_tb.v
    `-- divide_by_5_tb.v
```

There is a separate file for every divide value, but not a separate file for every duty cycle. Each RTL module needs only `clk` and `reset`; it continuously generates all of its valid duty-cycle outputs in parallel. The testbench does not select or construct a duty-cycle waveform.

## Generated waveform outputs

| Module | Output ports generated together |
|---|---|
| `divide_by_2` | `clk_out_25`, `clk_out_50`, `clk_out_75` |
| `divide_by_3` | `clk_out_16_67`, `clk_out_33_33`, `clk_out_50`, `clk_out_66_67`, `clk_out_83_33` |
| `divide_by_4` | `clk_out_12_5`, `clk_out_25`, `clk_out_37_5`, `clk_out_50`, `clk_out_62_5`, `clk_out_75`, `clk_out_87_5` |
| `divide_by_5` | `clk_out_10`, `clk_out_20`, ..., `clk_out_90` |

The Icarus runs create `divide_by_2.vcd` through `divide_by_5.vcd`. Open these in GTKWave to see the reference clock, reset, and every generated output together.

## Main TODO

| Order | What we will do | Status |
|---:|---|:---:|
| 1 | Implement standalone `/2` with 25%, 50%, and 75% duty cycles | DONE |
| 2 | Implement standalone `/3` with all five listed duty cycles | DONE |
| 3 | Implement standalone `/4` with all seven listed duty cycles | DONE |
| 4 | Implement standalone `/5` with all nine listed duty cycles | DONE |
| 5 | Create one clock/reset-only self-checking testbench per divider | DONE |
| 6 | Simulate every supported configuration with Icarus Verilog | DONE |
| 7 | Synthesize and inspect each standalone design in Vivado | NEXT |

## Later non-standard TODO

| Type | Target | Example plan | Status |
|---|---|---|:---:|
| Custom duty | `/2` at 33.33% | `3×` clock, modulo-6, two HIGH and four LOW counts | Later |
| Custom duty | `/2` at 60% | `5×` clock, modulo-10, six HIGH and four LOW counts | Later |
| Custom duty | `/3` at 25% | `4×` clock, modulo-12, three HIGH and nine LOW counts | Later |
| Custom duty | `/3` at 40% | `5×` clock, modulo-15, six HIGH and nine LOW counts | Later |
| Custom duty | `/3` at 75% | `4×` clock, modulo-12, nine HIGH and three LOW counts | Later |
| Custom duty | `/4` at 33.33% | `3×` clock, modulo-12, four HIGH and eight LOW counts | Later |
| Custom duty | `/4` at 80% | `5×` clock, modulo-20, sixteen HIGH and four LOW counts | Later |
| Custom duty | `/5` at 25% | `4×` clock, modulo-20, five HIGH and fifteen LOW counts | Later |
| Custom duty | `/5` at 33.33% | `3×` clock, modulo-15, five HIGH and ten LOW counts | Later |
| Custom duty | `/5` at 75% | `4×` clock, modulo-20, fifteen HIGH and five LOW counts | Later |
| Fractional output pulse | `/1.5` | Count both-edge events with modulo-3 | Later |
| Fractional output pulse | `/2.5` | Count both-edge events with modulo-5 | Later |
| Fractional output pulse | `/3.5` | Count both-edge events with modulo-7 | Later |
| Fractional output pulse | `/4.5` | Count both-edge events with modulo-9 | Later |
| Other custom case | Any other exact duty cycle | Calculate the required clock resolution and counts first | Later |
| Feature | Live reconfiguration | Apply settings at a clean output-period boundary | Later |

## Not in the first version

- No divide value above 5.
- No fractional divider such as `/2.5`.
- No later custom-duty or fractional case from the table above.
- No 0% or 100% case because those are constant outputs.
- No live configuration changes; settings change only while reset is active.
- No combined programmable top-level joining `/2` through `/5`.
- No separate RTL file for every individual duty cycle.
- No clock multiplier written in ordinary Verilog.
- No Verilog code inside this README.

## Checks for every configuration

- Correct divide ratio.
- Correct HIGH and LOW time.
- Correct duty cycle.
- Correct reset behavior.
- No missing, extra, or shortened pulse.
- Explicit testbench `PASS` with zero errors.

## Next task

Synthesize the four standalone modules in Vivado, one top module at a time, and inspect inferred counters, opposite-edge registers, timing, and warnings.
