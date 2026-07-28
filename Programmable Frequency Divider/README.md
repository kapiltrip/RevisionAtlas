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

Special case:

- `/3` with 75% duty cycle will use an externally supplied `4×` clock, modulo-12 counting, nine HIGH counts, and three LOW counts.

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

## Work order

- [ ] Create `src/` and `sim/`.
- [ ] Implement `/2` with 50% duty cycle.
- [ ] Make the same RTL configurable for `/2` through `/5`.
- [ ] Add every rising-edge duty cycle from the table.
- [ ] Write a self-checking testbench for these cases.
- [ ] Add `/3` and `/5` with 50% duty cycle using the falling edge.
- [ ] Add the remaining half-cycle duty cycles from the table.
- [ ] Add the special `/3`, 75% experiment using an external `4×` clock.
- [ ] Simulate every supported configuration.
- [ ] Synthesize the final design in Vivado and inspect the generated hardware.

## What we are not doing

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

Create the two files and complete `/2` with 50% duty cycle before generalizing the design.
