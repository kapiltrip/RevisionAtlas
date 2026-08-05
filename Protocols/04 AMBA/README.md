# 04 - AMBA

[Back to Protocols](../README.md)

AMBA is Arm's Advanced Microcontroller Bus Architecture: a family of on-chip
interconnect protocols rather than one bus. This folder is the common home for
AHB now and for later APB, AXI, or bridge chapters, so protocol-specific rules
do not get mixed together.

## Chapter map

| Order | Chapter | Current scope | Status |
|---:|---|---|:---:|
| 1 | [AHB](01%20AHB/README.md) | AHB-Lite transfers, wait states, FSM reasoning, SINGLE/INCR4/WRAP4 RTL, and verification | STARTED |
| 2 | APB | Add as a sibling when APB notes or code arrive | LATER |

## Keep the names separate

- **AMBA** is the protocol family.
- **AHB** is the pipelined high-performance bus studied in the current chapter.
- **APB** is a simpler peripheral bus and will not be described as if it used
  AHB's `HTRANS`, `HBURST`, or pipelined address/data rules.

The current source of truth is Arm's
[AMBA AHB Protocol Specification, ARM IHI 0033C](01%20AHB/sources/ARM-IHI-0033C-AMBA-AHB-Protocol-Specification.pdf).

## Planned growth

```text
04 AMBA/
|-- README.md
|-- 01 AHB/
|   |-- README.md
|   |-- code/
|   |-- handwritten/
|   |-- images/
|   `-- sources/
`-- 02 APB/                         # create only when APB work begins
```
