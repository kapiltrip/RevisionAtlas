# 03 - AMBA AXI

[Back to AMBA](../README.md) | [Back to Protocols](../../README.md)

This chapter starts AXI from the common `VALID`/`READY` transfer rule and then
specializes that rule for AXI-Stream. The present stopping point is the Namaste
FPGA lesson **20. Building AXIS Master**. Material after that lesson is outside
this revision boundary and has not been summarized in advance.

## Learning layers

| Layer | Material | Status |
|---|---|:---:|
| 1 | [Course-video atlas - Day 01](course/Day%2001.md) | COMPLETE THROUGH VIDEO 20 |
| 2 | [Kapil's handwritten AXI notes](handwritten/README.md) | WAITING FOR SOURCE PAGES |
| Authority | [Arm IHI 0051B - AMBA AXI-Stream Protocol Specification](sources/ARM-IHI-0051B-AMBA-AXI-Stream-Protocol-Specification.pdf) | LOCAL SOURCE |

Layer 1 contains real frames from all 19 completed videos: videos 1-9 and
11-20. Lesson 10 is a code resource rather than a video. Layer 2 is deliberately
empty until the handwritten notes arrive; no handwritten explanation has been
invented.

## Where each AXI interface fits

| Interface | Addressed? | Transfer shape | Best first mental model |
|---|:---:|---|---|
| **AXI4-Stream** | No | A unidirectional sequence of transfers, optionally grouped into packets | A producer and consumer connected by a flow-controlled data pipe |
| **AXI4-Lite** | Yes | Single-beat memory-mapped reads and writes | Control/status-register access |
| **AXI4** | Yes | Memory-mapped single or burst transactions, with multiple outstanding operations and IDs when implemented | High-throughput access to memories, DMA engines, and interconnects |

AXI4-Stream is point-to-point at one interface: one Transmitter connects to one
Receiver. That does **not** limit a system to only two components. An AXI-Stream
interconnect can switch, arbitrate, change width, or cross a clock domain while
preserving the stream rules, as stated by the
[Arm AXI-Stream specification](sources/ARM-IHI-0051B-AMBA-AXI-Stream-Protocol-Specification.pdf).

## Core-term key

| Term | Precise meaning | Hardware meaning |
|---|---|---|
| **AMBA** | Arm's Advanced Microcontroller Bus Architecture family of on-chip interface standards. | Independently designed IP blocks can exchange information through a shared electrical and timing contract. |
| **AXI** | Advanced eXtensible Interface, the AMBA family used for high-performance memory-mapped and streaming communication. | AXI separates information into channels so each channel can use its own flow-control handshake. |
| **AXI-Stream** | A standard point-to-point interface for exchanging an ordered stream of bytes between a Transmitter and Receiver. | It carries payload and packet metadata without an address phase on every transfer. |
| **Transmitter / source** | The endpoint that drives `TVALID`, `TDATA`, and associated sideband information. | It owns the offered beat and must keep it stable while stalled. Older material often calls it the master. |
| **Receiver / destination** | The endpoint that drives `TREADY` and accepts a transfer. | It creates back-pressure by lowering `TREADY`. Older material often calls it the slave. |
| **Transfer / beat** | One payload-and-sideband item accepted on one rising edge where `TVALID` and `TREADY` are both HIGH. | A beat counter, pointer, or state machine advances once for that edge and not merely once per clock. |
| **Packet** | A related group of transfers whose final transfer is identified by `TLAST` when packet boundaries are used. | `TLAST` belongs to the same held beat as `TDATA`; it cannot disappear during a stall. |
| **Back-pressure** | The Receiver's ability to postpone acceptance by driving `TREADY` LOW. | The Transmitter freezes the complete offered beat until acceptance becomes possible. |

These definitions follow the terminology and transfer model in
[Arm IHI 0051B](sources/ARM-IHI-0051B-AMBA-AXI-Stream-Protocol-Specification.pdf).

## The one equation that controls the RTL

Define the acceptance event for cycle $n$ as:

$$
\text{fire}[n] = \text{TVALID}[n] \land \text{TREADY}[n]
$$

At the rising edge ending cycle $n$:

- if `fire` is `1`, exactly one transfer is accepted;
- if `TVALID=1` and `TREADY=0`, no transfer occurs and `TDATA`, `TLAST`,
  `TKEEP`, `TSTRB`, `TID`, `TDEST`, and `TUSER` associated with that offered
  transfer must remain unchanged;
- if `TVALID=0`, the Receiver must not treat `TDATA` as a transfer, regardless
  of its visible bit pattern.

The Transmitter is not permitted to wait for `TREADY` before asserting
`TVALID`. Once `TVALID` is asserted, it remains asserted until a handshake. A
Receiver **is** permitted to wait for `TVALID` before raising `TREADY`, although
pre-asserting `TREADY` gives the one-cycle, full-throughput case. These are the
actual asymmetric rules in
[section 2.2 of Arm IHI 0051B](sources/ARM-IHI-0051B-AMBA-AXI-Stream-Protocol-Specification.pdf).

## Signal ownership and meaning

| Signal | Driven by | Meaning at a transfer edge |
|---|---|---|
| `ACLK` | Clock source | All interface inputs are sampled on its rising edge. |
| `ARESETn` | Reset source | Active-LOW reset; the course's sample RTL uses synchronous assertion because reset is tested inside `always @(posedge ACLK)`. |
| `TVALID` | Transmitter | The complete offered transfer is valid now. |
| `TREADY` | Receiver | The Receiver can accept the offered transfer now. |
| `TDATA` | Transmitter | Payload; byte lane $x$ is `TDATA[(8x+7):8x]`. |
| `TKEEP[x]` | Transmitter | HIGH means byte lane $x$ must be transported; LOW marks a removable null byte. |
| `TSTRB[x]` | Transmitter | With `TKEEP[x]=1`, HIGH marks a data byte and LOW marks a position byte. The combination `TKEEP=0`, `TSTRB=1` is reserved. |
| `TLAST` | Transmitter | Marks a packet boundary when the stream uses packets. |
| `TID` | Transmitter | Identifies a logical stream for ordering/interleaving rules. |
| `TDEST` | Transmitter | Supplies destination/routing information to an interconnect. |
| `TUSER` | Transmitter | Carries application-defined sideband information associated with a transfer. |

`TKEEP`, `TSTRB`, and even `TLAST` are conditional or optional for some usage
models; they are not universally mandatory pins. If `TREADY` is omitted for an
always-accepting Receiver, it defaults HIGH. The default and optional-signal
rules are defined in
[chapter 3 of Arm IHI 0051B](sources/ARM-IHI-0051B-AMBA-AXI-Stream-Protocol-Specification.pdf).

## Lecture precision and corrections

| Lecture shortcut | Specification-accurate version |
|---|---|
| AXI-Stream, AXI-Lite, and AXI4 have fixed totals of 11, 19, and 43 pins. | Pin count is configuration-dependent. Data, address, ID, user, and destination widths vary, and many AXI-Stream signals are optional. Use a signal-set comparison, not one universal total. |
| `VALID` and `READY` must be completely independent. | The critical deadlock rule is asymmetric: the Transmitter must not wait for `READY` before raising `VALID`; the Receiver may wait for `VALID` before raising `READY`. Good high-throughput Receivers commonly assert `READY` early. |
| `TKEEP` and `TLAST` are mandatory AXI-Stream signals. | Both depend on the interface's supported data and packet model. Their absence has defined default behavior. |
| `TWAKEUP` is not part of AXI-Stream. | It is not an AXI4-Stream signal, but it was added as an optional AXI5-Stream wake-up signal in Issue B of the specification. |
| `TSTRB=0` means ordinary Ethernet padding. | With `TKEEP=1`, `TSTRB=0` means a **position byte**: its position matters but its `TDATA` value does not. Ethernet's 64-byte minimum frame also includes header and FCS, so “4 data bytes plus 60 padded bytes” is not a generally correct Ethernet calculation. |
| Any non-`OKAY` memory response means an empty memory or an automatic retry. | AXI responses encode protocol-defined outcomes such as `SLVERR` and `DECERR`. Recovery is a system/software policy; retry is not implied by every error. |
| A plain memory is inherently unable to signal valid data or completion. | A raw array has no protocol, but a memory macro can have chip-enable, write-enable, byte-enable, and ready/busy behavior. AXI standardizes scalable decoupled channels; it is not the only possible memory control interface. |
| The sample master is a reusable production AXI-Stream source. | It is a useful four-beat teaching model. Because `TDATA` is derived continuously from external `din * count`, `din` must remain stable for the whole packet, including stalls. A reusable source should latch its command/data or explicitly document that upstream stability contract. |

## Source register

| Source | Use in this chapter |
|---|---|
| [Arm IHI 0051B - AMBA AXI-Stream Protocol Specification](sources/ARM-IHI-0051B-AMBA-AXI-Stream-Protocol-Specification.pdf) | Authority for handshake, byte types, packet boundaries, optional signals, ordering, and AXI4-Stream versus AXI5-Stream behavior |
| [Arm IHI 0022H - AMBA AXI and ACE Protocol Specification](https://developer.arm.com/-/media/Arm%20Developer%20Community/PDF/IHI0022H_amba_axi_protocol_spec.pdf) | Authority for the five memory-mapped channels and AXI4/AXI4-Lite distinctions |
| [Namaste FPGA course page](https://namaste-fpga.com/student/learn/53) | Lesson order, drawings, waveform examples, and sample RTL through lesson 20 |
| [Course-video atlas](course/Day%2001.md) | Saved real frames and frame-specific explanations from the completed lessons |
| [AMD AXI DMA core overview](https://docs.amd.com/r/en-US/pg021_axi_dma/Core-Overview) | Primary reference for the memory-mapped-to-stream and stream-to-memory-mapped DMA directions |
| [AMD AXI4-Stream Video signaling guide](https://docs.amd.com/r/en-US/ug934_axi_videoIP/AXI4-Stream-Signaling-Interface) | Primary reference for video-profile `TUSER[0]` start-of-frame and `TLAST` end-of-line meanings |

## How to revise this chapter

1. Write `fire = TVALID && TREADY` before tracing any waveform.
2. Circle only rising edges where `fire=1`; number accepted beats at those
   edges.
3. For every `TREADY=0` interval, verify the entire offered beat is unchanged.
4. On the final beat, treat `TLAST` as part of the held payload, not as a
   one-cycle pulse independent of acceptance.
5. In RTL, gate every beat counter, FIFO pointer, packet counter, and input-data
   advance with the same `fire` event.
6. Revisit the [video atlas](course/Day%2001.md), then explain each correction
   in the table above without looking.

## Completion checkpoint

- What exact Boolean condition means one transfer happened?
- Why may a Transmitter assert `TVALID` before `TREADY`, but not wait for it?
- Which signals must remain stable during back-pressure?
- How do `TKEEP` and `TSTRB` distinguish data, position, and null bytes?
- Why can one AXI-Stream link be point-to-point while a larger stream network
  still has multiple sources and destinations?
- What assumption about `din` is hidden inside the course's sample master?
- Why must the beat counter advance on a handshake rather than every clock?

## Next additions

- Add Kapil's handwritten pages as Layer 2 and map each page to the matching
  video and protocol rule.
- Add the master-verification lesson only after Kapil reaches it.
- Turn the four-beat teaching master into a self-checking RTL exercise after
  the lecture's verification boundary is reached.
