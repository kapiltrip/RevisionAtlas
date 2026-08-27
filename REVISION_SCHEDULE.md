# Six-Week Revision Schedule

[Revision method](_internal/repository/guides/REVISION_METHOD.md) |
[Review queue](_internal/repository/tracking/README.md) |
[Repository index](README.md)

This schedule starts on **Friday, 28 August 2026**. It gives the largest
subjects more than one session, keeps one recovery day each week, and finishes
with mixed tests instead of another reading pass. If the start date slips,
keep the order and move every date together.

## The daily contract

Use **75 minutes** on normal days:

1. **Due reviews - 15 minutes:** test due `M`, then `H`, then `R` items without
   opening the notes.
2. **Primary focus - 40 minutes:** retrieve the scheduled pages, diagrams,
   equations, or RTL behavior before repairing gaps from the notes.
3. **Application - 15 minutes:** solve, draw, trace, derive, or simulate the
   proof named in the schedule.
4. **Queue - 5 minutes:** mark each weak item `R`, `H`, or `M` and assign its
   next date.

On a crowded day, use the **25-minute minimum**: 10 minutes of due reviews, 10
minutes on the primary focus, and 5 minutes to produce one closed-book proof.
Never replace a missed day with zero contact.

## Scheduling rules

- `M` is reviewed tomorrow with a prerequisite repair and a second example.
- `H` is reviewed after three days with one contrast or "why" question.
- `R` is reviewed after seven days, then after 14 and 30 days.
- Due reviews come before the day's new topic, but stop them after 30 minutes.
- Use Sunday to recover one missed primary session. Do not move the whole
  calendar or create a catch-up marathon.
- After a second `M`, go back one prerequisite step instead of rereading the
  same explanation.
- A session counts only when it ends with visible evidence: a diagram,
  derivation, waveform, trace, answer, or passing simulation.

Record weak items in this form:

```text
Item: <term, page, equation, waveform, or invariant>
Subject: <subject>
Mark: R | H | M
Last reviewed: YYYY-MM-DD
Next due: YYYY-MM-DD
Repair action: define | derive | draw | solve | implement
```

## Week 1 - MOS foundations

| Date | Primary focus | Closed-book proof before stopping |
|---|---|---|
| Fri 28 Aug | [MOS capacitor fundamentals](MOSFET%20and%20CMOS/01%20MOS%20Capacitor%20Fundamentals/README.md), pages 1-12 | Draw accumulation, depletion, and inversion; explain the charge and band movement. |
| Sat 29 Aug | MOS capacitor fundamentals, pages 13-24 | Derive one capacitance or surface-potential relation with signs and units. |
| Sun 30 Aug | Due reviews and recovery only | Re-answer all `M` items; recover Saturday only if it was missed. |
| Mon 31 Aug | [Non-ideal MOS and MOSFET regions](MOSFET%20and%20CMOS/02%20Non-Ideal%20MOS%20and%20MOSFET%20Regions/README.md), pages 1-12 | Explain how work function and oxide charge move flat-band and threshold voltage. |
| Tue 1 Sep | Non-ideal MOS and MOSFET regions, pages 13-24 | Select cutoff, triode, or saturation for three bias points and justify each inequality. |
| Wed 2 Sep | [MOSFET models and CMOS inverter](MOSFET%20and%20CMOS/03%20MOSFET%20Models%20and%20CMOS%20Inverter/README.md), pages 1-12 | Rebuild the piecewise drain-current model and explain channel-length modulation. |
| Thu 3 Sep | MOSFET models and CMOS inverter, pages 13-24 | Derive the inverter switching point and check both transistor regions. |

## Week 2 - CMOS timing and STA

| Date | Primary focus | Closed-book proof before stopping |
|---|---|---|
| Fri 4 Sep | [CMOS switching, delay, power, and noise](MOSFET%20and%20CMOS/04%20CMOS%20Switching%20Delay%20Power%20and%20Noise/README.md), pages 1-12 | Sketch the inverter transfer curve and label gain, noise margins, and current regions. |
| Sat 5 Sep | CMOS switching, delay, power, and noise, pages 13-24 | Solve one delay or power problem and state every assumption. |
| Sun 6 Sep | Due reviews and recovery only | Give a five-minute MOS causal map without notes; repair the weakest link. |
| Mon 7 Sep | [CMOS sizing and NAND timing](MOSFET%20and%20CMOS/05%20CMOS%20Sizing%20and%20NAND%20Timing/README.md), pages 1-14 | Size one inverter or NAND path and explain the pull-up/pull-down resistance choice. |
| Tue 8 Sep | [Static timing analysis](Static%20Timing%20Analysis/README.md), pages 1-6 | Draw latch and flip-flop transparency; explain the physical origin of setup and hold. |
| Wed 9 Sep | Static timing analysis, pages 7-14 | Derive setup and hold constraints using separate arrival and required times. |
| Thu 10 Sep | Static timing analysis, pages 15-25 | Solve one skewed path and one maximum-frequency problem with min/max delays. |

## Week 3 - Serial protocols and dividers

| Date | Primary focus | Closed-book proof before stopping |
|---|---|---|
| Fri 11 Sep | Mixed MOS and STA test | Explain how device delay reaches setup slack, then solve one unseen timing path. |
| Sat 12 Sep | [I2C](Protocols/01%20I2C/README.md), pages 1-5 | Draw a controller read, including START, address, ACK/NACK ownership, and STOP. |
| Sun 13 Sep | Due reviews and recovery only | Redraw the weakest waveform or timing path without notes. |
| Mon 14 Sep | [SPI](Protocols/02%20SPI/README.md), pages 6-8, and [UART](Protocols/03%20UART/README.md), pages 9-12 | Draw all four SPI modes and one UART frame; identify every sampling event. |
| Tue 15 Sep | UART, pages 13-16 | Calculate a baud divider and trace transmitter/receiver state changes for one frame. |
| Wed 16 Sep | [Frequency dividers](Frequency%20Dividers/README.md), pages 1-6 | Derive `/2`, `/3`, and `/5` state sequences and their achievable duty cycles. |
| Thu 17 Sep | Frequency dividers, pages 7-13, and [RTL practice](Programmable%20Frequency%20Divider/README.md) | Draw one fractional-divider waveform and run or reason through one self-checking testbench. |

## Week 4 - AMBA foundations

| Date | Primary focus | Closed-book proof before stopping |
|---|---|---|
| Fri 18 Sep | [AHB](Protocols/04%20AMBA/01%20AHB/README.md): phases, `HTRANS`, bursts, and wait states | Draw back-to-back address/data phases with one inserted wait state. |
| Sat 19 Sep | [AHB manager RTL](Protocols/04%20AMBA/01%20AHB/code/README.md) | Trace the manager FSM and predict outputs during reset, wait, and completion. |
| Sun 20 Sep | Due reviews and recovery only | Compare I2C, SPI, UART, and AHB by ownership, sampling, response, and termination. |
| Mon 21 Sep | [APB](Protocols/04%20AMBA/02%20APB/README.md) | Draw SETUP and ACCESS, then show both zero-wait and waited transfers. |
| Tue 22 Sep | [AXI sections 1-2](Protocols/04%20AMBA/03%20AXI/Lectures/README.md): family, channels, and handshake | State the `VALID`/`READY` rules and trace a stall without changing payload. |
| Wed 23 Sep | AXI section 3: round-robin arbiter and AXI-Stream FIFO | Trace two competing requesters and prove when one beat enters or leaves the FIFO. |
| Thu 24 Sep | AXI sections 4-5: AXI4-Lite channels and single-beat control | Draw independent write-address, write-data, and response handshakes. |

## Week 5 - AXI depth and FIFO

| Date | Primary focus | Closed-book proof before stopping |
|---|---|---|
| Fri 25 Sep | AXI sections 6-7: FSM implementation and GPIO use case | Trace one write and one read through the responsible FSM states. |
| Sat 26 Sep | AXI sections 8-9: AXI4 bursts and next-address generation | Generate FIXED, INCR, and WRAP addresses; check beat size, length, and boundary. |
| Sun 27 Sep | Due reviews and recovery only | Repair the weakest AXI channel or burst rule using one fresh waveform. |
| Mon 28 Sep | Mixed AMBA test | Compare AHB, APB, AXI4-Lite, AXI4, and AXI-Stream using one transfer each. |
| Tue 29 Sep | [FIFO](FIFO/README.md): contract, storage, pointers, and occupancy | Trace accepted reads/writes, pointer movement, and occupancy for ten cycles. |
| Wed 30 Sep | FIFO: flags, wraparound, and simultaneous operations | Derive empty/full behavior and test the read-plus-write boundary cases. |
| Thu 1 Oct | FIFO RTL and verification | Predict a testbench trace first, then run it and explain every mismatch. |

## Week 6 - Integration and interview speed

| Date | Primary focus | Closed-book proof before stopping |
|---|---|---|
| Fri 2 Oct | Serial-versus-AMBA integration | Choose a protocol for three design scenarios and defend the choice with timing and ownership. |
| Sat 3 Oct | Mixed CMOS and STA numerical set | Solve one device/circuit question and one setup/hold question without reference material. |
| Sun 4 Oct | Due reviews and recovery only | Clear every overdue `M`; leave no weak item without a dated repair action. |
| Mon 5 Oct | Mixed sequential RTL: divider, FIFO, and AXI-Stream | Trace state, occupancy, and handshake together for a stalled data path. |
| Tue 6 Oct | Whiteboard reconstruction | Rebuild the full prerequisite map from MOS physics to CMOS delay, STA, and interfaces. |
| Wed 7 Oct | Mock interview | Answer ten random core questions in 30-60 seconds each; mark vague answers `H`. |
| Thu 8 Oct | Final mixed test and next queue | Complete four proofs: one derivation, one numerical, one waveform, and one RTL trace. |

## What happens after 8 October

Continue the due dates already created by the `R`/`H`/`M` rules. Use this
weekly rotation for new work:

| Day | Permanent focus |
|---|---|
| Monday | MOSFET/CMOS plus one equation or region check |
| Tuesday | STA plus one complete path calculation |
| Wednesday | Protocol waveform and a neighboring-protocol contrast |
| Thursday | RTL simulation or cycle trace: divider, FIFO, or interface |
| Friday | Mixed interview questions |
| Saturday | Deep repair of the week's two weakest items |
| Sunday | Due reviews only; recover at most one missed session |

The schedule is working when the `M` count falls, answers become causal rather
than memorized, and the final proof can be produced before the notes are
opened. Time spent reading is not the score; successful closed-book retrieval
is.
