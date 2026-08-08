# 04 — AMBA

[Back to Protocols](../README.md)

AMBA is Arm's **Advanced Microcontroller Bus Architecture**, a family of
on-chip interface protocols. It is not one bus and it is not a processor
architecture. Each member defines a different contract for moving requests,
data, and responses between IP blocks.

## Study order

- [01 — AHB](01%20AHB/README.md): pipelined address/data phases, transfer
  types, wait states, bursts, response routing, a limited AHB-Lite manager,
  and a self-checking testbench.
- [02 — APB](02%20APB/README.md): one SETUP cycle, one-or-more ACCESS cycles,
  wait states, error timing, back-to-back transfers, protocol versions, and
  bridge behavior.
- [03 — AXI](03%20AXI/README.md): AXI4's five memory-mapped channels,
  AXI4-Lite, AXI-Stream, `VALID`/`READY`, bursts, the 4-KiB rule, IDs,
  ordering, back-pressure, and RTL/DV invariants.

The fastest learning sequence is APB → AHB → AXI. The folder numbering keeps
the existing source order, but APB gives the simplest transaction model.

## Choose by transfer model

**APB — retained peripheral access**

A requester presents one address/control packet in SETUP and holds that same
packet through ACCESS until the completer raises `PREADY`. There is no burst
pipeline. This fits low-bandwidth control and status registers.

**AHB — shared address/data pipeline**

Address/control for transfer $N+1$ can overlap the data phase of transfer $N$.
`HREADY` both completes the current data phase and permits the pipeline to
advance. This fits memories and higher-bandwidth system components while
remaining simpler than AXI.

**AXI — decoupled channels**

Read address, read data, write address, write data, and write response use
independent handshakes. Buffering and channel independence improve concurrency
and timing closure, but they also create ordering and dependency rules that do
not exist in APB.

**AXI-Stream — unaddressed flow-controlled data**

AXI-Stream reuses the `VALID`/`READY` transfer rule for ordered data and
sideband information without a memory address phase. Packet boundaries and
byte validity can be represented by `TLAST`, `TKEEP`, and `TSTRB`.

## System view

A typical SoC does not choose one protocol for everything:

```text
CPU / DMA / high-speed IP
          |
       AXI or AHB
          |
   interconnect + bridge
          |
         APB
          |
 UART / GPIO / timer / control registers
```

The interconnect performs address decoding, arbitration when required, and
request/response routing. A bridge changes the transaction model. For example,
an AHB-to-APB bridge must remember the AHB request, generate APB SETUP and
ACCESS, wait for `PREADY`, return `PRDATA` for reads, and translate
`PSLVERR` into the upstream response.

## Rules that must not be mixed

- AHB uses `HTRANS`, `HBURST`, and an address/data pipeline; APB does not.
- APB `PENABLE` marks ACCESS; it is not a data-phase equivalent of AHB.
- AXI's five memory-mapped channels are independently flow-controlled; write
  address and write data are not required to handshake together.
- AXI-Stream has no memory address channel. `TID` and `TDEST` do not turn it
  into AXI4 memory-mapped traffic.
- `READY`/`VALID` is not the same handshake as AHB `HREADY` or APB `PREADY`.
  Similar words do not imply identical timing.
- Signal counts are configuration-dependent. Learn mandatory groups,
  directions, widths, and optional features instead of memorizing one total.

## Interview scope boundary

The active path is AHB/AHB-Lite, APB3/APB4/APB5 core behavior, AXI4,
AXI4-Lite, and AXI-Stream. Older AMBA members such as ASB are useful historical
context but are not a priority unless a role or source explicitly requires
them.

## Source intake

All source-derived material is collected under one [notes directory](notes/README.md).
It contains the AHB, APB, and AXI explanations, their page images, lecture
captures, and the unchanged source PDFs.

The original PDFs remain unchanged in [notes/sources](notes/sources/).
The 24-page notebook contains 18 AHB pages followed by six APB pages. The
11-page iPad file contains ten AHB annotation pages followed by one APB page.
A separate three-page file contains a blank cover and two duplicated iPad
pages; the source is preserved, but duplicates are not repeated in the
learning atlases. This leaves 35 unique instructional pages.

## Sources of truth

- [Arm AMBA AHB Protocol Specification, IHI 0033C](01%20AHB/sources/ARM-IHI-0033C-AMBA-AHB-Protocol-Specification.pdf)
- [Arm AMBA APB Protocol Specification, IHI 0024E](02%20APB/sources/ARM-IHI-0024E-AMBA-APB-Protocol-Specification.pdf)
- [Arm AMBA AXI and ACE Protocol Specification, IHI 0022H](https://developer.arm.com/-/media/Arm%20Developer%20Community/PDF/IHI0022H_amba_axi_protocol_spec.pdf)
- [Arm AMBA AXI-Stream Protocol Specification, IHI 0051B](03%20AXI/sources/ARM-IHI-0051B-AMBA-AXI-Stream-Protocol-Specification.pdf)

Lecture frames and source notes determine the teaching order. The Arm
specifications determine protocol correctness.
