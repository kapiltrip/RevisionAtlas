# Section 4 - Getting Started with AXI4-Lite

[Previous: Section 3](Section%2003%20-%20AXI-Stream%20IPs.md) | [Course hub](../Course%20Atlas.md) | [AXI chapter](../README.md) | [Next: Section 5](Section%2005%20-%20AXI4-Lite%20Single%20Beat%20without%20Pipeline%20-%20Waveform%20Approach.md)

**Course status:** 10/10 lessons complete, covering lessons 45-54.

The section first separates transaction, burst, beat, and channel-transfer
language. It then walks all five memory-mapped channels, the four response
encodings, and the final AXI4-Lite signal set. The page continually removes
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

![Full-screen Section 4 agenda for beat, transfer, transaction, channels, signals, and AXI-Lite](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2002/45-axi-lite-agenda-50.png)

The agenda gives the correct learning order. First decide what event is being
counted; then separate the five memory-mapped channels; then learn the payload
on each channel; finally remove the full-AXI features that AXI4-Lite does not
need. The section therefore begins with full-AXI examples as scaffolding before
arriving at the Lite subset.

### Video 46 - Transaction versus beat versus transfer

![Full-screen handwritten transaction and multi-beat transfer model above a read-burst waveform](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2002/46-transaction-beat-transfer-20.png)

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

![Full-screen four-beat read waveform with AR address/control and R data/response channels](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2002/46-transaction-beat-transfer-55.png)

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

#### Handwritten page 25 - Transaction, beat, transfer, and write address

![Handwritten AXI notes: Transaction, beat, transfer, and write address](../../../../_internal/Protocols/04%20AMBA/03%20AXI/handwritten/images/25-axi-transaction-beat-and-write-address.jpg)

**Explanation:** A transaction contains its address, data beat or beats, and
response; a beat is one data-channel transfer. Bytes are lanes within a beat,
not separate AXI transactions, and the write-address channel carries the control
for the data sequence.

### Video 47 - Understanding the write address channel

![Full-screen write-address waveform annotated with address, size, burst, length, ID, and encoding tables](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2002/47-write-address-channel-85.png)

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

#### Handwritten page 26 - Write-address burst attributes

![Handwritten AXI notes: Write-address burst attributes](../../../../_internal/Protocols/04%20AMBA/03%20AXI/handwritten/images/26-axi-write-address-burst-attributes.jpg)

**Explanation:** `AWSIZE` encodes `log2(bytes_per_beat)` and `AWLEN+1` gives the
number of beats. Burst type, length, and ID are AXI4 features; AXI4-Lite removes
bursts and transaction IDs.

#### Handwritten page 27 - Single-beat pipelining and read addressing

![Handwritten AXI notes: Single-beat pipelining and read addressing](../../../../_internal/Protocols/04%20AMBA/03%20AXI/handwritten/images/27-single-beat-pipelining-and-read-address.jpg)

**Explanation:** The page contrasts waiting for a complete transaction with
accepting a following address early. Pipelining changes throughput and required
buffering, not the channel handshake rules, which remain independent in both
implementation styles.

### Video 48 - Understanding channel IDs

![Full-screen comparison of non-pipelined and pipelined single-beat request/response timing](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2002/48-channel-ids-20.png)

Without pipelining, the requester waits for the response to address $a_0$
before sending $a_1$. The link is simple but round-trip latency creates idle
cycles. With pipelining, the requester can issue $a_1$ before response $d_0$
returns, increasing the number of outstanding transactions and improving
throughput.

![Full-screen pipelined waveform using request and response IDs to associate returned data](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2002/48-channel-ids-55.png)

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

![Full-screen write-data waveform with WVALID, WREADY, WDATA, WSTRB, WID, WLAST, byte lanes, and channel directions](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2002/49-write-data-channel-35.png)

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
Subordinate must not update that byte. During `WVALID && !WREADY`, `WDATA` and
`WSTRB` remain stable. Full AXI also holds `WLAST` with that stalled beat;
AXI4-Lite has no `WLAST` signal.

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

![Full-screen relationship among AWADDR, AWSIZE, AWBURST, AWLEN, four data beats, and burst encodings](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2002/49-write-data-channel-85.png)

This final frame reconnects the data beats to their address command. `AWSIZE`
sets bytes per beat, `AWLEN+1` sets the beat count, and `AWBURST` determines how
successive addresses are generated. These are full-AXI burst controls. In
AXI4-Lite the same conceptual write collapses to one address transfer and one
data transfer; byte-level partial updates still use `WSTRB`.

#### Write-channel independence checkpoint

For one AXI4-Lite write, the master may complete the AW handshake first, the W
handshake first, or both on the same edge. The slave records whichever arrives
and produces a write response only after it has accepted both pieces.

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
transactions whose two channels arrive separately.

#### Handwritten page 28 - Write data, byte strobes, IDs, and last

![Handwritten AXI notes: Write data, byte strobes, IDs, and last](../../../../_internal/Protocols/04%20AMBA/03%20AXI/handwritten/images/28-write-data-byte-strobes-ids-and-last.jpg)

**Explanation:** `WSTRB` qualifies byte lanes of `WDATA`. `WID` belongs to AXI3
rather than AXI4, while `WLAST` belongs to burst-capable AXI4; AXI4-Lite has
neither IDs nor a last marker because every transaction is single beat.

### Video 50 - Understanding the write response channel

![Original full-frame write response waveform and master/slave channel directions](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/050-understanding-write-response-channel-25.png)

The upper waveform finishes the write transaction. The address and data have
their own acceptance edges; the Subordinate then returns one `BRESP` value on
the B channel. The response transfer is:

$$
\text{b\_fire}=\text{BVALID}\land\text{BREADY}
$$

The frame's direction arrows are the quickest ownership check:

- the Subordinate drives `BVALID` and `BRESP`;
- the Manager drives `BREADY`;
- while `BVALID=1` and `BREADY=0`, the Subordinate must keep `BRESP` stable;
- the response is complete only at a rising edge with `b_fire=1`.

For a single-outstanding teaching slave, `BVALID` is raised only after both the
AW and W handshakes have occurred. It must not be a one-cycle pulse: if the
Manager is not ready, `BVALID` remains asserted. After `b_fire`, the slave can
clear `BVALID`, release its captured address/data flags, and accept the next
write according to its buffering policy.

The B channel has no data payload. It reports the status of the completed write
and, in full AXI, can return `BID`. AXI4-Lite has no IDs, so it contains only
`BRESP`, `BVALID`, and `BREADY`.

### Video 51 - The four response encodings

![Original full-frame AXI response-code table, special-operation notes, and interface diagram](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/051-different-types-of-response-25.png)

`BRESP[1:0]` and `RRESP[1:0]` use the same four encodings:

- `2'b00`, **OKAY**: normal success, and also the response used for an
  exclusive access that did not obtain exclusive success;
- `2'b01`, **EXOKAY**: successful exclusive access;
- `2'b10`, **SLVERR**: the addressed endpoint was reached but could not
  complete the requested operation successfully;
- `2'b11`, **DECERR**: no endpoint accepted the address, normally reported by
  an interconnect decode path.

The critical AXI4-Lite correction is that Lite does not support exclusive
accesses, so `EXOKAY` is not a valid AXI4-Lite response. A Lite implementation
uses `OKAY`, `SLVERR`, and `DECERR` as appropriate. Neither error code commands
an automatic retry; retry, logging, exception handling, or software recovery
is a system policy outside the handshake itself.

The response must describe the exact accepted operation. A slave cannot change
`BRESP` or `RRESP` while its corresponding `VALID` is stalled, and a checker or
scoreboard should sample the response only on the relevant response-channel
handshake.

#### Handwritten page 29 - Write responses and channel directions

![Handwritten AXI notes: Write responses and channel directions](../../../../_internal/Protocols/04%20AMBA/03%20AXI/handwritten/images/29-write-response-codes-and-channel-directions.jpg)

**Explanation:** The page records the two-bit response encodings and the five
channel directions. The Subordinate owns `BVALID` and `BRESP`; the Manager owns
`BREADY`, and their handshake retires the write response.

### Video 52 - Read address and read data channels, part 1

![Original full-frame read-address and read-data waveforms beside the AXI master/slave diagram](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/052-understanding-read-address-and-data-channel-p1-25.png)

The top half separates request from return data. The Manager offers the address
on AR and the Subordinate returns data later on R:

$$
\text{ar\_fire}=\text{ARVALID}\land\text{ARREADY}
$$

$$
\text{r\_fire}=\text{RVALID}\land\text{RREADY}
$$

On full AXI, the AR payload can include `ARID`, `ARLEN`, `ARSIZE`, `ARBURST`,
`ARLOCK`, `ARCACHE`, `ARPROT`, `ARQOS`, `ARREGION`, and user-defined sideband
bits. AXI4-Lite retains the single-beat request essentials: `ARADDR`, optional
`ARPROT`, `ARVALID`, and `ARREADY`.

Once `ar_fire` occurs, a simple slave captures the address or immediately
decodes it. The read-data source must then assert `RVALID` when `RDATA` and
`RRESP` are available; it must not wait for `RREADY` before asserting
`RVALID`. If the Manager stalls, `RDATA`, `RRESP`, and any associated ID/last
information remain stable until `r_fire`.

#### Handwritten page 30 - Read channels and memory-mapped signals

![Handwritten AXI notes: Read channels and memory-mapped signals](../../../../_internal/Protocols/04%20AMBA/03%20AXI/handwritten/images/30-read-channels-and-memory-mapped-signal-set.jpg)

**Explanation:** The read-address request travels Manager to Subordinate, while
read data and response return on the `R` channel. IDs, burst length, size, type,
and `RLAST` apply to full AXI; the Lite boundary removes them.

### Video 53 - Read address and read data channels, part 2

![Original full-frame completed AXI read waveform with request, data, response, ID, and last-beat timing](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/053-understanding-read-address-and-data-channel-p2-75.png)

The completed waveform makes the burst distinction visible. One accepted AR
command can produce several accepted R beats. In full AXI:

- `RID` associates each returned beat with its request ID;
- `RRESP` is carried on every read-data beat;
- `RLAST` is asserted with the final beat of the burst;
- every accepted beat advances only on `r_fire`, not merely because the clock
  advanced.

If the final beat stalls, `RLAST=1`, its `RDATA`, `RRESP`, and `RID` are one
held payload. `RLAST` cannot be pulsed and withdrawn before acceptance.

AXI4-Lite removes `RID`, `RLAST`, and all burst controls. One AR handshake
corresponds to one R handshake. Because Lite has no IDs, a one-outstanding
master is the natural teaching model; a more capable implementation can queue
requests, but responses still obey the ordered Lite model.

### Video 54 - The complete AXI4-Lite signal set

![Original full-frame five-channel AXI4-Lite waveform and complete signal-direction reference](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/054-axi-lite-signals-75.png)

This frame is the final cleanup pass. The interface has five independent
channels but one common clock/reset domain:

- **AW:** Manager drives address/protection/valid; Subordinate drives ready.
- **W:** Manager drives data/strobes/valid; Subordinate drives ready.
- **B:** Subordinate drives response/valid; Manager drives ready.
- **AR:** Manager drives address/protection/valid; Subordinate drives ready.
- **R:** Subordinate drives data/response/valid; Manager drives ready.

The independence is channel-level, not transaction-level. A write still links
one accepted AW item, one accepted W item, and one accepted B response. A read
links one accepted AR item and one accepted R result. The implementation needs
state that preserves those relationships across different cycle timings.

`ACLK` samples all channel handshakes on rising edges. `ARESETn` is active LOW;
interface `VALID` outputs must be deasserted during reset, and reset release
must be synchronized to the clock. AXI4-Lite does not add burst length, burst
type, ID, or last-beat ports. If those names appear in a supposed Lite module,
recheck whether the module is really full AXI or whether unnecessary signals
were copied from a template.

#### Handwritten page 31 - AXI4-Lite signal set and implementation configurations

![Handwritten AXI notes: AXI4-Lite signal set and implementation configurations](../../../../_internal/Protocols/04%20AMBA/03%20AXI/handwritten/images/31-axi-lite-signal-set-and-configurations.jpg)

**Explanation:** This summary reduces the interface to the five Lite channels
and lists common implementation profiles. A read-only or write-only endpoint may
omit unused channels, but every retained channel still follows the same
`VALID`/`READY` contract.

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
- A write response is issued only after the write address and write data have
  both been accepted.
- `BRESP` and `RRESP` remain stable with their `VALID` signal during a stall.
- AXI4-Lite does not support exclusive accesses, so it does not return
  `EXOKAY`.
- `RDATA`, `RRESP`, and `RVALID` belong to one held read-result payload.

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
10. What two input handshakes must complete before a slave can issue `BVALID`?
11. Why is `EXOKAY` not a valid AXI4-Lite response?
12. Which block normally originates `DECERR`?
13. What must remain stable while `RVALID=1` and `RREADY=0`?
14. Why is `RLAST` absent from AXI4-Lite?

[Continue to Section 5](Section%2005%20-%20AXI4-Lite%20Single%20Beat%20without%20Pipeline%20-%20Waveform%20Approach.md).
