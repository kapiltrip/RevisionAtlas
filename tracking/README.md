# Subject Dashboard and Review Queue

This is the management view for Revision Atlas. “Revision-ready” means the current scope has explanations, term definitions, citations, and retrieval prompts; it does not mean the entire academic subject is complete.

| Subject / topic | Source-linked explanation | Cited term layer | Quick recall / formula layer | Mixed tests | Next action |
|---|---|---|---|---|---|
| MOSFET and CMOS | Ready: 110 pages | Ready for current scope | Planned | Planned | Build five module quick-recall sheets |
| Static Timing Analysis | Ready: 25 pages | Ready for current scope | Planned | Planned | Extract formula/sign-convention sheet |
| Protocols | Ready: 16 serial pages; AHB foundation added | Ready for I2C, SPI, UART; AHB code verified | Planned | Planned | Add AHB handwritten pages when supplied |
| FIFO | Architecture guide + starter RTL | Ready for current scope | Planned | Planned | Complete and verify synchronous FIFO contract/RTL |
| Frequency Dividers | Ready: 13 pages | Ready for current scope | Planned | Planned | Build waveform and duty-cycle test set |

## Review queue format

Copy one row per weak term, page, derivation, waveform, or design invariant.

| Item | Subject | Mark | Last reviewed | Next due | Repair action |
|---|---|---|---|---|---|
| `<term/page/question>` | `<subject>` | `R / H / M` | `YYYY-MM-DD` | `YYYY-MM-DD` | `<define / derive / draw / solve / implement>` |

Queue rules:

- `M` — due tomorrow; repair the prerequisite and solve another example.
- `H` — due in three days; answer a contrast or “why” question.
- `R` — due in seven days, then Day 14 and Day 30.

The full session method and subject-specific tests are in [How to Revise a Subject](../REVISION_PLAN.md).
