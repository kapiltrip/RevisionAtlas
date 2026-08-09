# 04 - AMBA

[Back to Protocols](../README.md)

AMBA is Arm's Advanced Microcontroller Bus Architecture: a family of on-chip
interconnect protocols rather than one bus. This folder keeps AHB, APB, and AXI
in separate chapters so their timing rules are learned without mixing signal
names or transfer models.

## Chapter map

1. [AHB](01%20AHB/README.md) covers pipelined address/data phases, wait states,
   `HTRANS`, bursts, handwritten pages, corrected FSM reasoning, RTL, and
   verification.
2. [APB](02%20APB/README.md) covers SETUP/ACCESS timing, wait states, error
   reporting, and the matching handwritten pages.
3. [AXI](03%20AXI/README.md) covers interface selection, independent
   `VALID`/`READY` channels, AXI-Stream signals and IP, then AXI4-Lite through
   write-address and write-data lessons. The course boundary is lesson 49.

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
[AMBA AHB Protocol Specification, ARM IHI 0033C](../../_internal/Protocols/04%20AMBA/01%20AHB/sources/ARM-IHI-0033C-AMBA-AHB-Protocol-Specification.pdf)
and
[AMBA APB Protocol Specification, ARM IHI 0024E](../../_internal/Protocols/04%20AMBA/02%20APB/sources/ARM-IHI-0024E-AMBA-APB-Protocol-Specification.pdf),
plus the
[AMBA AXI-Stream Protocol Specification, ARM IHI 0051B](../../_internal/Protocols/04%20AMBA/03%20AXI/sources/ARM-IHI-0051B-AMBA-AXI-Stream-Protocol-Specification.pdf).
Memory-mapped AXI4 and AXI4-Lite distinctions are checked against the official
[AMBA AXI and ACE Protocol Specification, ARM IHI 0022H](https://developer.arm.com/-/media/Arm%20Developer%20Community/PDF/IHI0022H_amba_axi_protocol_spec.pdf).

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
|   `-- handwritten/
|-- 02 APB/
|   |-- README.md
|   `-- handwritten/
`-- 03 AXI/
    |-- README.md
    |-- Course Atlas.md
    |-- Handwritten Notes.md
    |-- Section 01 - Introduction to AXI.md
    |-- Section 02 - AXI-Stream Interface Fundamentals.md
    |-- Section 03 - AXI-Stream IPs.md
    `-- Section 04 - Getting Started with AXI4-Lite.md
```

The corresponding specifications and images are centralized under the
repository root's `_internal/Protocols/04 AMBA/` tree, which mirrors these
study folders without adding support directories to their GitHub listings.
