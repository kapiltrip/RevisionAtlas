# Coverage and Review Queue

[Back to RevisionSolved](../../../README.md) | [Revision method](../guides/REVISION_METHOD.md)

“Revision-ready” means the stated source boundary has deep explanations, term
definitions, corrections, and retrieval prompts. It does not mean the entire
academic subject is complete.

## Current coverage

### MOSFET and CMOS

- Ready: all 110 pages across five notebooks are rendered and discussed.
- Present strength: device physics, regions, inverter behavior, delay, power,
  noise, and sizing are source-linked and cited.
- Next high-value layer: five module-level quick-recall sheets.

### Static Timing Analysis

- Ready: all 25 pages are rendered and discussed, including visible corrections
  and worked sign conventions.
- Present strength: storage elements, setup/hold paths, skew, arrival/required
  time, slack, and maximum frequency.
- Next high-value layer: one formula and sign-convention sheet.

### Protocols

- Ready: all 16 handwritten serial-protocol pages for I2C, SPI, and UART.
- AMBA: AHB has specification-backed notes and verified RTL; APB has its
  handwritten layer; AXI has one handwritten page and a section-organized
  course atlas through lesson 49.
- Next high-value action: extend AXI only after Kapil reaches lesson 50, and add
  new handwritten pages when supplied.

### FIFO

- Ready: the architecture, contract, pointer, flag, occupancy, and verification
  guide plus starter RTL/project structure.
- Next high-value action: complete and verify the synchronous FIFO contract and
  then derive the CDC-safe asynchronous design.

### Frequency Dividers

- Ready: all 13 notebook pages plus the separate `/2` through `/5` RTL practice
  area.
- Next high-value layer: a mixed waveform and duty-cycle test set.

## Review queue

Record each weak term, page, derivation, waveform, or invariant in a notebook
or tracker using this compact form:

```text
Item: <term, page, or question>
Subject: <subject>
Mark: R | H | M
Last reviewed: YYYY-MM-DD
Next due: YYYY-MM-DD
Repair action: define | derive | draw | solve | implement
```

- `M` is due tomorrow; repair the prerequisite and solve another example.
- `H` is due in three days; answer a contrast or “why” question.
- `R` is due in seven days, then Day 14 and Day 30.
