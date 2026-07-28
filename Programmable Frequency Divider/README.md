# Programmable Frequency Divider — Project Plan

[Back to Revision Atlas](../README.md) | [Frequency-divider theory](../Frequency%20Dividers/README.md)

> **Status:** Plan only. No code or subdirectories yet.

## Goal

Build one configurable Verilog frequency divider covering:

- divide-by-2, `/3`, `/4`, and `/5`;
- all duty cycles listed below;
- one RTL file and one testbench file; and
- simulation followed by Vivado synthesis.

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
|   `-- programmable_frequency_divider.v
`-- sim/
    `-- programmable_frequency_divider_tb.v
```

There will not be separate files or folders for every divide value or duty cycle.

## Main TODO

| Order | What we will do | Status |
|---:|---|:---:|
| 1 | Create `src/` and `sim/` with one file in each | TODO |
| 2 | Implement `/2` with 50% duty cycle | TODO |
| 3 | Make the same RTL configurable for `/2` through `/5` | TODO |
| 4 | Add all rising-edge duty cycles from the table | TODO |
| 5 | Write the self-checking testbench | TODO |
| 6 | Add `/3` and `/5` at 50% using the falling edge | TODO |
| 7 | Add the remaining half-cycle duty cycles | TODO |
| 8 | Simulate every supported configuration | TODO |
| 9 | Synthesize and inspect the design in Vivado | TODO |

## Later non-standard TODO

| Later target | Plan | Status |
|---|---|:---:|
| `/3` at 75% duty | External `4×` clock, modulo-12, nine HIGH and three LOW counts | Later |
| Fractional `/1.5` | Both-edge or faster-clock method | Later |
| Fractional `/2.5` | Both-edge or faster-clock method | Later |
| Other exact duty percentages | First determine the required timing resolution | Later |
| Live reconfiguration | Apply new settings only at a clean output-period boundary | Later |

## Not in the first version

- No divide value above 5.
- No fractional divider such as `/2.5`.
- No arbitrary duty cycle outside the listed cases.
- No 0% or 100% case because those are constant outputs.
- No live configuration changes; settings change only while reset is active.
- No separate RTL file for each divider or duty cycle.
- No separate FSM for each divider.
- No clock multiplier written in ordinary Verilog.
- No Verilog code inside this README.

## Checks for every configuration

- Correct divide ratio.
- Correct HIGH and LOW time.
- Correct duty cycle.
- Correct reset behavior.
- No missing, extra, or shortened pulse.
- Explicit testbench `PASS` with zero errors.

## First task

Complete Main TODO 1 and 2: create the two files and make `/2` with 50% duty cycle work.
