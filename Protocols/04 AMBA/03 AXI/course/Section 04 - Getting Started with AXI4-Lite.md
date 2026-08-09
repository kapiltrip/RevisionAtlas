# Section 4 - Getting Started with AXI4-Lite

[Previous: Section 3](Section%2003%20-%20AXI-Stream%20IPs.md) | [Course hub](README.md) | [AXI chapter](../README.md)

**Course status:** 5/10 lessons complete. This page stops at lesson 49,
**Understanding Write data channel**. Lessons 50-54 are intentionally not
summarized yet.

Lessons 45–49 first separate transaction, burst, beat, and channel-transfer
language; then they examine the write address channel, the purpose of full-AXI
IDs, and the write data channel with byte strobes. The page continually removes
AXI3/full-AXI fields that do not belong on an AXI4-Lite interface.

## Read this section with the correct protocol lens

The course section is named AXI Lite, but several frames in lessons 46-49 show
**full AXI burst fields** and one **AXI3-only** field while building the general
mental model. They are useful, but they are not the literal AXI4-Lite signal
set. The official
[AMBA AXI and ACE Protocol Specification](https://developer.arm.com/-/media/Arm%20Developer%20Community/PDF/IHI0022H_amba_axi_protocol_spec.pdf)
defines AXI4-Lite as single-beat, fixed-width operation without burst, ID, or
last-beat signals.

| Signal or feature | AXI4 | AXI4-Lite |
|---|---|---|
| `AWADDR`, `AWVALID`, `AWREADY` | Present | Present |
| `WDATA`, `WSTRB`, `WVALID`, `WREADY` | Present | Present |
| `BVALID`, `BREADY`, `BRESP` | Present | Present |
| `AWLEN`, `AWSIZE`, `AWBURST` | Describe a burst | Absent; one full-bus-width beat is implied |
| `AWID` and `BID` | Identify write transactions when IDs are implemented | Absent |
| `WID` | Not an AXI4 signal; it belongs to AXI3 | Absent |
| `WLAST` | Marks the final write-data beat | Absent; every Lite transaction has one data beat |

That distinction prevents a common exam and RTL error: do not add `AWLEN`,
`AWBURST`, `AWID`, `WID`, or `WLAST` to a block merely because its interface is
called AXI4-Lite.

### Video 45 - Section 4 agenda

![Full-screen Section 4 agenda for beat, transfer, transaction, channels, signals, and AXI-Lite](../images/Day%2002/45-axi-lite-agenda-50.png)

The agenda gives the correct learning order. First decide what event is being
counted; then separate the five memory-mapped channels; then learn the payload
on each channel; finally remove the full-AXI features that AXI4-Lite does not
need. The section therefore begins with full-AXI examples as scaffolding before
arriving at the Lite subset.

### Video 46 - Transaction versus beat versus transfer

![Full-screen handwritten transaction and multi-beat transfer model above a read-burst waveform](../images/Day%2002/46-transaction-beat-transfer-20.png)

The handwritten left side groups address, data, and response into a complete
transaction. The right side shows $b_0$-$b_3$ as the data items within a
multi-beat operation. Use these precise meanings:

- a **channel transfer** occurs on one rising edge where that channel's
  `VALID && READY` is HIGH;
- a **data beat** is one accepted item on the `W` or `R` data channel;
- a **burst** is one address request followed by one or more data beats;
- a **transaction** is the complete read or write operation, including its
  address, data, and completion response information.

The words *beat* and *data transfer* are often used interchangeably. Always
state the channel when ambiguity matters: an address transfer and a data
transfer are different handshakes.

![Full-screen four-beat read waveform with AR address/control and R data/response channels](../images/Day%2002/46-transaction-beat-transfer-55.png)

The waveform is a full-AXI read burst. `ARLEN=3` encodes four data beats because:

$$
N_{\text{beats}}=\text{AxLEN}+1
$$

`ARVALID && ARREADY` accepts the request once. Later, each edge with
`RVALID && RREADY` accepts one of `0x10`, `0x11`, `0x12`, and `0x13`; `RLAST`
belongs to the fourth beat. If `RREADY` goes LOW while `RVALID` is HIGH, that
beat and its `RRESP`/`RLAST` values must stay unchanged.

AXI4-Lite removes `ARLEN`, `ARSIZE`, `ARBURST`, and `RLAST`. A Lite read has one
address transfer and exactly one read-data transfer.

### Video 47 - Understanding the write address channel

![Full-screen write-address waveform annotated with address, size, burst, length, ID, and encoding tables](../images/Day%2002/47-write-address-channel-85.png)

The `AW` channel carries **where** and **how** a full-AXI write will occur; it
does not carry the write data itself. In the frame:

- `AWADDR=a0` is the first transfer address;
- `AWSIZE=2` means $2^2=4$ bytes per beat;
- `AWBURST=INCR` selects incrementing addresses;
- `AWLEN=3` requests four beats;
- `AWID=id0` labels the full-AXI write transaction.

For an incrementing burst, the teaching relationship is:

$$
A_k=A_0+k\times 2^{\text{AWSIZE}}
$$

so four-byte beats starting at `a0` use `a0`, `a0+4`, `a0+8`, and `a0+12`,
subject to the protocol's alignment and boundary rules.

The address transfer itself is only:

$$
\text{aw\_fire}=\text{AWVALID}\land\text{AWREADY}
$$

The source must assert `AWVALID` without waiting for `AWREADY`, then hold
`AWADDR` and every AW control field stable until `aw_fire`. The write-address
and write-data channels are independent: a legal slave must not assume their
handshakes always occur in the same cycle.

For AXI4-Lite, retain `AWADDR`, `AWPROT`, `AWVALID`, and `AWREADY`. The burst and
ID fields shown in the frame are absent because a Lite write has one fixed-width
data beat and ordered responses.

### Video 48 - Understanding channel IDs

![Full-screen comparison of non-pipelined and pipelined single-beat request/response timing](../images/Day%2002/48-channel-ids-20.png)

Without pipelining, the requester waits for the response to address $a_0$
before sending $a_1$. The link is simple but round-trip latency creates idle
cycles. With pipelining, the requester can issue $a_1$ before response $d_0$
returns, increasing the number of outstanding transactions and improving
throughput.

![Full-screen pipelined waveform using request and response IDs to associate returned data](../images/Day%2002/48-channel-ids-55.png)

IDs let full AXI associate a response with its originating request. `ARID` is
returned as `RID`; `AWID` is returned as `BID`. A requester can therefore have
multiple operations in flight and identify completions even when different ID
streams are interleaved or reordered within the protocol's ordering rules.

Three boundaries matter:

1. AXI4-Lite has no IDs, so returned responses are interpreted in issue order.
2. AXI4 has address IDs and response IDs, but it removed AXI3's write-data ID.
3. The `WID` label visible in the following write-data lesson is AXI3 context,
   not an AXI4 or AXI4-Lite port.

Pipelining is not the same as a burst. A burst sends multiple beats under one
address request; pipelining keeps multiple distinct transactions outstanding.

### Video 49 - Understanding the write data channel

![Full-screen write-data waveform with WVALID, WREADY, WDATA, WSTRB, WID, WLAST, byte lanes, and channel directions](../images/Day%2002/49-write-data-channel-35.png)

Each write-data beat is accepted on:

$$
\text{w\_fire}=\text{WVALID}\land\text{WREADY}
$$

The four colored `WDATA` values are four full-AXI beats. `WLAST` is asserted
with the final beat and must remain asserted with that beat if it stalls. It is
not a pulse sent after the data.

The 32-bit `WDATA` bus is divided into four byte lanes:

| `WSTRB` bit | Enabled `WDATA` byte |
|---:|---|
| `WSTRB[0]` | `WDATA[7:0]` |
| `WSTRB[1]` | `WDATA[15:8]` |
| `WSTRB[2]` | `WDATA[23:16]` |
| `WSTRB[3]` | `WDATA[31:24]` |

A strobe bit of `1` means that byte lane is valid for the write; `0` means the
slave must not update that byte. During `WVALID && !WREADY`, `WDATA`, `WSTRB`,
and `WLAST` must all remain stable.

#### Worked partial-write example

Assume a 32-bit register currently contains `0xA1B2C3D4`. The Manager offers:

```text
WDATA = 0x11223344
WSTRB = 4'b0101
```

Only lanes 0 and 2 are enabled. Lane 0 replaces bits `[7:0]` with `0x44`, and
lane 2 replaces bits `[23:16]` with `0x22`. Lanes 1 and 3 retain their old
values, so the stored word becomes:

```text
old    = A1 B2 C3 D4
write  = 11 22 33 44
strobe =  0  1  0  1
result = A1 22 C3 44 = 0xA122C344
```

For byte lane $i$, the hardware merge is:

$$
Q_{next}[8i+7:8i]=
\begin{cases}
WDATA[8i+7:8i], & WSTRB[i]=1\\
Q[8i+7:8i], & WSTRB[i]=0
\end{cases}
$$

This is why `WSTRB` is not a “valid for the whole word” flag. It is a bank of
per-byte write enables, and it must be captured with the exact `WDATA` beat
when that beat is accepted.

The frame includes `WID=id0`. That is AXI3 terminology. AXI4 removed `WID`, so
write data follows the ordering rules associated with accepted write
addresses. AXI4-Lite removes both `WID` and `WLAST`; it keeps only the one-beat
`WDATA`/`WSTRB` payload and its `WVALID`/`WREADY` handshake.

![Full-screen relationship among AWADDR, AWSIZE, AWBURST, AWLEN, four data beats, and burst encodings](../images/Day%2002/49-write-data-channel-85.png)

This final frame reconnects the data beats to their address command. `AWSIZE`
sets bytes per beat, `AWLEN+1` sets the beat count, and `AWBURST` determines how
successive addresses are generated. These are full-AXI burst controls. In
AXI4-Lite the same conceptual write collapses to one address transfer and one
data transfer; byte-level partial updates still use `WSTRB`.

#### Write-channel independence checkpoint

For one AXI4-Lite write, the master may complete the AW handshake first, the W
handshake first, or both on the same edge. The slave records whichever arrives
and produces a write response only after it has accepted both pieces. The
details of the `B` response channel begin in lesson 50 and are intentionally
left for the next update.

#### Hardware state implied by independent arrival

A simple one-outstanding AXI4-Lite Subordinate therefore needs two independent
capture flags and their payload registers:

- `have_aw` plus `awaddr_q`/`awprot_q` for an accepted address;
- `have_w` plus `wdata_q`/`wstrb_q` for accepted write data.

Using the pre-edge flags, the input set becomes complete on an edge when:

$$
\text{write\_inputs\_complete}=
(\text{have\_aw}\lor\text{aw\_fire})
\land
(\text{have\_w}\lor\text{w\_fire})
$$

This expression covers all three legal orders: stored AW followed by W, stored
W followed by AW, or both handshakes on the same edge. A design that commits
only when `aw_fire && w_fire` is true in one cycle will lose or deadlock legal
transactions whose two channels arrive separately. The later `B`-channel
lesson will determine how and when these one-entry captures are released; that
response behavior is deliberately not pre-empted here.

## Section 4 points to remember

- Count events per channel using `VALID && READY`; do not treat a whole
  transaction as one universal handshake.
- Full AXI `AxLEN` stores beats minus one, so `AxLEN=3` means four beats.
- AXI4-Lite is single-beat and has no burst, ID, or last-beat signals.
- `AWVALID` cannot wait for `AWREADY`, and AW payload stays stable while stalled.
- AW and W are independent channels; a slave must accept either order.
- `WSTRB` has one bit per byte lane and controls which bytes are written.
- `WID` is AXI3-only; `WLAST` exists in AXI4 full but not AXI4-Lite.
- Pipelining means multiple outstanding transactions; bursting means multiple
  data beats controlled by one address request.

## Active-recall checkpoint

1. If `ARLEN=3`, how many read-data beats follow and why?
2. Which edge accepts a write address?
3. What must remain stable while `AWVALID=1` and `AWREADY=0`?
4. Why can write data legally arrive before the write address handshake?
5. What does `AWSIZE=2` encode?
6. Which `WSTRB` bit controls `WDATA[23:16]`?
7. Why is `WID` not a valid AXI4-Lite signal?
8. What is the difference between a four-beat burst and four pipelined
   single-beat transactions?
9. Which full-AXI signals disappear when the interface is reduced to
   AXI4-Lite?

[Return to the course hub](README.md).
