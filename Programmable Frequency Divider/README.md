# Programmable Frequency Divider — Subject Plan

[Back to Revision Atlas](../README.md) | [Frequency-divider theory](../Frequency%20Dividers/README.md)

**Current status:** planning only. No RTL has been written yet.

## Project goal

Build one reusable, synchronous Verilog divider that can be configured for:

- an integer frequency-division ratio $N$;
- a chosen number of HIGH input-clock cycles $H$;
- a continuous output waveform;
- a one-cycle `tick_out` pulse every $N$ input clocks; and
- safe run-time configuration changes without producing a shortened or stretched partial cycle.

The baseline relationship will be

$$
f_{out}=\frac{f_{in}}{N},
$$

with duty cycle

$$
\mathcal D=\frac{H}{N}\times100\%.
$$

Here, $N$ is the number of input-clock periods in one complete output period, and $H$ is the number of those periods for which the output is HIGH.

## What “fully customizable” can mean in synchronous digital logic

The first version will support any **integer** $N\ge2$ that fits within the selected counter width. The HIGH duration must also be an integer number of input-clock periods:

$$
1\le H\le N-1.
$$

Therefore, the possible duty cycles are quantized in steps of

$$
\frac{100\%}{N}.
$$

Examples:

| Configuration | Result |
|---|---|
| $N=10$, $H=5$ | divide-by-10, 50% duty cycle |
| $N=10$, $H=3$ | divide-by-10, 30% duty cycle |
| $N=8$, $H=1$ | divide-by-8, 12.5% duty cycle |
| $N=7$, $H=3$ | divide-by-7, about 42.86% duty cycle |

An exact 50% duty cycle is not possible for an odd $N$ when output transitions are allowed only on rising edges of the input clock. For example, divide-by-7 would need $H=3.5$ clocks. A later extension can use half-cycle edge placement or a dedicated FPGA clocking primitive for such cases.

Values $H=0$ and $H=N$ would produce constant LOW and constant HIGH respectively. Those are useful output modes in some systems, but they are not divided clocks because they have no repeating edges. The baseline divider will treat them as invalid configurations.

## Planned interface

The exact port widths will be chosen during implementation, but the intended interface is:

| Signal | Direction | Purpose |
|---|---|---|
| `clk` | input | Original reference clock; all state changes use this clock |
| `reset` | input | Return the divider to a known idle state |
| `enable` | input | Run or pause the divider |
| `config_load` | input | Request a new divider configuration |
| `divide_value` | input | Requested period length $N$ |
| `high_cycles` | input | Requested HIGH duration $H$ |
| `clk_out` | output | Continuous divided waveform |
| `tick_out` | output | One-input-cycle pulse at the end of each divided period |
| `config_valid` | output | Indicates whether the requested values are legal |

The module will receive $N$ and $H$ directly instead of receiving a percentage. This avoids rounding hardware and makes the generated timing exact and easy to verify. Software or a wrapper can convert a requested percentage $D$ into a cycle count using

$$
H\approx\operatorname{round}\left(\frac{D}{100}N\right).
$$

## Planned baseline architecture

1. A synchronous counter advances from $0$ through $N-1$.
2. `clk_out` is HIGH for the first $H$ states and LOW for the remaining $N-H$ states.
3. The counter returns to zero after state $N-1$.
4. `tick_out` pulses for one input-clock cycle at the period boundary.
5. New settings are first stored in pending configuration registers.
6. Pending settings become active only at a clean period boundary, preventing an in-progress period from being corrupted.
7. Illegal settings are rejected and reported through `config_valid` rather than being allowed to produce unpredictable timing.

This is a **synchronous divider**: every register continues to use the original `clk`. It will not form a ripple counter by using one logic output as another register's clock.

## Project stages

### Stage 1 — Freeze the specification

- Choose the maximum counter width and reset behavior.
- Decide exactly how `enable` pauses and resumes a partial period.
- Define whether a rejected configuration leaves the old configuration active.
- Write timing tables for representative values of $N$ and $H$.

### Stage 2 — Implement the integer divider core

- Add the counter and active configuration registers.
- Generate both `clk_out` and `tick_out`.
- Support even and odd integer divide values.
- Keep all sequential logic on one edge of the original clock.

### Stage 3 — Add safe run-time reconfiguration

- Capture new values when `config_load` is asserted.
- Validate $N\ge2$ and $1\le H<N$.
- Apply valid pending values at a complete-period boundary.
- Prove that configuration changes do not create runt or extra pulses.

### Stage 4 — Build a self-checking testbench

The testbench will automatically check:

- divide values such as 2, 3, 5, 8, 10, and the maximum supported value;
- minimum, middle, and maximum legal HIGH times;
- actual input edges per output period;
- actual HIGH cycles per period;
- reset and enable behavior;
- run-time changes of both $N$ and $H$; and
- rejection of $N<2$, $H=0$, and $H\ge N$.

The testbench will end with an explicit `PASS` or `FAIL`, rather than relying only on visual waveform inspection.

### Stage 5 — Vivado verification

- Compile and elaborate the RTL without errors.
- Run the self-checking behavioral simulation.
- Save a clean waveform containing only the clock, configuration, counter, `clk_out`, and `tick_out` signals.
- Document what each waveform interval proves.

### Stage 6 — Optional advanced divider family

These features should be separate extensions rather than hidden inside the simple baseline module:

| Extension | Why it needs separate treatment |
|---|---|
| Exact 50% duty for odd integer $N$ | Requires half-cycle edge placement or a suitable dedicated clocking resource |
| Fractional division such as 2.5 | Requires alternating periods, an accumulator, or clock-management hardware; individual cycles may jitter |
| Percentage input such as 37% | Requires a defined rounding rule because $DN/100$ may not be an integer |
| FPGA internal generated clock | Must use suitable clock routing and timing constraints; a clock-enable is often safer |
| Multiple output channels | Requires shared-counter or independent-channel architecture and resource analysis |

## Planned repository layout

Only this README exists now. Later stages are expected to add:

```text
Programmable Frequency Divider/
|-- README.md
|-- src/
|   `-- programmable_frequency_divider.v
|-- sim/
|   `-- programmable_frequency_divider_tb.v
`-- vivado/
    `-- programmable_frequency_divider_vivado/
```

## Completion criteria

The project will be considered complete when:

- the legal range of $N$ and $H$ is unambiguous;
- every legal tested pair produces a period of exactly $N$ input clocks;
- every legal tested pair remains HIGH for exactly $H$ input clocks;
- invalid configurations are handled deterministically;
- run-time configuration changes occur without partial output pulses;
- the testbench reports zero errors;
- Vivado compilation and elaboration have no design errors; and
- the README explains the limits of integer, odd, fractional, and generated-clock division.

## First implementation decision

Start with the rising-edge, integer divider using direct values $N$ and $H$. It gives a clean foundation that covers the most useful customizable cases. Exact odd-ratio 50% duty and fractional division should then be added as clearly named extensions, because their timing behavior and FPGA implementation rules are different.
