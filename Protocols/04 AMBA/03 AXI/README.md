# 03 — AMBA AXI

[Back to AMBA](../README.md) | [Back to Protocols](../../README.md)

AXI is AMBA's decoupled, channel-based interface family. The common rule is
simple—information transfers only when `VALID && READY`—but AXI depth comes
from applying that rule independently to address, data, and response channels
while preserving transaction dependencies, ordering, and payload stability.

This chapter covers memory-mapped AXI4 and AXI4-Lite as interview foundations,
then connects them to the existing AXI-Stream lesson and question notes.

## Open this chapter

- [AXI Day 01 notes](../notes/AXI%20Day%2001.md) — AXI-Stream handshake,
  source/sink RTL, stalls, integration, and the plain round-robin arbiter
  through lesson 33.
- [AXI question notes](../notes/AXI%20Questions.md) — the round-robin fairness
  question and its AXI-Stream boundary conditions.
- [Arm IHI 0051B AXI-Stream specification](sources/ARM-IHI-0051B-AMBA-AXI-Stream-Protocol-Specification.pdf)
  — local stream authority.
- [Arm IHI 0022H AXI and ACE specification](https://developer.arm.com/-/media/Arm%20Developer%20Community/PDF/IHI0022H_amba_axi_protocol_spec.pdf)
  — memory-mapped AXI4 and AXI4-Lite authority.

## Choose the correct AXI interface

- **AXI4:** memory-mapped, burst-capable, ID-based, and suitable for
  high-throughput memories, DMA engines, and interconnects.
- **AXI4-Lite:** memory-mapped and single-beat, with fewer attributes and no
  transaction IDs. It fits control/status registers.
- **AXI-Stream:** unaddressed, unidirectional transfer of ordered data and
  sideband information. It fits DSP, packet, video, and DMA data paths.

AXI-Stream is not “AXI4 without address wires.” It is a separate protocol with
stream and packet semantics.

## The universal handshake invariant

For any AXI channel:

$$
\text{fire}=\texttt{VALID}\land\texttt{READY}
$$

At the rising edge where `fire=1`, exactly one beat transfers.

The source owns `VALID` and the channel payload. The destination owns `READY`.
The source must not wait for `READY` before asserting `VALID`; doing so can
deadlock with a destination that waits for `VALID`. Once `VALID=1`, the source
must keep `VALID` and its entire payload stable until a handshake.

The destination may assert `READY` before or after `VALID`. Pre-asserting it
permits a one-cycle transfer.

AXI also forbids combinational paths between interface inputs and outputs.
Registering or buffering channel boundaries avoids long ready loops and makes
timing closure practical.

## AXI4 memory-mapped channels

- **AW — write address:** `AWADDR`, burst attributes, ID, and protection/cache
  attributes travel with `AWVALID/AWREADY`.
- **W — write data:** `WDATA`, byte strobes, and `WLAST` travel with
  `WVALID/WREADY`.
- **B — write response:** `BRESP` and `BID` travel with
  `BVALID/BREADY`.
- **AR — read address:** `ARADDR`, burst attributes, ID, and attributes travel
  with `ARVALID/ARREADY`.
- **R — read data:** `RDATA`, `RRESP`, `RID`, and `RLAST` travel with
  `RVALID/RREADY`.

Each channel can stall independently. A design that gates all five channels
with one global “AXI ready” signal throws away the protocol's decoupling and
often creates deadlock or throughput problems.

## Write transaction: independence plus dependency

AW and W are independent. The address can handshake before the data, the data
can handshake before the address, or both can handshake on the same edge. A
subordinate that needs both must buffer whichever arrives first.

A correct AXI4 write-response condition is conceptually:

```text
write address accepted
AND
all write data beats accepted, including WLAST
THEN
offer BVALID with BRESP/BID
```

The subordinate must not wait for `BREADY` before asserting `BVALID`.
`BVALID` and its response hold until `BVALID && BREADY`.

In AXI4, write data has no `WID`; write-data ordering follows the accepted
write-address ordering rules. Do not try to pair AW and W by assuming they
arrive in the same cycle.

## Read transaction

An AR handshake creates a read request. The subordinate later offers one or
more R beats. Every beat transfers on `RVALID && RREADY`; `RLAST` marks the
final beat of a burst and must remain stable with its beat during a stall.

The subordinate must not wait for `RREADY` before asserting `RVALID`.
`RRESP` belongs to each read beat, so a burst can report response information
per beat rather than only after the entire burst.

## Burst arithmetic

For AW or AR:

$$
\text{beats}=\texttt{AxLEN}+1
$$

$$
\text{bytes per beat}=2^{\texttt{AxSIZE}}
$$

`AxBURST` selects FIXED, INCR, or WRAP address behavior.

- **FIXED:** every beat uses the same address, useful for FIFO-like locations.
- **INCR:** address advances by bytes per beat.
- **WRAP:** address advances but wraps inside
  `beats × bytes_per_beat`; legal AXI wrap lengths are 2, 4, 8, or 16 beats.

An AXI transaction must not cross a 4-KiB boundary. A practical check is:

$$
\texttt{start\_addr[ADDR\_W-1:12]}
=
\texttt{last\_byte\_addr[ADDR\_W-1:12]}
$$

where `last_byte_addr` includes every byte covered by the final beat. Do not
confuse this system routing boundary with a WRAP burst's smaller local wrap
region.

## IDs, outstanding transactions, and ordering

AXI4 IDs let a manager issue transactions without waiting for every earlier
response. Responses carry `BID` or `RID` so the interconnect can route them
back correctly.

The safe interview rule is:

- transactions with the same relevant ID have ordering guarantees defined by
  the protocol;
- different IDs permit more independence and can complete out of issue order;
- a component that requires an order not guaranteed by AXI must wait for a
  response or add its own dependency control.

IDs do not mean beats within one burst can be arbitrarily reordered. AXI4-Lite
removes ID signals and burst support, which simplifies register interfaces but
does not remove the five-channel handshake model.

## Responses

Memory-mapped AXI uses response encodings:

- `OKAY`: normal access;
- `EXOKAY`: successful exclusive access where that feature applies;
- `SLVERR`: the addressed subordinate accepted the request but could not
  complete it successfully;
- `DECERR`: the interconnect could not decode the address to a valid target.

An error response does not automatically imply retry. Recovery is a
system/software decision.

## AXI-Stream data and packet semantics

AXI-Stream uses one forward channel:

- `TVALID`: transmitter offers a beat;
- `TREADY`: receiver accepts a beat;
- `TDATA`: payload;
- `TKEEP`: byte lanes that must be transported;
- `TSTRB`: distinguishes data bytes from position bytes when `TKEEP=1`;
- `TLAST`: packet boundary when packet semantics are used;
- `TID`: logical stream identity;
- `TDEST`: routing destination;
- `TUSER`: application-defined sideband;
- optional AXI5-Stream `TWAKEUP`: wake/activity indication, not a handshake.

During `TVALID && !TREADY`, every implemented forward signal belonging to the
offered beat must hold, including `TDATA`, `TLAST`, byte qualifiers, ID,
destination, and user fields.

`TKEEP`, `TSTRB`, and `TLAST` are not universally mandatory pins; their
presence depends on the interface's byte and packet model. Signal totals are
therefore configuration-dependent.

## Round-robin arbitration at an AXI-Stream boundary

A plain request/grant arbiter can rotate priority every completed service. An
AXI-Stream arbiter must additionally preserve the selected source while its
offered output beat is stalled:

```text
out_tvalid && !out_tready
=> selected source and all output payload stay stable
```

For beat-level arbitration, rotate after an output handshake. For
packet-level arbitration, keep the source selected through the handshake that
accepts `TLAST`, then rotate. Rotating merely because a clock edge occurred can
mix two sources into one stalled beat or packet.

## RTL and verification invariants

For every channel:

- count a transfer only on `VALID && READY`;
- hold `VALID` and payload during `VALID && !READY`;
- allow independent stalls on AW, W, B, AR, and R;
- never require the source to see `READY` before it asserts `VALID`;
- reset source-side `VALID` outputs LOW;
- avoid combinational input-to-output paths.

For memory-mapped AXI:

- accept AW and W in either order;
- issue B only after address and final write data are accepted;
- check `WSTRB` byte lanes;
- preserve `WLAST` and `RLAST` through stalls;
- verify burst address, length, size, wrap, and 4-KiB rules;
- scoreboard responses by ID and channel;
- test `SLVERR` and `DECERR`; and
- randomize back-pressure independently on all channels.

For AXI-Stream:

- randomize receiver stalls and transmitter bubbles;
- hold sidebands with the stalled beat;
- count packet completion on `TVALID && TREADY && TLAST`, not on a falling
  edge of `TLAST`;
- verify zero-byte or partial-byte cases when `TKEEP` is implemented.

## Course corrections retained

- Do not memorize fixed pin totals for AXI4, AXI4-Lite, or AXI-Stream.
- The source must not wait for `READY`; the destination may wait for `VALID`.
- `TKEEP` and `TLAST` depend on the configured stream model.
- `TWAKEUP` is AXI5-Stream-only.
- With `TKEEP=1`, `TSTRB=0` marks a position byte, not generic padding.
- The course master requires external `din` to remain stable because it does
  not latch the whole command.
- `TVALID` may contain bubbles between accepted packet beats, but an offered
  beat cannot be withdrawn before handshake.
- The course slave's combinational `dout` is not stored data.
- Packet completion is the accepted `TLAST` beat, not `negedge TLAST`.

The clause-level review remains in the
[Day 01 standards audit](../notes/AXI%20Day%2001.md#arm-ihi-0051b-standards-audit).

## Recall checkpoint

1. Why may AW and W handshake in either order?
2. What must happen before a subordinate can offer `BVALID`?
3. What is the one invariant shared by all five channels?
4. Derive beats and bytes per beat from `AxLEN` and `AxSIZE`.
5. Why can a legal WRAP burst still violate the 4-KiB rule?
6. What do IDs enable, and what ordering assumption is unsafe?
7. What is removed—and what remains—in AXI4-Lite?
8. Which AXI-Stream signals must hold during back-pressure?
9. When should a stream arbiter rotate at beat level and packet level?
