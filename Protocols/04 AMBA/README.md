# 04 - AMBA

[Back to Protocols](../README.md)

AMBA is Arm's Advanced Microcontroller Bus Architecture: a family of on-chip
interconnect protocols rather than one bus. This folder keeps AHB and APB in
separate chapters so their timing rules are learned together without mixing
their signal names or transfer models.

## Chapter map

| Order | Chapter | Current scope | Status |
|---:|---|---|:---:|
| 1 | [AHB](01%20AHB/README.md) | Pipelined transfers, wait states, `HTRANS`, bursts, handwritten pages, RTL, and verification | ACTIVE |
| 2 | [APB](02%20APB/README.md) | Setup/access timing, wait states, errors, and handwritten pages | ACTIVE |

## Keep the names separate

- **AMBA** is the protocol family.
- **AHB** is a pipelined, higher-performance system bus with separate address
  and data phases.
- **APB** is a simpler peripheral bus with SETUP and ACCESS phases. It does not
  use AHB's `HTRANS`, `HBURST`, or pipelined address/data rules.

The sources of truth are Arm's
[AMBA AHB Protocol Specification, ARM IHI 0033C](01%20AHB/sources/ARM-IHI-0033C-AMBA-AHB-Protocol-Specification.pdf)
and
[AMBA APB Protocol Specification, ARM IHI 0024E](02%20APB/sources/ARM-IHI-0024E-AMBA-APB-Protocol-Specification.pdf).

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
`-- 02 APB/
    |-- README.md
    |-- handwritten/
    |-- images/
    `-- sources/
```
