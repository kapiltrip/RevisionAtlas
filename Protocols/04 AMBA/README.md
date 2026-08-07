# 04 - AMBA

[Back to Protocols](../README.md)

AMBA is Arm's Advanced Microcontroller Bus Architecture: a family of on-chip
interconnect protocols rather than one bus. This folder keeps AHB, APB, and AXI
in separate chapters so their timing rules are learned without mixing signal
names or transfer models.

## Chapter map

| Order | Chapter | Current scope | Status |
|---:|---|---|:---:|
| 1 | [AHB](01%20AHB/README.md) | Pipelined transfers, wait states, `HTRANS`, bursts, handwritten pages, RTL, and verification | ACTIVE |
| 2 | [APB](02%20APB/README.md) | Setup/access timing, wait states, errors, and handwritten pages | ACTIVE |
| 3 | [AXI](03%20AXI/README.md) | AXI family selection, valid-ready handshakes, AXI-Stream signals, stalls, and master RTL | ACTIVE THROUGH AXIS MASTER |

## Keep the names separate

- **AMBA** is the protocol family.
- **AHB** is a pipelined, higher-performance system bus with separate address
  and data phases.
- **APB** is a simpler peripheral bus with SETUP and ACCESS phases. It does not
  use AHB's `HTRANS`, `HBURST`, or pipelined address/data rules.
- **AXI** uses independent valid-ready channels. AXI4 and AXI4-Lite are
  memory-mapped; AXI-Stream moves unaddressed streams through a Transmitter and
  Receiver.

The sources of truth are Arm's
[AMBA AHB Protocol Specification, ARM IHI 0033C](01%20AHB/sources/ARM-IHI-0033C-AMBA-AHB-Protocol-Specification.pdf)
and
[AMBA APB Protocol Specification, ARM IHI 0024E](02%20APB/sources/ARM-IHI-0024E-AMBA-APB-Protocol-Specification.pdf),
plus the
[AMBA AXI-Stream Protocol Specification, ARM IHI 0051B](03%20AXI/sources/ARM-IHI-0051B-AMBA-AXI-Stream-Protocol-Specification.pdf).

## Handwritten source intake

The original PDFs remain unchanged in [Handwritten data](Handwritten%20data/).
The 24-page notebook scan contains 18 AHB pages followed by six APB pages. The
11-page iPad PDF contains ten AHB annotation pages followed by one APB page.
The remaining three-page PDF contains one blank cover and duplicates of the
first two iPad pages, so those duplicates are preserved in the source folder
but are not repeated in the learning atlases. This accounts for all 38 source
PDF pages and 35 unique instructional pages.

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
|-- 02 APB/
|   |-- README.md
|   |-- handwritten/
|   |-- images/
|   `-- sources/
`-- 03 AXI/
    |-- README.md
    |-- course/
    |-- handwritten/
    |-- images/
    `-- sources/
```
