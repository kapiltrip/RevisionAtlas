# Revision Atlas

Revision Atlas is a revision-first knowledge base for VLSI and digital-design
topics. Each subject keeps source material intact, explains the hardware
reasoning beside it, and turns that understanding into short recall units.

## Start here

- [MOSFET and CMOS](MOSFET%20and%20CMOS/README.md) — device physics, CMOS
  behavior, delay, power, noise, and sizing.
- [FIFO](FIFO/README.md) — architecture, RTL, verification, timing, and CDC.
- [Frequency Dividers](Frequency%20Dividers/README.md) — source-linked divider
  theory, waveforms, and duty-cycle reasoning.
- [Frequency Divider RTL Practice](Programmable%20Frequency%20Divider/README.md)
  — focused `/2` through `/5` implementations and self-checking simulations.
- [Protocols](Protocols/README.md) — I2C, SPI, UART, and the
  [AMBA path](Protocols/04%20AMBA/README.md) covering AHB, APB, AXI4,
  AXI4-Lite, and AXI-Stream.
- [Static Timing Analysis](Static%20Timing%20Analysis/README.md) — storage
  elements, setup/hold analysis, arrival and required time, slack, skew, and
  worked timing paths.

## Repository controls

- [Content standard](CONTENT_STANDARD.md) defines how technical terms, physical
  meaning, common confusions, and authoritative references are handled.
- [Revision plan](REVISION_PLAN.md) defines the retrieval method and the
  Day 1/3/7/14/30 review ladder.
- [Subject dashboard](tracking/README.md) tracks coverage and the `R/H/M`
  review queue.
- [Future plan](FUTURE_PLAN.md) controls growth without duplicating material.
- [Subject template](templates/subject-template.md) is the starting point for a
  new subject.

## Content rule

A core term is not complete until five things are clear:

1. its precise technical meaning;
2. its plain-language meaning;
3. what it means physically or in hardware;
4. the nearest term or behavior it is commonly confused with; and
5. an authoritative source.

Long source-page explanations remain beside the source. Fast-recall notes,
formulas, pitfalls, and question banks belong in a separate `revision/` layer
when that layer is created.

## Revision loop

1. **Recognize:** look at the source page or waveform and name the problem.
2. **Retrieve:** explain the diagram, assumptions, edge events, and conclusion
   without reading the explanation.
3. **Repair:** read only enough to locate the missing reasoning link.
4. **Test:** answer the active-recall prompt closed-book.
5. **Compress:** finish with one causal sentence:
   `When _____ changes, _____ changes because _____.`

Use `R` for recalled, `H` for hesitant, and `M` for missed. Review `M` items
tomorrow, `H` items after three days, and `R` items after one week. The complete
schedule and pass criteria are in the [revision plan](REVISION_PLAN.md).

## Current AMBA focus

The AMBA material is organized by transfer model, not by memorizing signal
lists:

- **AHB:** overlap the next address phase with the current data phase; reason
  about `HREADY`, transfer types, bursts, and response routing.
- **APB:** retain one request through SETUP and ACCESS; reason about
  `PREADY`, stability, errors, and bridge behavior.
- **AXI:** treat every channel as an independent `VALID`/`READY` interface;
  then add memory-mapped channel dependencies, burst rules, IDs, ordering, and
  AXI-Stream packet semantics.

Open the [AMBA dashboard](Protocols/04%20AMBA/README.md) for the study order,
official Arm specifications, detailed notes, RTL, and verification
checkpoints.

## Source and citation policy

Original PDFs and handwritten pages remain unchanged. Explanations can correct
or deepen them, but a protocol rule must be checked against the protocol
owner's specification. Course videos and handwritten pages are teaching
evidence; they do not override an Arm, NXP, Microchip, AMD, or other primary
specification.
