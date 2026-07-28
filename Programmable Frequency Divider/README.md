# Programmable Frequency Divider — `/2` to `/5` Project Plan

[Back to Revision Atlas](../README.md) | [Frequency-divider theory and worked derivations](../Frequency%20Dividers/README.md)

> **Current status:** planning only. No RTL, testbench, Vivado project, or empty subdirectory is being added yet.

## Decision

Build one small learning project that covers divide-by-2 through divide-by-5 and systematically answers:

1. Which duty cycles are possible when output transitions occur only on input rising edges?
2. What additional duty cycles become possible when half-cycle timing is deliberately available?
3. Why do targets such as divide-by-3 with 75% duty need finer timing resolution?
4. Which parts are ordinary counter RTL, which need opposite-edge logic, and which need a PLL/MMCM or another dedicated clocking resource?

The first implementation will remain simple:

- one reusable Verilog design file;
- one self-checking testbench file;
- no separate RTL file for each divide ratio or duty cycle;
- no explicit state-by-state FSM unless a counter cannot express the required behavior; and
- no live reconfiguration in the first version.

The design will be configured while reset is active and will start from a known phase when reset is released. Glitch-free run-time reconfiguration can be a later extension after the divider itself is correct.

## Exact project scope

### Included

- Integer division ratios \(N=2,3,4,5\).
- Every nonconstant duty cycle available on a full-input-cycle grid.
- Every nonconstant duty cycle available on a half-input-cycle grid.
- Exact odd-divider 50% cases, especially `/3` and `/5`.
- One finer-resolution proof case: `/3` with 75% duty.
- A self-checking simulation that measures frequency, period, HIGH time, LOW time, and duty cycle.
- Vivado synthesis review and a clear distinction between a waveform output, a clock-enable pulse, and a clock that drives other registers.

### Deliberately deferred

- Divide ratios above 5.
- Fractional division such as `/2.5`.
- Arbitrary requested percentages with rounding.
- Glitch-free configuration changes while the divider is running.
- Multiple simultaneous outputs.
- Jitter-clean clock synthesis.
- Trying to create a clock multiplier from ordinary Verilog logic.

These are separate design problems. Adding them now would hide the basic divider and duty-cycle reasoning.

## The timing-grid model

This plan assumes a clock-like rectangular output with one contiguous HIGH interval and one contiguous LOW interval in each output period.

For divide by \(N\),

$$
f_{out}=\frac{f_{in}}{N},
\qquad
T_{out}=N T_{in}.
$$

Let \(R\) be the number of usable, equally spaced timing slots inside one input period:

| Resolution \(R\) | Smallest transition step | Typical source |
|---:|---:|---|
| 1 | \(T_{in}\) | Rising edges only |
| 2 | \(T_{in}/2\) | Rising and falling edges of an ideal 50% input, or an equivalent dedicated resource |
| \(R>2\) | \(T_{in}/R\) | PLL/MMCM multiplication or controlled phase generation |

One output period contains

$$
K=NR
$$

timing slots. If the output remains HIGH for an integer number \(H\) of those slots, then

$$
\boxed{\mathcal D=\frac{H}{NR}\times100\%},
\qquad
H=1,2,\ldots,NR-1.
$$

The endpoints \(H=0\) and \(H=NR\) produce constant LOW and constant HIGH. They are not divided clocks because they do not repeat edges.

### Quick exact-achievability test

Write a requested duty cycle in lowest terms as

$$
\mathcal D=\frac{a}{b}.
$$

The target is exact only if

$$
\boxed{H=NR\frac{a}{b}}
$$

is an integer. Equivalently, \(b\) must divide \(NR\). The smallest mathematical timing resolution that can represent the target is

$$
\boxed{R_{\min}=\frac{b}{\gcd(b,N)}}.
$$

Here, \(\gcd(b,N)\) is the greatest common divisor of \(b\) and \(N\). This formula finds the required edge-placement grid; it does not create that grid in hardware.

For `/3` with 75% duty,

$$
N=3,\qquad \mathcal D=\frac34,\qquad
R_{\min}=\frac{4}{\gcd(4,3)}=4.
$$

Therefore, one output period needs \(3\times4=12\) quarter-period slots: nine HIGH and three LOW. Rising edges alone give only \(R=1\), and both original-clock edges give only \(R=2\), so neither can produce exact 75%.

## Complete duty-cycle inventory for `/2` through `/5`

The table lists every nonconstant duty cycle available on the two timing grids included in the main project.

| Division | Rising-edge grid, \(R=1\) | Half-cycle grid, \(R=2\) |
|---:|---|---|
| `/2` | \(1/2=50\%\) | \(1/4=25\%\), \(2/4=50\%\), \(3/4=75\%\) |
| `/3` | \(1/3=33.33\%\), \(2/3=66.67\%\) | \(1/6=16.67\%\), \(2/6=33.33\%\), \(3/6=50\%\), \(4/6=66.67\%\), \(5/6=83.33\%\) |
| `/4` | \(1/4=25\%\), \(2/4=50\%\), \(3/4=75\%\) | \(1/8=12.5\%\), \(2/8=25\%\), \(3/8=37.5\%\), \(4/8=50\%\), \(5/8=62.5\%\), \(6/8=75\%\), \(7/8=87.5\%\) |
| `/5` | \(1/5=20\%\), \(2/5=40\%\), \(3/5=60\%\), \(4/5=80\%\) | \(1/10=10\%\), \(2/10=20\%\), \(3/10=30\%\), \(4/10=40\%\), \(5/10=50\%\), \(6/10=60\%\), \(7/10=70\%\), \(8/10=80\%\), \(9/10=90\%\) |

Important consequences:

- The rising-edge core has exactly \(1+2+3+4=10\) legal `/2`–`/5` configurations.
- The half-cycle grid has exactly \(3+5+7+9=24\) legal configurations.
- If duty cycle \(D\) is possible, its complement \(100\%-D\) is also possible by inverting the waveform; the frequency does not change.
- Even division ratios naturally contain a 50% whole-cycle split.
- Odd `/3` and `/5` need a half-cycle transition for exact 50%.
- `/3` at 75% is not in the \(R=1\) or \(R=2\) list. It needs \(R=4\).

The whole-cycle and half-cycle conclusions agree with real clocking implementations: AMD documents unequal HIGH and LOW counts for odd `BUFGCE_DIV` ratios, while Altera documents use of a falling-edge transition to obtain a 50% odd divide. Texas Instruments also lists `/3` as 33% and `/5` as 40% in a practical divider.

## Architecture plan

### Track A — Portable rising-edge counter core

This is the first implementation and the only part that should be generalized immediately.

Conceptually, it will:

1. accept a divide value \(N\) from 2 through 5;
2. accept a whole-cycle HIGH count \(H\) from 1 through \(N-1\);
3. count synchronously through one \(N\)-cycle output period;
4. keep the output HIGH for \(H\) counts and LOW for \(N-H\) counts; and
5. reject illegal combinations.

This is counter-and-decode logic. Four separate divider modules and a large enumerated FSM are unnecessary.

### Track B — Half-cycle extension

This track begins only after all 10 Track A configurations pass.

The first targets are:

- `/3`, 50%: HIGH for \(1.5T_{in}\), LOW for \(1.5T_{in}\);
- `/5`, 50%: HIGH for \(2.5T_{in}\), LOW for \(2.5T_{in}\).

A falling-edge flip-flop can provide a half-cycle-shifted component for these standard odd-divider corrections. It is clocked by the same root clock; it delays by half a cycle and does not independently perform divide-by-2.

However, one falling-edge flip-flop plus an OR gate is not a universal implementation for all 24 half-cycle configurations. Before claiming complete \(R=2\) support, choose and verify one deliberate architecture:

- coordinated positive-edge and negative-edge logic for a waveform that will not clock internal fabric;
- a dedicated DDR output primitive for a waveform leaving the FPGA; or
- a dedicated \(2f_{in}\) clock followed by an ordinary single-edge slot counter.

Do not update one ordinary fabric register from both edges and call it portable synthesizable RTL.

### Track C — Finer-resolution experiment

Use `/3`, 75% as the boundary case:

1. prove that \(R=1\) requires \(H=2.25\), which is not an integer;
2. prove that \(R=2\) requires \(H=4.5\), which is still not an integer;
3. compute \(R_{\min}=4\);
4. provide an externally generated quarter-period grid;
5. count 12 slots per output period; and
6. verify nine HIGH slots and three LOW slots.

The divider logic may consume a \(4f_{in}\) clock, but ordinary RTL will not create that multiplied clock. On an FPGA, a PLL/MMCM or Clocking Wizard configuration supplies the required frequency or phase grid.

## Coding and folder decision

Do not create a subdirectory for `/2`, `/3`, `/4`, every duty cycle, or every milestone. That would duplicate nearly identical code and make the project harder to revise.

When coding begins, use:

```text
Programmable Frequency Divider/
|-- README.md
|-- src/
|   `-- programmable_frequency_divider.v
|-- sim/
|   `-- programmable_frequency_divider_tb.v
`-- evidence/
    |-- waveforms/
    `-- synthesis/
```

Stay with one RTL file and one testbench file while the design is small. A `vivado/` directory should be added only if Track B or Track C introduces device-specific ODDR, PLL/MMCM, constraints, or reproducible tool scripts. Vendor-generated files should not be mixed into the portable counter core.

Git does not preserve empty directories without placeholder files, so creating all folders before they contain work adds noise. For now, only this README should exist.

## Planned first-version configuration

Keep the first interface small:

| Configuration or signal | First-version rule |
|---|---|
| Input clock | One root clock for the portable \(R=1\) core |
| Reset | Returns the counter and output phase to a known state |
| Divide value \(N\) | Legal values are 2, 3, 4, and 5 |
| HIGH count \(H\) | Legal values are \(1\) through \(N-1\) |
| Output | A divided waveform for measurement and learning |
| Configuration validity | Illegal \(N,H\) pairs must be reported or forced to a documented safe state |

For Version 1, change \(N\) and \(H\) only while reset is active. Do not add `enable`, a percentage input, a run-time load handshake, or a second output until the baseline matrix passes.

## Actionable build sequence

| Milestone | Work | Pass condition | Suggested effort |
|---:|---|---|---:|
| 0 — Plan | Freeze the scope, equations, duty-cycle matrix, architecture tracks, and folders in this README | No unresolved meaning of \(N\), \(R\), or \(H\) | Complete |
| 1 — Fixed `/2` | Create `src/` and `sim/`; make `/2`, 50% work first | Period is exactly \(2T_{in}\); HIGH and LOW are each \(T_{in}\) | One focused session |
| 2 — General \(R=1\) core | Replace the fixed case with configurable \(N\) and \(H\) | All 10 whole-cycle configurations pass | One to two sessions |
| 3 — Self-checking verification | Measure edges and durations automatically; test reset and illegal settings | Testbench ends with zero errors and an explicit `PASS` | One session |
| 4 — Odd 50% correction | Add `/3` and `/5` 50% using a deliberate half-cycle method | HIGH and LOW are \(1.5T_{in}\) for `/3` and \(2.5T_{in}\) for `/5` | One to two sessions |
| 5 — Complete \(R=2\) study | Choose a synthesizable/platform-appropriate half-cycle architecture and cover the 24-case table | Every advertised half-cycle case is measured; no runt or extra pulse | Two sessions |
| 6 — `/3`, 75% proof | Add the externally supplied \(R=4\) experiment | 12 slots per period, nine HIGH, three LOW, output remains \(f_{in}/3\) | One session |
| 7 — Vivado review | Synthesize, inspect inferred logic and clocking, save only useful evidence | No unexplained clock warning; hardware use matches the declared output purpose | One session |

Do not start Milestone 4 before Milestones 1–3 pass. Otherwise, a basic counter error and an edge-placement error become mixed together.

## Verification contract

For each legal configuration, the testbench must observe at least three complete output periods and check:

$$
T_{out}=N T_{in},
$$

$$
T_{HIGH}=H\frac{T_{in}}{R},
$$

$$
T_{LOW}=(NR-H)\frac{T_{in}}{R},
$$

and

$$
\mathcal D=\frac{H}{NR}\times100\%.
$$

It must also check:

- deterministic reset phase;
- no missing or extra output transition;
- no zero-time or shortened pulse;
- all 10 \(R=1\) configurations;
- all 24 \(R=2\) configurations only after a valid Track B architecture exists;
- rejection of \(N<2\), \(N>5\), \(H=0\), and \(H\ge NR\); and
- `/3`, 75% is rejected at \(R=1\) and \(R=2\), then passes only in the \(R=4\) experiment.

Waveforms are supporting evidence, not the main checker. The testbench must decide `PASS` or `FAIL`.

## FPGA reality check

During simulation, `clk_out` can be treated as the waveform under study. On real FPGA hardware, decide what the output actually does:

| Intended use | Preferred implementation direction |
|---|---|
| Slow action inside existing synchronous logic | Keep the original clock and generate a clock-enable pulse |
| Waveform sent to an output pin | Use an appropriate output/DDR resource when both-edge timing is needed |
| Clock that drives internal registers | Use a dedicated clocking resource and apply the required generated-clock constraints |

AMD warns that a counter implemented in fabric can create a local clock with unpredictable skew and difficult timing closure. Therefore, a logically correct simulation waveform is not automatically a safe internal FPGA clock.

## Completion criteria

The project is complete only when:

- the README and implementation use the same definitions of \(N\), \(R\), and \(H\);
- the 10 rising-edge configurations pass automatically;
- every claimed half-cycle configuration has a deliberate, valid architecture;
- odd `/3` and `/5` 50% waveforms are measured correctly;
- `/3`, 75% is correctly identified as an \(R=4\) case;
- invalid configurations have deterministic behavior;
- reset starts every waveform from a documented phase;
- the testbench reports zero errors;
- the synthesized hardware structure is inspected rather than assumed; and
- the output is not used as an internal FPGA clock without an appropriate clocking resource and timing constraints.

## First action when implementation starts

Create only `src/` and `sim/`. Implement `/2`, 50% in the single source file, and write its period/HIGH/LOW checker in the single testbench. Generalize to `/3`, `/4`, and `/5` only after that smallest case passes.

Do not begin with `/3`, 75%, a PLL, live reconfiguration, or one file per duty cycle.

## Research basis

The plan was checked against vendor documentation and the detailed derivations in the related [Frequency Dividers chapter](../Frequency%20Dividers/README.md):

- [AMD `BUFGCE_DIV` documentation](https://docs.amd.com/r/en-US/ug572-ultrascale-clocking/BUFGCE_DIV) — integer division and the unequal HIGH/LOW count produced by odd divide values.
- [Altera MAX 10 PLL post-scale counters](https://docs.altera.com/r/docs/683047/21.1/max-10-clocking-and-pll-user-guide/post-scale-counters-c0-to-c4) — duty cycle as HIGH count divided by total HIGH-plus-LOW counts, and falling-edge correction for a 50% odd divide.
- [Texas Instruments LMX1204 datasheet, Table 6-4](https://www.ti.com/lit/ds/symlink/lmx1204.pdf) — practical `/2` through `/5` divider duty-cycle examples.
- [AMD PLL attributes](https://docs.amd.com/r/en-US/ug572-ultrascale-clocking/PLL-Attributes) — clock multiplication, division, phase, and duty-cycle controls supplied by dedicated hardware.
- [AMD Clocking Wizard](https://docs.amd.com/r/en-US/pg065-clk-wiz/Configuring-Output-Clocks) — requested frequency, phase, and duty cycle may not all be exactly realizable, so the achieved values must be checked.
- [AMD guidance on avoiding local clocks](https://docs.amd.com/r/en-US/ug949-vivado-design-methodology/Avoiding-Local-Clocks) — why a fabric-generated waveform should not automatically be used as an internal FPGA clock.
