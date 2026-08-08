# AXI Notes — Day 01

[Back to AXI](../03%20AXI/README.md) | [Back to AMBA](../README.md) | [AXI questions](AXI%20Questions.md)

This is Layer 1 of the AXI notes. It follows the completed Namaste FPGA lessons
in their original order and stops at **33. Code**, immediately before
**Implementing AXIS Arbiter P1**. Every course image below is a real frame
captured from the lesson video. The explanations use the lecture as the teaching path and the
[Arm AXI-Stream specification](../03%20AXI/sources/ARM-IHI-0051B-AMBA-AXI-Stream-Protocol-Specification.pdf)
as the authority.

## Day map

- [Videos 1-4 — interface selection and memory-mapped channels](#section-1---introduction-to-axi)
- [Videos 5-9 — `VALID`/`READY`, source/sink RTL, and waveform verification](#video-5---understanding-validready)
- [Videos 11-28 — AXI-Stream signals, packets, stalls, RTL, and integration](#section-2---axi-stream-interface-fundamentals)
- [Videos 29-33 — round-robin arbitration and code review](#video-29---section-3-agenda)
- [Standards audit — details the lesson examples omit](#arm-ihi-0051b-standards-audit)

Lessons 10, 22, 26, 28, and 33 are code resources rather than videos. The four
code resources in the completed implementation path are rendered below because
their exact RTL and testbench behavior are part of the revision boundary.

## The trace rule used throughout this page

For any channel, write:

$$
\text{fire} = \text{VALID} \land \text{READY}
$$

Evaluate `fire` at the rising edge. A clock edge alone does not move data. When
`VALID=1` and `READY=0`, the offered information is stalled and must remain
unchanged. This single rule is the bridge from the early generic handshake
videos to `TVALID`, `TREADY`, `TDATA`, and `TLAST` in AXI-Stream.

## Section 1 - Introduction to AXI

### Video 1 - Agenda

![Agenda listing AXI interface types and the valid-ready implementation](images/AXI/Day%2001/01-agenda-50.png)

The agenda has two branches. The first asks which AXI interface matches an
application. The second asks how all AXI channels move information safely.
That order is useful: first choose the communication model, then implement its
flow control.

The phrase “AXI memory” in the lesson should be read as an AXI **memory-mapped
interface**, not as a special kind of storage cell. AXI defines how a component
requests and completes an addressed access. The component behind that interface
could be SRAM, DDR control logic, a GPIO register bank, or another interconnect.

The three interfaces introduced are:

- AXI4-Stream for ordered, unaddressed data flow;
- AXI4-Lite for simple single-beat register accesses;
- AXI4 for memory-mapped bursts, IDs, and multiple outstanding work when those
  features are implemented.

The handshake is the common foundation. AXI4 and AXI4-Lite repeat the
`VALID`/`READY` pair independently on each channel; AXI-Stream applies it to the
stream transfer itself.

**Recall:** Why is “AXI memory” an interface description rather than a memory
technology?

### Video 2 - Use cases of the AXI interfaces

![AXI family comparison and ADC-to-FIR signal-processing path](images/AXI/Day%2001/02-axi-family-use-cases-30.png)

The right side shows the cleanest AXI-Stream mental model: samples leave an ADC,
enter an FIR filter, and continue in one direction. The filter does not need a
new destination address with every sample. It needs the next sample plus a way
to pause the producer if its pipeline cannot accept one.

![Processor, register peripheral, and the AXI family selection table](images/AXI/Day%2001/02-axi-family-use-cases-72.png)

The processor-to-peripheral drawing represents a different problem. A processor
must identify *which* peripheral register to access and whether it is reading or
writing. That requires a memory map, addresses, response information, and
separate read/write directions.

| Application question | Natural choice | Reason |
|---|---|---|
| Are samples moving through a fixed DSP chain? | AXI4-Stream | No per-beat address is needed; back-pressure controls the flow. |
| Is software configuring a small register bank? | AXI4-Lite | Single-beat addressed operations match control/status traffic. |
| Is a DMA engine moving blocks to or from DDR? | AXI4 | Bursts amortize address overhead and support high throughput. |
| Does a stream need to reach DDR? | AXI4-Stream plus DMA | The stream terminates at a DMA that creates memory-mapped AXI transactions. |

The lecture calls AXI-Stream “point-to-point.” That is correct for one interface,
but it is not a whole-system limitation. The specification explicitly permits
an interconnect between multiple stream components. `TDEST`, arbitration, and
switching can route packets while each individual link remains one Transmitter
to one Receiver.

**Pitfall:** AXI4-Lite is not for “one bit” only. Its standard data-bus widths
are 32 or 64 bits; “Lite” means no bursts and a simpler memory-mapped feature
set.

### Video 3 - Interface pins

![Lecture comparison of the AXI-Stream, AXI4-Lite, and AXI4 signal groups](images/AXI/Day%2001/03-interface-pins-28.png)

![Expanded AXI4 signal-group comparison](images/AXI/Day%2001/03-interface-pins-72.png)

![Fullscreen interface-pin comparison without the course sidebar or player controls](images/AXI/Day%2001/03-interface-pins-fullscreen.png)

The growing blocks in the frames are directionally correct: AXI-Stream can be
very small, AXI4-Lite adds five memory-mapped channels, and AXI4 adds burst,
identifier, and transaction-attribute signals. The exact totals shown in the
lecture—11, 19, and 43—are examples for particular configurations, not constants
of the protocols.

Pin count changes with:

- `TDATA`, address, and memory-mapped data widths;
- whether stream qualifiers such as `TKEEP`, `TSTRB`, or `TLAST` are present;
- the widths of `TID`, `TDEST`, and `TUSER`;
- the AXI4 ID width and supported transaction attributes.

This matters in RTL reviews. Saying “AXI-Stream has 11 pins” can cause an
integration error when one IP includes `TLAST`/`TKEEP` and the other omits them,
or when two components disagree on `TDATA` width. Compare the actual interface
properties and signal widths.

**Recall:** Which two kinds of width make a fixed AXI pin count impossible?

### Video 4 - Simple memory versus AXI memory

![Simple memory drawing and the four missing-control questions](images/AXI/Day%2001/04-simple-vs-axi-memory-30.png)

The whiteboard lists four questions: when write/read data is valid, when an
address is valid, whether an update succeeded, and whether the target can accept
work. A bare address/data bundle does not answer them. It needs an external
timing convention or explicit controls.

![Five AXI memory-mapped channels with separate timing waveforms](images/AXI/Day%2001/04-simple-vs-axi-memory-72.png)

AXI solves the interface problem with five independent channels:

| Channel | Direction | Information | Completion condition |
|---|---|---|---|
| `AW` | Manager to Subordinate | Write address and attributes | `AWVALID && AWREADY` |
| `W` | Manager to Subordinate | Write data and byte strobes | `WVALID && WREADY` |
| `B` | Subordinate to Manager | Write response | `BVALID && BREADY` |
| `AR` | Manager to Subordinate | Read address and attributes | `ARVALID && ARREADY` |
| `R` | Subordinate to Manager | Read data and response | `RVALID && RREADY` |

The write-address and write-data handshakes are independent. A correct
Subordinate cannot assume that `AW` and `W` are accepted in one fixed order; it
must buffer or coordinate them safely. In AXI4, the Subordinate must not assert
`BVALID` until it has accepted the write address and the final write-data
transfer marked by `WLAST`; AXI4-Lite has one write-data transfer and no burst
`WLAST`. On reads, the Subordinate asserts `RVALID` only after the read-address
handshake, and the transfer completes when the Manager also asserts `RREADY`.
These dependencies are defined in
[Arm IHI 0022H](https://developer.arm.com/-/media/Arm%20Developer%20Community/PDF/IHI0022H_amba_axi_protocol_spec.pdf).

Two lecture simplifications need care:

1. A non-AXI SRAM interface can still have enable, write-enable, byte-enable,
   and ready/busy signals. AXI's value is standardization and decoupling, not
   being the only possible valid interface.
2. A non-`OKAY` response is not simply “memory empty” and does not automatically
   command a retry. `SLVERR` and `DECERR` have defined protocol meanings;
   recovery is a system decision.

More precisely, `SLVERR` says the access reached a Subordinate but the
Subordinate could not complete it successfully. `DECERR` is normally generated
by an interconnect when it cannot decode a valid route to a Subordinate.
`EXOKAY` belongs to successful exclusive-access handling in full AXI and is not
a normal AXI4-Lite response. None of these response encodings empties memory or
automatically reissues the transaction.

### Video 5 - Understanding `VALID`/`READY`

![Source-to-destination valid-ready waveform beside the Arm rule excerpt](images/AXI/Day%2001/05-handshake-fundamentals-30.png)

![Three legal relative timings for valid and ready](images/AXI/Day%2001/05-handshake-fundamentals-72.png)

![Fullscreen valid-ready timing and the three handshake rules](images/AXI/Day%2001/05-handshake-fullscreen.png)

The first frame connects the abstract words to pins. The source drives the
information and `VALID`; the destination drives `READY` in the opposite
direction. A transfer is not “in progress” merely because one of them is HIGH.
It is accepted on a rising edge where both are HIGH.

Trace the common delayed-ready case:

| Edge | `VALID` | `READY` | Result |
|---:|:---:|:---:|---|
| $E_0$ | 0 | 0 | No offer, no transfer. |
| $E_1$ | 1 | 0 | Data $D_0$ is offered but stalled. |
| $E_2$ | 1 | 0 | Still stalled; $D_0$ and all qualifiers must match $E_1$. |
| $E_3$ | 1 | 1 | $D_0$ is accepted exactly once. |
| $E_4$ | 1 | 1 | A new beat $D_1$ may be accepted if the source presents it. |

The destination register normally changes just after $E_3$ because sequential
logic sampled the inputs at that edge. That visible post-edge change is the
effect of the transfer, not a second transfer.

### Video 6 - `VALID`/`READY` rules

![Handshake rule slide with the source and destination waveform](images/AXI/Day%2001/06-handshake-rules-28.png)

![Ready-before-valid, valid-before-ready, and simultaneous cases](images/AXI/Day%2001/06-handshake-rules-72.png)

![Fullscreen handshake-rule frame with source and destination ownership](images/AXI/Day%2001/06-handshake-rules-fullscreen.png)

The frames show three legal orderings:

- `VALID` first: the source holds the offered information until `READY` arrives;
- `READY` first: the destination advertises capacity and accepts in the first
  cycle where `VALID` arrives;
- simultaneous: both rise for the same edge and the transfer completes there.

The most important correction is that the rule is **not symmetric**. Arm says
the Transmitter must not wait for `TREADY` before asserting `TVALID`, because two
waiting endpoints could deadlock. The Receiver is permitted to wait for
`TVALID` before asserting `TREADY`, although doing so adds latency. Once
`TVALID` is HIGH, both `TVALID` and the complete offered information remain
unchanged until the handshake.

Use this implementation checklist:

- generate `VALID` from local availability, not from `READY`;
- advance the source pointer only on `VALID && READY`;
- if stalled, hold payload and sidebands;
- let a Receiver assert `READY` early when it truly has capacity;
- avoid an unregistered combinational path that runs from an interface input
  through the component to an interface output and creates a long or cyclic
  path at integration.

### Video 7 - Handshake RTL part 1

![Two-state source flowchart beside the initial Verilog](images/AXI/Day%2001/07-handshake-rtl-p1-20.png)

![Source reset and new-data state logic](images/AXI/Day%2001/07-handshake-rtl-p1-50.png)

![Wait-for-receiver state holding valid until ready](images/AXI/Day%2001/07-handshake-rtl-p1-82.png)

The source FSM has a “new data” state and a “wait for slave” state. When data is
available, it loads `M_data`, asserts `M_valid`, and moves to the waiting state.
While `S_ready` is LOW, it remains there, which holds the same data and valid
offer. When `S_ready` is HIGH at an edge, the transfer fires and the FSM can
return for another item.

This design demonstrates correctness under a stall, but it is not a
full-throughput source. Returning through a separate “new data” state can insert
a bubble between accepted items. A streaming source with data always available
can instead keep `VALID` asserted and replace the payload after every fire edge.

The frame also shows `$urandom_range`, which is excellent for a testbench but is
not ordinary portable synthesizable payload-generation logic. Keep random
stimulus in verification code; production RTL receives or computes real data.

**State invariant:** in the wait state, if `S_ready=0`, the next edge must not
change `M_data` or deassert `M_valid`.

### Video 8 - Handshake RTL part 2

![Receiver flowchart: ready, wait for valid, and receive](images/AXI/Day%2001/08-handshake-rtl-p2-20.png)

![Receiver wait-for-data state and data capture](images/AXI/Day%2001/08-handshake-rtl-p2-52.png)

![Receiver process-data state returning to readiness](images/AXI/Day%2001/08-handshake-rtl-p2-84.png)

The Receiver raises `S_ready` while it has storage, waits for `M_valid`, captures
`M_data`, lowers ready while “processing,” and later returns to the ready state.
In the shown wait state, `S_ready` is already HIGH, so testing `M_valid` is
equivalent to testing `M_valid && S_ready`. Writing the full fire condition in
reusable RTL is safer because it remains correct if ready-generation changes.

The extra process state deliberately models a Receiver that needs time between
items. It therefore creates back-pressure and cannot accept one item every
clock. A one-entry register with no downstream consumption also needs such a
pause; a FIFO or skid buffer lets the interface accept more items while earlier
ones are processed.

Do not lower `READY` merely because `VALID` became HIGH before the acceptance
edge. The transfer event is the edge where both are HIGH. After that edge, the
registered FSM may lower `READY` for the following cycle.

### Video 9 - Verifying the handshake

![Simulation during reset and the first ready state](images/AXI/Day%2001/09-verify-handshake-18.png)

![Waveform where valid and ready overlap for acceptance](images/AXI/Day%2001/09-verify-handshake-52.png)

![Post-edge Receiver data update in the verification waveform](images/AXI/Day%2001/09-verify-handshake-84.png)

Read the waveform from left to right:

1. Active-LOW reset forces data, valid, ready, and the captured Receiver value
   to their reset values.
2. After reset is released, the empty Receiver raises ready.
3. The source independently raises valid and presents $D_0$.
4. At the first rising edge where both are HIGH, $D_0$ transfers.
5. The Receiver register displays $D_0$ after that edge. The source may prepare
   the next item without waiting for the displayed register trace to settle.

The useful verification question is not “did both signals ever become HIGH?”
It is “how many rising edges had both HIGH, and which payload was stable for
each?” A stronger self-checking testbench would also assert:

```systemverilog
// Conceptual properties; signal names follow the generic demo.
valid && !ready |=> valid && $stable(data);
accepted_count == count_rising_edges(valid && ready);
```

The first property expresses stall stability. A complete AXI-Stream property
would include every sideband signal, not only `data`.

## Section 2 - AXI-Stream interface fundamentals

### Video 11 - AXI-Stream agenda

![Agenda for signals, AXI-Stream transactions, and master/slave RTL](images/AXI/Day%2001/11-agenda.png)

The second-section agenda moves from vocabulary to hardware in three steps:
identify the signals, understand write/read-style stream movement, and then
build Transmitter and Receiver RTL. AXI-Stream itself is unidirectional, so
“read” and “write” here describe which component is providing or consuming the
stream; they are not separate AXI-Stream read and write channels like the five
memory-mapped AXI channels.

The course builds the Transmitter first and initially supplies `TREADY` from a
testbench. That isolation is useful: it forces the Transmitter to remain correct
for arbitrary Receiver back-pressure before another RTL block is connected.

### Video 12 - Typical signals part 1

![AXI-Stream waveforms and the first half of the official signal table](images/AXI/Day%2001/12-typical-signals-p1-25.png)

![Signal table with stream identifiers, destination, user, and wake-up context](images/AXI/Day%2001/12-typical-signals-p1-75.png)

![Fullscreen signal-table frame showing TID, TDEST, TUSER, and TWAKEUP](images/AXI/Day%2001/12-typical-signals-fullscreen.png)

The left side of the frames shows `TVALID`, `TREADY`, `TDATA`, `TKEEP`, and
`TLAST` changing together as one transfer bundle. The right side anchors the
lecture to the Arm signal table.

| Signal group | Deep meaning |
|---|---|
| `ACLK`, `ARESETn` | Interface inputs are sampled on rising `ACLK` edges and outputs change after rising edges. The protocol permits asynchronous reset assertion but requires synchronous deassertion. The course RTL chooses synchronous assertion as well because reset is tested only inside `always @(posedge ACLK)`. |
| `TVALID`, `TREADY` | The only signals needed to decide whether a transfer occurred. `TREADY` may be permanently HIGH only if the Receiver can truly accept every offered beat. |
| `TDATA` | Payload divided into byte lanes. Lane $x$ is `TDATA[(8x+7):8x]`; low-order lanes represent earlier byte positions in the stream. |
| `TKEEP`, `TSTRB` | Per-byte classification. They are optional when every lane always contains a data byte. |
| `TLAST` | The packet delimiter. It is asserted on the offered transfer that becomes the final transfer when accepted, so it remains asserted with that beat during a stall. |
| `TID` | Logical stream identity. It is not simply a video-row number; its precise meaning is defined by the system profile. |
| `TDEST` | Coarse routing information that an interconnect can use to select a destination. |
| `TUSER` | Application-defined metadata whose interpretation must be agreed by both endpoints. |

The lecture says `TWAKEUP` is outside AXI-Stream. The version distinction is:
AXI4-Stream Issue A has no `TWAKEUP`; AXI5-Stream Issue B adds it as an optional
wake-up signal. It indicates interface-associated activity and must not be
treated as another transfer handshake. This history is stated in
[Arm IHI 0051B](../03%20AXI/sources/ARM-IHI-0051B-AMBA-AXI-Stream-Protocol-Specification.pdf).

The small-print rules are also important. `TWAKEUP` must be glitch-free, may
assert before or after `TVALID`, and is recommended at least one cycle before
`TVALID`. If `TWAKEUP` and `TVALID` are HIGH together, `TWAKEUP` must remain
HIGH until `TREADY` is asserted. A Receiver may wait for `TWAKEUP` before
raising `TREADY`, so a Transmitter that implements wake-up but never asserts it
can deadlock the interface. These rules apply only when the AXI5-Stream
`Wakeup_Signal` property is enabled.

### Video 13 - Typical signals part 2

![Eight byte lanes with TKEEP qualification and the Arm qualifier text](images/AXI/Day%2001/13-typical-signals-p2-30.png)

![Position-byte example and the relationship between TKEEP and TSTRB](images/AXI/Day%2001/13-typical-signals-p2-72.png)

![Fullscreen TKEEP and TSTRB truth table beside the lecture padding example](images/AXI/Day%2001/13-byte-qualifiers-fullscreen.png)

Each qualifier bit maps to exactly one byte lane:

$$
\text{TKEEP}[x],\ \text{TSTRB}[x]
\longleftrightarrow
\text{TDATA}[(8x+7):8x]
$$

The complete truth table is:

| `TKEEP[x]` | `TSTRB[x]` | Byte type | Can an interconnect remove it? |
|:---:|:---:|---|:---:|
| 1 | 1 | Data byte | No |
| 1 | 0 | Position byte | No; its relative position carries information |
| 0 | 0 | Null byte | Yes |
| 0 | 1 | Reserved | Must not be generated |

For a 64-bit `TDATA`, eight `TKEEP` bits qualify eight byte lanes. If
`TKEEP=8'b1111_0000`, lanes 7:4 must be transported and lanes 3:0 are null. Be
careful when reading a hex word on paper: the leftmost displayed byte is the
most-significant lane, while AXI-Stream defines low-order bus bytes as earlier
bytes in a packed stream.

A position byte is not ordinary zero padding. Its `TDATA` value is irrelevant,
but its place relative to real data bytes must be preserved—for example during
a partial update. The course's Ethernet analogy is only motivational. A minimum
64-byte Ethernet frame includes header and FCS, so “four payload bytes plus 60
padding bytes” is not a generally valid frame calculation.

If an interface omits `TKEEP`, the protocol default is all ones. If it omits
`TSTRB`, `TSTRB` defaults to `TKEEP`. These defaults explain why many simple
FPGA streams expose `TKEEP` but not `TSTRB`.

### Video 14 - AXI-Stream use cases

![Five-channel memory-mapped AXI compared with a one-way stream path](images/AXI/Day%2001/14-use-cases-45.png)

![Lecture use-case slide showing the ADC, camera, audio, DMA, DDR, generator, and FIFO paths](images/AXI/Day%2001/14-use-cases-pipelines-context.png)

![Fullscreen AXI-Stream use cases with only the video frame visible](images/AXI/Day%2001/14-use-cases-fullscreen.png)

The first frame explains **why AXI-Stream exists**. Memory-mapped AXI carries an
address because a requester can choose among many memory locations or
registers. A fixed processing chain already has its route wired into the
hardware. An ADC connected to a filter does not need to say “send this sample
to the filter at address $A$” on every clock. The connection itself identifies
the next block. AXI-Stream can therefore concentrate on:

- the payload in `TDATA`;
- whether the payload is being offered and accepted through `TVALID` and
  `TREADY`;
- which byte lanes are meaningful through `TKEEP` and `TSTRB` when those
  signals are present; and
- boundaries or application metadata through `TLAST`, `TUSER`, `TID`, and
  `TDEST` when the chosen profile needs them.

The second frame is the lecture's actual use-case map. Each row solves a
different engineering problem, so the boxes must be understood rather than
memorized as names.

#### Decode the unfamiliar boxes first

| Box in the frame | What it physically or logically does | Why a stream fits |
|---|---|---|
| ADC | An analog-to-digital converter samples a changing voltage and produces a sequence of digital numbers. A $16$-bit ADC might create one signed sample every sample period. | Samples naturally arrive in time order. The next block normally wants the next sample, not a randomly addressed sample. |
| Digital filter | Computes a new output sample from the present and previous input samples. FIR and IIR filters are common examples. A pipelined filter can accept one sample each clock even when its first result appears several clocks later. | Input and output are ordered sequences. Handshaking lets the pipeline pause without losing or duplicating a sample, provided the implementation has enough internal storage. |
| Camera | Produces pixels in raster order: left-to-right across a line and then line-by-line across a frame. | Pixels are processed sequentially by colour converters, scalers, filters, or inference blocks. The stream carries pixels plus line/frame markers. |
| Transform | A deliberately generic image-processing block. It could perform colour-space conversion, resize, thresholding, convolution, edge detection, or another pixel operation. | Most transforms can begin processing a pixel before the complete frame has arrived, which avoids storing a full frame between every pair of blocks. |
| I2S interface | Converts the serial I2S audio wires—bit clock, left/right word-select clock, and serial data—into parallel PCM sample words, or performs the reverse conversion. | Once deserialized, left and right audio samples form an ordered, continuous sequence that is convenient to transport inside the FPGA. |
| AXI DMA | Direct-memory-access hardware that bridges AXI4-Stream and addressed AXI4 memory traffic. On the paths drawn in the frame, its stream-to-memory-mapped channel accepts beats and writes them into a configured DDR buffer. | The processing blocks remain address-free while the DMA handles addresses, bursts, buffer lengths, and memory writes. |
| DDR | External dynamic memory used to retain a block of samples, an image frame, or an audio buffer so software or another hardware engine can use it later. | DDR is memory-mapped, so it belongs on the addressed side of the DMA rather than directly on a simple stream link. |
| Generator | Any source that creates an ordered sequence: a DDS waveform generator, test-pattern generator, packet generator, or algorithmic producer. | It can expose each new generated value as a beat and obey back-pressure when the next block cannot accept it. |
| FIFO | A first-in, first-out buffer. It preserves order while temporarily absorbing a difference between producer and consumer timing. | Its input and output naturally use ready/valid. It creates elasticity without changing the order or contents of accepted beats. |

#### Use case 1 - ADC to filter to DMA to DDR

```text
analog voltage -> ADC -> digital filter -> AXI DMA (S2MM) -> DDR buffer
```

Suppose the ADC produces signed $16$-bit samples. An AXI-Stream wrapper can put
one sample in `TDATA[15:0]`, assert `TVALID`, and allow the filter to accept it
when the filter asserts `TREADY`. The filter transforms the ordered sample
sequence—for example, removing high-frequency noise—and offers the filtered
samples on its output stream. The DMA's **stream-to-memory-mapped**, or S2MM,
channel collects those accepted beats and writes them to addresses in a DDR
buffer configured beforehand by control logic or software.

The important address distinction is:

| Location | Is an address transferred? | Who knows the destination? |
|---|:---:|---|
| ADC-to-filter stream | No | The physical RTL connection fixes the filter as the Receiver. |
| Filter-to-DMA stream | No | The physical RTL connection fixes the DMA stream port as the Receiver. |
| DMA-to-DDR AXI4 side | Yes | The DMA obtains the base address and transfer length from its control state or descriptors. |

The DMA does **not** filter the samples. It is a transport engine that changes
the transaction model from ordered beats to addressed memory bursts. AMD's
[AXI DMA core overview](https://docs.amd.com/r/en-US/pg021_axi_dma/Core-Overview)
describes the S2MM and memory-mapped-to-stream directions explicitly.

There is a real-time caveat hidden by the clean diagram. Many ADCs cannot stop
the physical sampling clock merely because downstream `TREADY` becomes LOW. A
practical design therefore places a FIFO near the ADC, guarantees that the
whole path can sustain the sample rate, or defines an overflow policy. AXI
back-pressure protects a compliant digital source; it cannot retroactively stop
an unstalled physical event that has already produced a sample.

#### Use case 2 - Camera to transform to DMA to DDR

```text
camera pixels -> image transform -> AXI DMA or video DMA -> DDR frame buffer
```

The camera or its interface wrapper converts sensor timing into pixel beats.
`TDATA` can contain one pixel or several pixels per clock. The transform accepts
each pixel, processes it, and sends the result onward. Because the pipeline can
operate while the frame is still arriving, it avoids a full-frame memory write
and read between every image-processing stage.

Video gives the sideband signals a concrete meaning. In AMD's AXI4-Stream Video
profile:

| Signal | Meaning for the video stream |
|---|---|
| `TDATA` | One or more pixels, packed according to the selected video format |
| `TVALID && TREADY` | The pixel beat is accepted on this rising edge |
| `TUSER[0]` | Start of frame, aligned with the first accepted pixel of the frame |
| `TLAST` | End of line, aligned with the final accepted pixel of each scan line |

That `TLAST` meaning is worth noticing: in this video profile it marks the end
of a **line**, not the end of the whole frame. `TUSER[0]` identifies start of
frame. These meanings come from the application profile, not from base
AXI-Stream; see AMD's
[AXI4-Stream Video signaling guide](https://docs.amd.com/r/en-US/ug934_axi_videoIP/AXI4-Stream-Signaling-Interface).

After the transform, a DMA stores pixels in DDR so a processor, display path,
or later accelerator can access the completed frame. Video-oriented DMA or
frame-buffer IP is commonly used when two-dimensional details such as line
stride and multiple frame buffers matter. The lecture's `AXI DMA` label is a
useful conceptual bridge, but it should not be read as saying that every video
system uses the exact same DMA configuration.

A camera is another source that may be unable to tolerate arbitrary stalls.
The design must budget FIFO capacity and maximum stall time or provide an
explicit dropped-frame/error policy. Merely connecting `TREADY` does not create
infinite storage.

#### Use case 3 - Audio to I2S interface to DMA to DDR

```text
audio codec -> serial I2S -> I2S receiver -> AXI-Stream samples -> DMA -> DDR
```

I2S is the external serial audio protocol; AXI-Stream is the internal FPGA data
path. The I2S receiver uses the bit clock to collect serial bits and the
left/right word-select signal to determine the channel. Once a complete PCM
word is available, the wrapper can place it into `TDATA` and assert `TVALID`.
A wider beat might carry a left/right pair, while a narrower design might send
one channel sample per beat.

Base AXI-Stream does not prescribe how audio channels are encoded. A particular
design may use separate streams, pack both channels in `TDATA`, or attach a
channel identifier in `TUSER`. Similarly, `TLAST` could mark the end of a
software audio block, but it does not universally mean “right-channel sample.”
The producer and consumer must share the same convention.

The DMA writes the accepted PCM samples into a circular or block buffer in DDR.
Software can then record, analyze, mix, or retransmit the audio. Because the
codec's sample rate continues independently of temporary DDR or CPU delays, an
audio FIFO usually absorbs short bursts of back-pressure. If it fills, the
system needs a defined overrun response rather than silently corrupting the
stream.

#### Use case 4 - Generator through an AXI-Stream FIFO

```text
generator -> AXI-Stream FIFO -> downstream consumer
```

This row teaches **elasticity**. The generator and consumer can have uneven
instantaneous rates even when their long-term rates are compatible. The FIFO
accepts an input beat on:

$$
\text{input fire} = \text{s_axis_tvalid} \land \text{s_axis_tready}
$$

and removes an output beat on:

$$
\text{output fire} = \text{m_axis_tvalid} \land \text{m_axis_tready}
$$

While the FIFO has free entries, it can keep `s_axis_tready` HIGH. When full,
it lowers `s_axis_tready`, forcing a compliant generator to hold its current
beat. While at least one entry exists, it raises `m_axis_tvalid` and holds the
front entry stable until the consumer accepts it. A FIFO must preserve the
entire beat bundle—`TDATA`, `TKEEP`, `TLAST`, `TUSER`, and any other enabled
sideband—not just the payload.

A synchronous FIFO decouples short rate variations in one clock domain. An
asynchronous FIFO can additionally cross between unrelated clocks, but it needs
clock-domain-crossing pointer logic; ordinary ready/valid wires alone are not a
safe clock-domain crossing.

#### Same AXI-Stream signals, different application meanings

| Example | `TDATA` represents | A plausible `TLAST` boundary | Important warning |
|---|---|---|---|
| ADC acquisition | One sample or several packed samples | End of a configured acquisition block | The physical ADC might not be stallable. |
| AXI4-Stream Video profile | One or more pixels | End of each video line | Start of frame is carried by `TUSER[0]` in this profile. |
| Audio capture | One PCM sample or a packed channel pair | End of a software-defined audio block | Channel packing and markers are application conventions. |
| Generic packet data | Bytes or words from a packet | End of packet | `TKEEP` identifies valid lanes on a partial final beat. |
| FIFO | Whatever entered the FIFO | Exactly the boundary received at its input | The FIFO must preserve all enabled sidebands. |

This is the central lesson behind the examples: AXI-Stream standardizes **how
an ordered beat moves**, while the endpoint profile defines **what that beat
means**.

#### Common use-case traps

- “No address channel” does not mean “no destination.” A direct wire fixes the
  destination, and a stream interconnect can use `TDEST` for routing.
- A DMA is a bridge and data mover, not the algorithmic filter or transform.
- A FIFO absorbs only a finite amount of back-pressure; it does not repair an
  unsustainable average data rate.
- `TLAST` is not inherently end-of-frame, end-of-line, or end-of-audio-channel.
  Its application boundary must be defined by the interface profile.
- `TUSER` is application-defined in base AXI-Stream. The lecture's start-of-frame
  example is valid for a video profile, but it is not a universal meaning for
  every stream.

### Video 15 - AXI-Stream transactions

![DSP, camera, audio, and FIFO stream paths beside the minimal signal set](images/AXI/Day%2001/15-transactions-28.png)

![Minimal transaction path and the continuously ready packet waveform](images/AXI/Day%2001/15-transactions-72.png)

The minimal packet example transfers $D_0$, $D_1$, $D_2$, and $D_3$. When the
Receiver keeps `TREADY=1`, the Transmitter can maintain `TVALID=1` and present a
different beat every cycle. The final beat carries `TLAST=1`.

| Rising edge | `TVALID` | `TREADY` | `TDATA` | `TLAST` | Accepted beat |
|---:|:---:|:---:|---|:---:|---|
| $E_0$ | 1 | 1 | $D_0$ | 0 | $D_0$ |
| $E_1$ | 1 | 1 | $D_1$ | 0 | $D_1$ |
| $E_2$ | 1 | 1 | $D_2$ | 0 | $D_2$ |
| $E_3$ | 1 | 1 | $D_3$ | 1 | $D_3$, end of packet |

This is one beat per clock, the best possible throughput for one AXI-Stream
link. It is enabled by the absence of stalls, not merely by the absence of an
address channel. If the Receiver lowers `TREADY`, packet duration stretches but
the accepted beat sequence and packet boundary must remain identical.

`TVALID` does not have to stay HIGH across every clock of every legal packet;
gaps are permitted unless a stricter application profile forbids them. When
`TVALID` is HIGH and a beat is stalled, however, it cannot be withdrawn.

### Video 16 - Implementation approaches

This short lesson compares three engineering paths. Its saved frame was a blank
slide transition, so it is intentionally not embedded as a primary study image;
the technical comparison is preserved below instead of presenting an unreadable
capture.

| Approach | What is generated | Control | Main trade-off |
|---|---|---|---|
| Hand-written RTL | The designer writes protocol and application logic | Highest visibility over buffering, latency, and microarchitecture | Most design and verification effort |
| Vivado IP/template flow | A vendor-generated wrapper/template with insertion points | Good RTL access, but some structure is tool-generated | Faster integration with tool conventions |
| HLS | C/C++ behavior plus interface directives becomes RTL | Control comes through pragmas, scheduling constraints, and generated reports | Fast algorithm exploration; latency/resource results still require inspection |

“HLS gives less control” is too absolute. HLS exposes pipeline initiation
interval, latency, resource binding, and interface directives, but control is
expressed differently and generated RTL can be harder to reason about
cycle-by-cycle. Hand-written RTL is valuable here because the learning goal is
to see exactly why a beat counter advances or stalls.

Also, processors do not literally “only understand AXI.” In a Zynq device, AXI
is the standard interface exposed between the processing system and programmable
logic; the processor core itself executes an instruction set and participates
in several internal protocols.

### Video 17 - Waveforms part 1

![AXI-Stream master ports above three valid-ready timing scenarios](images/AXI/Day%2001/17-waveform-p1-30.png)

![Master output bundle and the delayed-ready portions of the waveform](images/AXI/Day%2001/17-waveform-p1-72.png)

The module boundary makes ownership explicit:

- inputs: `m_axis_aclk`, `m_axis_aresetn`, `newd`, and `m_axis_tready`;
- outputs: `m_axis_tvalid`, `m_axis_tdata`, and `m_axis_tlast`.

`newd` is not an AXI-Stream signal. It is a local command telling this teaching
source to start a fixed packet. A real design needs a contract for when `newd`
may be asserted, whether it is a pulse or level, and whether another command can
arrive while a packet is active.

The long waveform contains three cases:

1. Receiver always ready: every offered beat transfers immediately.
2. Receiver stalls in the middle: the current data and qualifiers freeze.
3. Receiver stalls on the final beat: `TLAST` freezes HIGH with that final data.

The third case is the best check for a broken master. A design that generates
`TLAST` as an unconditional one-clock pulse loses the packet boundary when
`TREADY=0` during that pulse.

### Video 18 - Waveforms part 2

![Complete three-case waveform with the no-back-pressure packet first](images/AXI/Day%2001/18-waveform-p2-30.png)

![No-back-pressure trace reaching the final D3 and TLAST beat](images/AXI/Day%2001/18-waveform-p2-75.png)

This lesson traces the first case in detail. After reset is released, the source
enters its transmit phase, raises `TVALID`, and presents $D_0$. Because
`TREADY=1`, that first beat fires. The source advances to $D_1$ for the next
edge, then $D_2$, and finally $D_3$ with `TLAST=1`.

The counter rule is:

$$
\text{count}_{next} =
\begin{cases}
\text{count}+1, & \text{if TVALID} \land \text{TREADY} \\
\text{count}, & \text{otherwise}
\end{cases}
$$

This formula works in both the fast and stalled cases. Coding “increment while
`TREADY` is HIGH” is only safe if the state guarantees `TVALID=1`; writing the
full fire term makes the design intent and verification condition obvious.

`TLAST` is asserted for the transfer containing $D_3$. The Receiver recognizes
the packet end only when that transfer is accepted, not merely when it observes
`TLAST` HIGH in a cycle with no handshake.

### Video 19 - Waveforms part 3

![Middle-of-packet stall beginning on D2](images/AXI/Day%2001/19-waveform-p3-22.png)

![D2 held across back-pressure until ready returns](images/AXI/Day%2001/19-waveform-p3-50.png)

![Final D3 and TLAST held together during the last-beat stall](images/AXI/Day%2001/19-waveform-p3-80.png)

![Fullscreen three-packet waveform with no stall, middle stall, and final-beat stall](images/AXI/Day%2001/19-waveforms-fullscreen.png)

The middle-stall trace is:

| Cycle | `TVALID` | `TREADY` | `TDATA` | `TLAST` | Action at edge |
|---:|:---:|:---:|---|:---:|---|
| 0 | 1 | 1 | $D_0$ | 0 | Accept $D_0$ |
| 1 | 1 | 1 | $D_1$ | 0 | Accept $D_1$ |
| 2 | 1 | 0 | $D_2$ | 0 | Stall; accept nothing |
| 3 | 1 | 0 | $D_2$ | 0 | Stall; values unchanged |
| 4 | 1 | 1 | $D_2$ | 0 | Accept $D_2$ once |
| 5 | 1 | 1 | $D_3$ | 1 | Accept final beat |

The final-stall case uses the same rule. Once the source offers
`TDATA=D3`, `TVALID=1`, and `TLAST=1`, all three remain unchanged until an edge
with `TREADY=1`. Lowering `TLAST` early would merge the final beat into the next
packet; changing `TDATA` would corrupt the payload; incrementing the counter
would skip the stalled beat.

“Hold all signals” means all information controlled by this transfer. `ACLK`,
reset, and the Receiver-owned `TREADY` are not held by the Transmitter. The held
bundle includes any implemented `TKEEP`, `TSTRB`, `TID`, `TDEST`, and `TUSER`.

### Video 20 - Building the AXI-Stream master

![Master ports and the ready/last flowchart](images/AXI/Day%2001/20-building-master-18.png)

![TX-state next-state logic checking ready and the final count](images/AXI/Day%2001/20-building-master-52.png)

![Synchronous state register and handshake-gated count logic](images/AXI/Day%2001/20-building-master-84.png)

![Fullscreen AXIS master next-state RTL around the ready-gated transmit state](images/AXI/Day%2001/20-building-master-fullscreen.png)

The design sends a fixed four-beat packet. It uses two states:

- `idle`: wait for local `newd` and keep the beat counter at zero;
- `tx`: assert `m_axis_tvalid`, derive the current data from `din` and `count`,
  assert `m_axis_tlast` when `count==3`, and wait for acceptance.

#### State register

The first sequential block tests active-LOW reset inside
`always @(posedge m_axis_aclk)`. This makes reset **synchronous** in the shown
RTL. When reset is asserted, `state <= idle`; otherwise,
`state <= next_state`.

#### Beat counter

The second sequential block resets `count` in `idle`. In `tx`, it increments
only while the Receiver is ready and the current count is below three. Because
`m_axis_tvalid` is defined as `state==tx`, the course condition
`state==tx && m_axis_tready` is equivalent to the full fire condition inside
this design.

If `m_axis_tready=0`, `count` holds. That one hold simultaneously stabilizes:

- `m_axis_tdata`, because it is derived from `din * count`;
- `m_axis_tlast`, because it is derived from `count==3 && state==tx`;
- `m_axis_tvalid`, because the next-state logic remains in `tx`.

#### Last-beat exit

When `count==3`, the source is offering the fourth beat. It leaves `tx` only if
`m_axis_tready=1`, so the final beat and `TLAST` cannot be abandoned during a
stall. On that fire edge the Receiver accepts the last beat; after the edge the
state becomes `idle`, `TVALID` drops, and the counter resets for the next packet.

#### Hidden input-stability requirement

The output is continuously derived from external `din * count`. Holding
`count` is not enough if `din` changes during a stall. The teaching design
quietly assumes `din` remains constant for the entire packet. A reusable module
should either:

1. latch `din` when accepting `newd`, then derive all four beats from the
   latched value; or
2. expose a documented local input handshake that requires the upstream owner
   to hold `din` until packet completion.

The same issue applies to `newd`: if it remains HIGH when the FSM returns to
`idle`, the source can immediately start another packet. Decide whether that is
desired or whether `newd` must be a one-cycle pulse/acknowledged command.

#### Why this implementation is a good teaching model

The master directly encodes the protocol invariant in state and counter
movement. It is small enough to trace manually and correctly holds the final
beat. Its limitations—fixed length, generated rather than buffered payload,
unlatched command input, and no `TKEEP`/`TUSER`—are deliberate boundaries, not
general AXI-Stream limitations.

### Video 21 - Verifying the master

![Fullscreen master testbench stimulus loop](images/AXI/Day%2001/21-verify-master-testbench-fullscreen.png)

The testbench holds active-LOW reset for ten rising edges, raises
`m_axis_tready`, asserts `newd`, chooses a random eight-bit `din`, and waits for
the generated packet to finish. The loop repeats five times, so the intended
observation is five packets with four accepted beats per packet.

The payload is not four bytes sliced from `din`. The RTL calculates
`m_axis_tdata = din * count`, so one packet is:

| Accepted beat | `count` | `m_axis_tdata` | `m_axis_tlast` |
|---:|---:|---:|:---:|
| 0 | 0 | $0 \times din$ | 0 |
| 1 | 1 | $1 \times din$ | 0 |
| 2 | 2 | $2 \times din$ | 0 |
| 3 | 3 | $3 \times din$ | 1 |

Because `TDATA` is eight bits, multiplication wraps modulo $2^8$ if the result
exceeds 255. That wrap is ordinary Verilog width truncation, not an
AXI-Stream rule.

![Fullscreen master waveform with repeated four-beat packets](images/AXI/Day%2001/21-verify-master-waveform-fullscreen.png)

Read the waveform from handshake edges rather than from the width of the green
regions. With the testbench holding `m_axis_tready=1`, every rising edge with
`m_axis_tvalid=1` accepts one beat. `m_axis_tlast` is meaningful only on the
fourth accepted beat. The next packet may use a new `din`, but the current
packet's `din` must remain stable because the teaching master never latches it.

#### What this simulation proves—and what it does not

The trace proves the happy path: reset, command start, four consecutive
handshakes, final-beat marking, and repetition. It does **not** prove
back-pressure correctness because `m_axis_tready` remains HIGH during each
packet. A stronger test must lower `m_axis_tready` on a middle beat and on the
final beat, then assert that `TVALID`, `TDATA`, and `TLAST` remain stable.

Waiting for `@(negedge m_axis_tlast)` is also specific to this implementation.
A protocol-aware scoreboard should detect completion at the accepted final
beat:

$$
\text{packet\_done} = \text{TVALID} \land \text{TREADY} \land \text{TLAST}
$$

That condition still works when the final beat is stalled for several cycles;
the falling edge of `TLAST` is not itself an AXI-Stream event.

#### Testbench race and initialization details

The supplied testbench changes reset, `newd`, and `din` using blocking
assignments immediately after `@(posedge m_axis_aclk)`. The DUT also samples on
that edge, so simulation ordering can create a race. A robust testbench drives
inputs on the falling edge, through a clocking block, or with nonblocking
assignments scheduled before the next sampling edge. It should also initialize
`m_axis_tready`, `newd`, and `din` before the reset wait so no accidental `X`
value enters checks.

### Lesson 22 - Master code resource

The course resource provides the complete teaching master and its happy-path
testbench. The same listing is reproduced here with whitespace normalized so
the implementation can be revised without leaving the page.

```systemverilog
module axis_m(
    input  wire       m_axis_aclk,
    input  wire       m_axis_aresetn,
    input  wire       newd,
    input  wire [7:0] din,
    input  wire       m_axis_tready,
    output wire       m_axis_tvalid,
    output wire [7:0] m_axis_tdata,
    output wire       m_axis_tlast
);

typedef enum bit {idle = 1'b0, tx = 1'b1} state_type;
state_type state = idle, next_state = idle;
reg [2:0] count = 0;

always @(posedge m_axis_aclk) begin
    if (m_axis_aresetn == 1'b0)
        state <= idle;
    else
        state <= next_state;
end

always @(posedge m_axis_aclk) begin
    if (state == idle)
        count <= 0;
    else if (state == tx && count != 3 && m_axis_tready == 1'b1)
        count <= count + 1;
    else
        count <= count;
end

always @(*) begin
    case (state)
        idle: begin
            if (newd == 1'b1)
                next_state = tx;
            else
                next_state = idle;
        end

        tx: begin
            if (m_axis_tready == 1'b1) begin
                if (count != 3)
                    next_state = tx;
                else
                    next_state = idle;
            end else begin
                next_state = tx;
            end
        end

        default: next_state = idle;
    endcase
end

assign m_axis_tdata  = m_axis_tvalid ? din * count : 0;
assign m_axis_tlast  = (count == 3 && state == tx) ? 1'b1 : 1'b0;
assign m_axis_tvalid = (state == tx) ? 1'b1 : 1'b0;

endmodule
```

```systemverilog
module tb_axis_m;
    wire [7:0] m_axis_tdata;
    wire       m_axis_tlast;
    reg        m_axis_tready;
    wire       m_axis_tvalid;
    reg        m_axis_aclk = 0;
    reg        m_axis_aresetn;
    reg        newd;
    reg  [7:0] din;

    axis_m dut (
        .m_axis_tdata(m_axis_tdata),
        .m_axis_tlast(m_axis_tlast),
        .m_axis_tready(m_axis_tready),
        .m_axis_tvalid(m_axis_tvalid),
        .m_axis_aclk(m_axis_aclk),
        .m_axis_aresetn(m_axis_aresetn),
        .newd(newd),
        .din(din)
    );

    always #10 m_axis_aclk = ~m_axis_aclk;

    initial begin
        m_axis_aresetn = 0;
        repeat (10) @(posedge m_axis_aclk);
        for (int i = 0; i < 5; i++) begin
            @(posedge m_axis_aclk);
            m_axis_aresetn = 1;
            m_axis_tready  = 1'b1;
            newd = 1;
            din = $random();
            @(negedge m_axis_tlast);
            m_axis_tready = 1'b0;
        end
    end
endmodule
```

Two shorthand choices deserve a red flag during revision. `newd` is never
explicitly lowered, so returning to `idle` can immediately request another
packet. Also, the testbench has no assertion that the accepted sequence equals
$\{0,din,2din,3din\}$ or that the held beat remains stable during a stall.

### Video 23 - Building the slave part 1

![Fullscreen comparison of master/slave ports and the Receiver flowchart](images/AXI/Day%2001/23-building-slave-p1-18.png)

The slave is the AXI-Stream **Receiver**. Signal ownership reverses across the
link, not the meaning of the signals:

| Link signal | Master/Transmitter port | Slave/Receiver port | Owner |
|---|---|---|---|
| `ACLK`, `ARESETn` | input | input | System clock/reset source |
| `TVALID` | output | input | Transmitter |
| `TDATA` | output | input | Transmitter |
| `TLAST` | output | input | Transmitter |
| `TREADY` | input | output | Receiver |

The flowchart's “sample data” action must be read as “consume data on a rising
edge where `TVALID && TREADY` is true.” Seeing `TVALID=1` tells the Receiver an
offer exists; it does not by itself complete the transfer. Similarly,
`TLAST=1` announces that the **offered** beat is the final beat, but the packet
ends only when that beat handshakes.

The Receiver is allowed to keep `TREADY=1` in advance, wait for `TVALID`, or
deassert `TREADY` while it is busy. In a real multiplier, filter, or parser,
ready must describe storage/processing capacity—not merely the FSM state name.
If the block cannot retain an input beat while processing an earlier one, it
must lower `TREADY` before its storage becomes full.

### Video 24 - Building the slave part 2

![Fullscreen slave state register and next-state decoder](images/AXI/Day%2001/24-building-slave-p2-18.png)

![Fullscreen store-state conditions beside the Receiver flowchart](images/AXI/Day%2001/24-building-slave-p2-fsm-fullscreen.png)

The teaching Receiver uses `idle` and `store` states. An encoded `last_byte`
state is declared but never used. In `idle`, observing `TVALID=1` schedules
entry to `store`; in `store`, the design drives `TREADY=1`. This creates one
cycle of startup latency because the first valid offer is not accepted while
the state is still `idle` and `TREADY=0`. A compliant Transmitter holds that
first offer until ready rises.

Within `store`, the next-state decoder distinguishes:

| `TVALID` | `TLAST` | Course next state | Correct interpretation while `TREADY=1` |
|:---:|:---:|---|---|
| 1 | 0 | `store` | Accept a non-final beat. |
| 1 | 1 | `idle` | Accept the final beat, then return idle. |
| 0 | 0 | `idle` | **Course simplification:** no transfer exists; this can legally be an inter-beat bubble. |
| 0 | 1 | `idle` | `TLAST` is not meaningful as a transfer while `TVALID=0`. |

#### Important correction: packets may contain bubbles

The lecture suggests `TVALID` must remain continuously HIGH for the whole
packet and treats a LOW cycle mid-packet as an incomplete/error transfer. The
base protocol does not impose that rule. Once a particular beat is offered
with `TVALID=1`, the Transmitter cannot retract or change it until a handshake.
After that beat is accepted, the Transmitter may insert cycles with
`TVALID=0` before offering the next beat—even before `TLAST` has occurred.

Therefore a packet-tracking Receiver must not discard packet context merely
because one cycle has `TVALID=0`. It should wait in its packet state until the
next **accepted** beat. A profile may separately forbid bubbles, but that would
be an application constraint, not the general AXI-Stream rule.

#### `dout` is not storage

The assignment `dout = (state == store) ? s_axis_tdata : 0` is a combinational
view of the input bus. It does not remember an accepted beat. `dout` is useful
only when accompanied by an enable such as
`sample_en = s_axis_tvalid && s_axis_tready`, or when the accepted data is
registered:

```systemverilog
always_ff @(posedge s_axis_aclk) begin
    if (!s_axis_aresetn)
        dout <= '0;
    else if (s_axis_tvalid && s_axis_tready)
        dout <= s_axis_tdata;
end
```

Registering creates real storage and prevents downstream logic from treating
an unaccepted or invalid bus value as data.

### Video 25 - Verifying the slave

![Fullscreen supplied slave-testbench stimulus](images/AXI/Day%2001/25-verify-slave-18.png)

The testbench raises `TVALID` and changes `TDATA` on every loop iteration. The
instructor then correctly identifies the resulting first-cycle violation:
`TREADY` is LOW, yet the stimulus moves to another `TDATA` value. A legal
Transmitter must hold the offered beat until the Receiver accepts it.

![Fullscreen slave waveform ending the packet and returning to idle](images/AXI/Day%2001/25-verify-slave-waveform-fullscreen.png)

The visible state transition after the final beat is correct only because
`store` implies `TREADY=1`. The decisive edge satisfies all three terms:

$$
\text{final\_fire} = \text{TVALID} \land \text{TREADY} \land \text{TLAST}
$$

After that edge, returning to `idle` is safe. Returning merely because `TLAST`
is visible would be unsafe if the final beat were stalled.

#### Handshake-correct source task

A source driver should randomize or choose one beat, assert it, and wait without
changing it until `TREADY` is sampled HIGH:

```systemverilog
task automatic send_beat(input logic [7:0] data,
                         input logic       last);
    @(negedge s_axis_aclk);
    s_axis_tdata  <= data;
    s_axis_tlast  <= last;
    s_axis_tvalid <= 1'b1;

    do @(posedge s_axis_aclk);
    while (!s_axis_tready);

    @(negedge s_axis_aclk);
    s_axis_tvalid <= 1'b0;
    s_axis_tlast  <= 1'b0;
endtask
```

The falling-edge drive avoids racing the DUT's rising-edge sampling. A
scoreboard should count data only when `TVALID && TREADY`, and assertions should
check that an offered beat remains stable while stalled.

The lecture's description of SystemVerilog `logic` as automatically becoming
`reg` for inputs and `wire` for outputs is an oversimplification. `logic` is a
four-state variable data type that permits one driver; port direction controls
data flow. It removes many old `reg`/`wire` declarations, but it does not make
multiple-driver nets legal or replace reasoning about who drives a signal.

### Lesson 26 - Slave code resource

```systemverilog
module axis_s(
    input  wire       s_axis_aclk,
    input  wire       s_axis_aresetn,
    output wire       s_axis_tready,
    input  wire       s_axis_tvalid,
    input  wire [7:0] s_axis_tdata,
    input  wire       s_axis_tlast,
    output wire [7:0] dout
);

typedef enum bit [1:0] {
    idle      = 2'b00,
    store     = 2'b01,
    last_byte = 2'b10
} state_type;
state_type state = idle, next_state = idle;

always @(posedge s_axis_aclk) begin
    if (s_axis_aresetn == 1'b0)
        state <= idle;
    else
        state <= next_state;
end

always @(*) begin
    case (state)
        idle: begin
            if (s_axis_tvalid == 1'b1)
                next_state = store;
            else
                next_state = idle;
        end

        store: begin
            if (s_axis_tlast == 1'b1 && s_axis_tvalid == 1'b1)
                next_state = idle;
            else if (s_axis_tlast == 1'b0 && s_axis_tvalid == 1'b1)
                next_state = store;
            else
                next_state = idle;
        end

        default: next_state = idle;
    endcase
end

assign s_axis_tready = (state == store);
assign dout = (state == store) ? s_axis_tdata : 8'h00;

endmodule
```

```systemverilog
`timescale 1ns / 1ps

module axis_s_tb;
    logic       s_axis_aclk = 0;
    logic       s_axis_aresetn;
    logic       s_axis_tvalid;
    logic [7:0] s_axis_tdata;
    logic       s_axis_tlast;
    logic       s_axis_tready;
    logic [7:0] dout;

    axis_s uut (
        .s_axis_aclk(s_axis_aclk),
        .s_axis_aresetn(s_axis_aresetn),
        .s_axis_tready(s_axis_tready),
        .s_axis_tvalid(s_axis_tvalid),
        .s_axis_tdata(s_axis_tdata),
        .s_axis_tlast(s_axis_tlast),
        .dout(dout)
    );

    always #10 s_axis_aclk = ~s_axis_aclk;

    initial begin
        s_axis_tvalid  = 0;
        s_axis_tdata   = 8'h00;
        s_axis_tlast   = 0;
        s_axis_aresetn = 0;
        repeat (5) @(posedge s_axis_aclk);
        s_axis_aresetn = 1;

        for (int i = 0; i < 10; i++) begin
            @(posedge s_axis_aclk);
            s_axis_tvalid = 1;
            s_axis_tdata  = $urandom;
        end

        @(posedge s_axis_aclk);
        s_axis_tlast = 1;
        @(posedge s_axis_aclk);
        s_axis_tlast  = 0;
        s_axis_tvalid = 0;
        $finish;
    end
endmodule
```

The RTL is small enough to expose the distinction between **protocol legality**
and **application usefulness**. Its ready/valid handshakes can accept beats,
but it neither buffers them nor emits a downstream-valid signal. It is a
teaching Receiver, not yet a reusable data-processing endpoint.

### Video 27 - Connecting master and slave

![Fullscreen elaborated master-to-slave wiring beside the top-level RTL](images/AXI/Day%2001/27-connect-master-slave-18.png)

The top module connects one shared clock and reset to both endpoints. Four
internal nets form the stream link:

```text
axis_m.m_axis_tvalid ─────► axis_s.s_axis_tvalid
axis_m.m_axis_tdata  ─────► axis_s.s_axis_tdata
axis_m.m_axis_tlast  ─────► axis_s.s_axis_tlast
axis_m.m_axis_tready ◄───── axis_s.s_axis_tready
```

This direction diagram is the integration contract. `TREADY` is the only
course link signal driven from slave to master; the payload and its validity
and packet marker travel from master to slave. Both blocks use the same `clk`,
so no clock-domain crossing logic is needed here. If their clocks were
unrelated, directly wiring them would be invalid; an asynchronous AXI-Stream
FIFO or clock converter would be required.

The course uses positional module instantiation. It works only while the child
port order remains exactly unchanged. Named connections are safer because a
future port insertion cannot silently swap `TREADY`, `TVALID`, `TDATA`, or
`TLAST`.

![Fullscreen integrated master/slave waveform with repeated packets](images/AXI/Day%2001/27-connect-master-slave-waveform-fullscreen.png)

For a command value $din=7$, the master offers $0,7,14,21$ and asserts `TLAST`
with 21. For $din=10$, it offers $0,10,20,30$. Those are four **eight-bit
transfers**, not four individual bits. On every edge where the internal
`valid_t && ready_t` is HIGH, `dout` reflects the accepted `data` value because
the slave is in `store`.

#### Startup bubble and back-pressure path

The slave begins in `idle`, so `ready_t=0`. Once the master reaches `tx`,
`valid_t=1` and the slave schedules `store`. The master must hold beat zero
during that startup bubble. After the slave enters `store`, `ready_t=1` and the
four beats can fire on consecutive edges. The same return path would stop the
master counter if a real slave later lowered ready while processing.

No combinational loop exists in this pair: master `TVALID` comes from its
registered state, slave `TREADY` comes from its registered state, and each FSM
uses the opposite handshake input only to choose a later state. More complex
blocks must still be reviewed for combinational `TREADY`/`TVALID` paths that
could create long timing paths or loops across several components.

### Lesson 28 - Integration code resource

```systemverilog
module top (
    input        clk,
    input        rst,
    input        newd,
    input  [7:0] din,
    output [7:0] dout,
    output       last
);
    wire       last_t;
    wire       valid_t;
    wire       ready_t;
    wire [7:0] data;

    axis_m m1 (clk, rst, newd, din,
               ready_t, valid_t, data, last_t);
    axis_s s1 (clk, rst,
               ready_t, valid_t, data, last_t, dout);

    assign last = last_t;
endmodule
```

```systemverilog
module top_tb;
    reg        clk = 0;
    reg        rst;
    reg        newd;
    reg  [7:0] din;
    wire [7:0] dout;
    wire       last;

    top dut (clk, rst, newd, din, dout, last);

    always #10 clk = ~clk;

    initial begin
        rst = 1'b0;
        repeat (10) @(posedge clk);
        rst = 1'b1;

        for (int i = 0; i < 10; i++) begin
            @(posedge clk);
            newd = 1;
            din = $urandom_range(0, 15);
            @(negedge last);
        end
        $finish;
    end
endmodule
```

The same local-control caveats remain: initialize `newd` and `din`, define
whether `newd` is a pulse or level, avoid driving on the DUT sampling edge, and
detect packet completion with `valid_t && ready_t && last_t`. Exporting raw
`last_t` for waveform visibility is harmless, but external logic must not count
it as completion without the other handshake terms.

A safer top-level style makes ownership visible:

```systemverilog
axis_m m1 (
    .m_axis_aclk   (clk),
    .m_axis_aresetn(rst),
    .newd          (newd),
    .din           (din),
    .m_axis_tready (ready_t),
    .m_axis_tvalid (valid_t),
    .m_axis_tdata  (data),
    .m_axis_tlast  (last_t)
);
```

The slave should be instantiated with the corresponding named `s_axis_*`
ports. This adds no hardware; it prevents connection-order bugs.

### Video 29 - Section 3 agenda

![Fullscreen Section 3 agenda: round-robin arbiter, AXIS arbiter, and AXIS FIFO](images/AXI/Day%2001/29-section3-agenda-18.png)

This agenda is the requested stopping boundary. It previews three related but
distinct components:

| Component | Core problem | AXI-Stream-specific responsibility |
|---|---|---|
| Round-robin arbiter | Choose fairly among persistent requesters. | Initially none; first learn the grant rotation independently. |
| AXIS arbiter | Multiplex several Transmitters onto one Receiver. | Route the selected payload/sidebands and return `TREADY` only to the selected source while preserving packet/order rules. |
| AXIS FIFO | Buffer accepted transfers when producer and consumer timing differ. | Store the complete beat bundle, generate upstream `TREADY` from space, and generate downstream `TVALID` from occupancy. |

Ethernet is mentioned because packet traffic often needs buffering and fair
arbitration among flows. The agenda does not yet define an implementation, so
the AXIS-specific datapath and FIFO RTL are not invented in advance here.

### Video 30 - Round-robin arbiter part 1

![Fullscreen two-request timing example and round-robin decision flow](images/AXI/Day%2001/30-round-robin-p1-concept-fullscreen.png)

This lesson deliberately starts with a plain request/grant arbiter, not yet an
AXI-Stream interface. There are two requesters, `req1` and `req2`, and two
one-hot grants, `gnt1` and `gnt2`. The initial idle tie-break favors requester
1, but after one requester is served, the other requester becomes the preferred
choice. That rotating preference is what separates round-robin behavior from a
permanent fixed-priority arbiter.

The grant is state-decoded, so a request sampled in one cycle produces a grant
after the next active clock edge:

| Sampled requests | Previous arbitration state | Next grant | Reason |
|:---:|---|---|---|
| `10` | `idle` | `gnt1` | Only requester 1 is asking. |
| `01` | `idle` | `gnt2` | Only requester 2 is asking. |
| `11` | `idle` | `gnt1` | Reset/idle tie-break gives requester 1 initial priority. |
| `11` | after `gnt1` | `gnt2` | Rotate priority to the requester that did not just win. |
| `11` | after `gnt2` | `gnt1` | Rotate back symmetrically. |

The highlighted grants in the course waveform therefore lag the corresponding
sampled requests by one state-register update. They are not combinational
same-cycle acknowledgements.

#### What “equal service” means here

If both requests remain asserted, the steady-state grant sequence is:

$$
gnt1,\ gnt2,\ gnt1,\ gnt2,\ldots
$$

Each persistent requester receives one of every two grant cycles, and after the
initial decision neither can be bypassed twice by the other. This fairness
claim assumes one grant cycle completes one unit of service. If an operation
takes several cycles, the arbiter needs an explicit `done`, `accept`, or
handshake event and must rotate only when service actually completes.

### Video 31 - Round-robin arbiter part 2

![Fullscreen next-state RTL beside the round-robin flowchart](images/AXI/Day%2001/31-round-robin-p2-fullscreen.png)

The FSM is a Moore machine: `gnt1` and `gnt2` depend only on the registered
state. The three state meanings are:

| State | Current output | Stored arbitration history |
|---|---|---|
| `idle` | No grant | No requester is currently selected; use the initial tie-break. |
| `s1` | `gnt1=1`, `gnt2=0` | Requester 1 is being served now, so requester 2 gets first choice next. |
| `s2` | `gnt1=0`, `gnt2=1` | Requester 2 is being served now, so requester 1 gets first choice next. |

The full next-state table makes the rotating priority visible:

| Current state | `req1 req2 = 00` | `10` | `01` | `11` |
|---|---|---|---|---|
| `idle` | `idle` | `s1` | `s2` | `s1` |
| `s1` | `idle` | `s1` | `s2` | `s2` |
| `s2` | `idle` | `s1` | `s2` | `s1` |

#### Why `s1` checks `req2` before `req1`

State `s1` already means requester 1 owns the **current** grant. If both
requests are still HIGH, checking `req1` first would keep choosing `s1` forever
and requester 2 could starve. Checking `req2` first implements:

$$
\text{next}(s1,\ req2=1)=s2
$$

Requester 1 is allowed to remain in `s1` only when requester 2 is not waiting.
The `s2` logic is the exact mirror: it checks `req1` first because requester 2
has just received service. The order of an `if`/`else if` chain is therefore
hardware priority, not cosmetic source-code ordering.

This is the direct solution to the question on the
[fairness question note](AXI%20Questions.md#page-1---why-does-s1-check-req2-first).

#### Reset and decoder details

The plain arbiter uses a synchronous, active-HIGH reset:
`always @(posedge clk)` samples `rst`, then loads `idle` when `rst=1`. That is
different from AXI's active-LOW `ARESETn` naming and reset contract. The
next-state block uses blocking assignments because it models combinational
logic, while the state register uses a nonblocking assignment.

Every state and branch assigns `next_state`, and the output decoder assigns
both grants in every state, so the shown RTL does not infer latches. In `s1`,
the output decoder sets `gnt1=1`; any spoken phrase suggesting grant 1 becomes
zero in `s1` is simply a narration slip—the code and state meaning are clear.

### Video 32 - Round-robin arbiter part 3

![Fullscreen round-robin testbench stimulus sequence](images/AXI/Day%2001/32-round-robin-p3-testbench-fullscreen.png)

The supplied testbench covers three scenarios in order:

1. `req1=1, req2=0` checks that requester 1 can win alone.
2. `req1=0, req2=1` checks that requester 2 can win alone.
3. `req1=1, req2=1` for five clock edges checks the rotating-priority path.

After the one-cycle state latency, the expected persistent-contention sequence
is `gnt1`, `gnt2`, `gnt1`, `gnt2`, and so on. Mutual exclusion must always hold:

$$
\neg(gnt1 \land gnt2)
$$

The waveform demonstrates alternation, but the testbench is observational—it
contains no assertions or scoreboard. It also changes request values
immediately after `@(posedge clk)` with blocking assignments, which can race the
DUT's state register. Driving requests on `negedge clk`, using nonblocking
assignments, or using a clocking block makes the sampling relationship
deterministic.

Two useful assertions for a stronger test are:

```systemverilog
assert property (@(posedge clk) !(gnt1 && gnt2));
assert property (@(posedge clk) disable iff (rst)
                 (gnt1 && req1 && req2) |=>
                 (!req1 || !req2 || gnt2));
```

The second property is specific to persistent simultaneous requests: if
requester 1 is granted while both remain asserted, requester 2 must be granted
on the next cycle.

### Lesson 33 - Round-robin code resource

The course design listing, with whitespace normalized, is:

```systemverilog
`timescale 1ns / 1ps

module robin (
    input      clk,
    input      rst,
    input      req1,
    input      req2,
    output reg gnt1,
    output reg gnt2
);

typedef enum bit [1:0] {
    idle = 2'b00,
    s1   = 2'b01,
    s2   = 2'b10
} state_type;
state_type state, next_state;

always @(posedge clk) begin
    if (rst)
        state <= idle;
    else
        state <= next_state;
end

always @(*) begin
    case (state)
        idle: begin
            if (req1)
                next_state = s1;
            else if (req2)
                next_state = s2;
            else
                next_state = idle;
        end

        s1: begin
            if (req2)
                next_state = s2;
            else if (req1)
                next_state = s1;
            else
                next_state = idle;
        end

        s2: begin
            if (req1)
                next_state = s1;
            else if (req2)
                next_state = s2;
            else
                next_state = idle;
        end

        default: next_state = idle;
    endcase
end

always @(*) begin
    case (state)
        idle: begin
            gnt1 = 1'b0;
            gnt2 = 1'b0;
        end
        s1: begin
            gnt1 = 1'b1;
            gnt2 = 1'b0;
        end
        s2: begin
            gnt1 = 1'b0;
            gnt2 = 1'b1;
        end
        default: begin
            gnt1 = 1'b0;
            gnt2 = 1'b0;
        end
    endcase
end

endmodule
```

The supplied testbench is:

```systemverilog
module tb;
    reg  clk = 0;
    reg  rst = 0;
    reg  req1, req2;
    wire gnt1, gnt2;

    robin dut (
        .clk (clk),
        .rst (rst),
        .req1(req1),
        .req2(req2),
        .gnt1(gnt1),
        .gnt2(gnt2)
    );

    always #5 clk = ~clk;

    initial begin
        rst = 1;
        repeat (5) @(posedge clk);
        rst = 0;

        req1 = 1;
        req2 = 0;
        @(posedge clk);

        req1 = 0;
        req2 = 1;
        @(posedge clk);

        req1 = 1;
        req2 = 1;
        repeat (5) @(posedge clk);
        $stop;
    end
endmodule
```

#### Code-review findings

| Check | Result | Detail |
|---|:---:|---|
| One-hot grants | PASS | `idle` drives none; `s1` and `s2` drive exactly one. |
| Rotate when both persist | PASS | `s1` prioritizes `req2`; `s2` prioritizes `req1`. |
| Avoid starving requester 2 | PASS AFTER INITIAL TIE-BREAK | `idle` initially favors requester 1, but persistent contention alternates thereafter. |
| Keep serving the sole requester | PASS | `s1` can remain `s1` and `s2` can remain `s2` when the other request is absent. |
| Avoid inferred latches | PASS | All next-state and grant paths, including defaults, are assigned. |
| Make testbench sampling race-free | NEEDS IMPROVEMENT | Requests and reset change on the same positive edge used by the DUT. |
| Verify behavior automatically | NOT PROVIDED | The testbench stops after visual stimulus and has no assertions/scoreboard. |
| Model unknown/uninitialized state | LIMITED | `enum bit` is two-state. An `enum logic` state type provides stronger `X` visibility in simulation. |
| Define request lifetime | SYSTEM CONTRACT | A requester should normally hold `req` until its grant/service-accept event; otherwise a short pulse can be missed. |

This module is still a **request/grant arbiter**, not an AXI-Stream arbiter.
An AXIS version must arbitrate complete transfer bundles, return `TREADY` only
to the selected source, preserve a stalled selected beat, and define whether a
grant is held for one beat or until accepted `TLAST`. Those implementation
details begin after the present stopping boundary.

## Arm IHI 0051B standards audit

This second-pass audit checks the lecture interpretation and sample master
against the small-print requirements in the local
[Arm IHI 0051B specification](../03%20AXI/sources/ARM-IHI-0051B-AMBA-AXI-Stream-Protocol-Specification.pdf).
“Master” and “slave” are retained when discussing the course RTL port names;
the Issue B specification uses **Transmitter** and **Receiver**.

### Interface shape and optional-signal details

The signal list and default rules are in
[sections 2.1 and 3.1](../03%20AXI/sources/ARM-IHI-0051B-AMBA-AXI-Stream-Protocol-Specification.pdf#page=16).

| Minor standard rule | Consequence for design and waveform reading |
|---|---|
| `TDATA_WIDTH` must be an integer number of bytes. Power-of-two byte widths are expected in many designs but are not a protocol requirement. | A non-power-of-two width can still be AXI-Stream compliant. Never infer compliance from a familiar width such as 32 or 64 bits alone. |
| Arm recommends `TDATA` widths of 8, 16, 32, 64, 128, 256, 512, or 1024 bits, but the normative width rule is byte granularity. | “Recommended” and “required” are different. A tool or IP profile may impose a narrower set than the base protocol. |
| `TDATA` itself can be absent. If absent, `TSTRB` must also be absent; `TKEEP`, if present, defines the byte-equivalent width for conversion. | AXI-Stream can transport control/sideband events without a conventional payload. The common `TDATA`-carrying interface is not the only legal form. |
| `TREADY` is optional and defaults HIGH when omitted, although the specification recommends including it. | An omitted `TREADY` means the Transmitter assumes every offered transfer is accepted. It cannot respond to back-pressure; including the pin can still expose an illegal LOW as an error. |
| If `TKEEP` is absent, it defaults to all HIGH. If `TSTRB` is absent, it defaults to `TKEEP`. | A simple interface without either qualifier represents every lane as a data byte. No hidden null or position bytes exist in that configuration. |
| `TID`, `TDEST`, and `TUSER` are optional. Undriven Receiver bits are fixed LOW. | Both endpoints must agree on the sideband contract. Merely having ports with matching names does not guarantee that their meanings match. |
| `TLAST` is optional. For a stream with no packet concept it can be tied LOW, tied HIGH, or generated periodically, but the choice affects merging, arbitration, and buffering. | When topology is unknown and a component has no `TLAST`, Arm recommends defaulting it HIGH so an interconnect cannot delay data indefinitely while waiting for a boundary. Fixed LOW is safe only when the topology guarantees no boundary-dependent draining. |

### Handshake, clock, and reset details

These rules come from
[sections 2.2 and 2.8](../03%20AXI/sources/ARM-IHI-0051B-AMBA-AXI-Stream-Protocol-Specification.pdf#page=18).

| Minor standard rule | Consequence for the course waveforms and RTL |
|---|---|
| `TVALID` may lead `TREADY`, `TREADY` may lead `TVALID`, or both may assert together. | The only acceptance test is their sampled conjunction on a rising edge. Signal ordering alone does not create a transfer. |
| The Transmitter must not wait for `TREADY` before asserting `TVALID`. | This is the deadlock-prevention dependency. The course master satisfies it because `newd` can move the FSM into `tx` even when `m_axis_tready=0`. |
| The Receiver may wait for `TVALID` before asserting `TREADY`, and may assert or deassert `TREADY` while no valid offer exists. | `TREADY` is not required to remain HIGH. Pre-asserting it is a latency optimization, not a protocol obligation. |
| Once `TVALID` is HIGH, `TVALID` and all valid data/control information must remain unchanged until a handshake. | The held bundle includes enabled `TDATA`, `TKEEP`, `TSTRB`, `TLAST`, `TID`, `TDEST`, and `TUSER`, not just the visible payload. |
| All inputs are sampled on rising `ACLK` edges and all outputs change after a rising edge. | A direct AXI-Stream link is a single-clock interface. Crossing unrelated clocks requires a clock-conversion component such as an asynchronous FIFO or stream clock converter. |
| `ARESETn` is active LOW. Assertion may be asynchronous, but deassertion must be synchronous to `ACLK`. | Reset release must not occur at an arbitrary point in the clock cycle. A reset synchronizer is normally used when the external reset release is asynchronous. |
| While reset is active, `TVALID` must be LOW; every other interface output may take any value. | A testbench should judge reset compliance primarily from `TVALID`. Requiring every data/sideband signal to be zero is an implementation preference, not a base-protocol rule. |
| After reset is sampled HIGH, the Transmitter may first drive `TVALID` HIGH only after the following rising edge. | The course state register naturally enforces this: reset leaves the state in `idle`, and the later sampled `newd` transition makes `TVALID` HIGH after a clock edge. |

### Byte, packet, conversion, and ordering details

The relevant clauses are
[sections 2.4-2.7](../03%20AXI/sources/ARM-IHI-0051B-AMBA-AXI-Stream-Protocol-Specification.pdf#page=21)
and
[chapter 4](../03%20AXI/sources/ARM-IHI-0051B-AMBA-AXI-Stream-Protocol-Specification.pdf#page=40).

| Minor standard rule | Consequence for a real stream path |
|---|---|
| Low-order `TDATA` byte lanes are earlier in a packed byte stream. | Byte lane $0$ is `TDATA[7:0]`; lane $x$ is `TDATA[(8x+7):8x]`. A left-to-right hexadecimal drawing can visually reverse the time order if this convention is forgotten. |
| Data-byte values, counts, and relative positions must be preserved. Position-byte counts and relative positions must also be preserved. Null bytes may be inserted or removed. | An interconnect may repack a stream, but it cannot silently alter meaningful data or the holes whose positions carry information. |
| A transfer with every `TKEEP` bit LOW is legal. It may be suppressed only when `TLAST` is also LOW. | “No valid byte lanes” does not automatically mean “illegal transfer.” A zero-byte transfer with `TLAST=1` can terminate a packet or flush buffered data and must not simply disappear. |
| The count of packet boundaries and assertions of `TLAST` must be preserved from Transmitter to Receiver. | Width converters may move `TLAST` to the final output transfer, but they cannot lose, invent, or merge away packet endings. |
| AXI-Stream has no explicit start-of-packet signal. | For a given `TID`/`TDEST`, a packet begins at the first transfer after reset or the first transfer after the previous `TLAST`. Application profiles can add a start marker in `TUSER`, but base AXI-Stream does not. |
| Every byte in one packet has the same `TID` and `TDEST`. Transfers with different identifiers, or transfers separated by an asserted `TLAST`, must not be merged. | Routing and logical-stream identity are packet invariants even when an interconnect repacks beat widths. |
| Streams with different `TID`/`TDEST` values may be interleaved transfer-by-transfer unless the `Continuous_Packets` property forbids it. | `TLAST` is an efficient arbitration point, not a universal rule that arbitration can occur only at packet boundaries. A continuous-packet interface is the stricter exception. |
| Transfers must remain ordered; AXI-Stream reordering is not permitted. | If a later accepted transfer from a Transmitter reaches a destination, all earlier transfers on that path must already have reached it. |
| Merging is permitted only when identifiers match, byte order and sideband associations remain correct, and the earlier transfer does not have `TLAST=1`. | An upsizer may wait for more bytes, but an asserted `TLAST` tells it not to merge with the following packet and provides a reason to drain promptly. |
| AXI-Stream defines no maximum packet length. | A four-beat packet is a teaching choice in the course master, not a protocol limit comparable to a fixed AXI memory-mapped burst length. |

### TUSER and compatibility details

`TUSER` is more precise than a generic “extra bits” description. Section 2.9
models it on a per-byte basis. User bits associated with a byte whose `TKEEP`
is LOW are not guaranteed to transfer, and if an interconnect removes that null
byte it removes the associated User bits. When an interconnect inserts a null
byte, the new User bits are fixed LOW.

Transfer-wide `TUSER` information is reliable through an interconnect only
under restrictions that preserve its byte association—for example, matching
input/output data widths and no repacking that changes which bytes share a
transfer. A system profile can still define one transfer-wide start flag, but
the designer must confirm how width converters preserve it.

Finally, section 3.2 warns that **interface compatibility does not guarantee
functional compatibility**. Two blocks can have the same data width and signal
set yet disagree about pixel packing, audio-channel order, packet boundaries,
or `TUSER` meaning. The use-case contract is part of integration correctness.

### AXI5-Stream wake-up detail

`TWAKEUP` exists only on AXI5-Stream when `Wakeup_Signal=True`. It is synchronous
to `ACLK` but must also be glitch-free so another clock domain can sample it.
It can assert before or after `TVALID`; if both are HIGH in the same cycle,
`TWAKEUP` remains HIGH until `TREADY` is asserted. A Receiver may wait for
`TWAKEUP` before asserting `TREADY`, which is why an implemented-but-never-driven
wake-up path can deadlock even though the ordinary valid/ready dependency rule
is correct.

### Course-master compliance result

| Check | Result | Reason |
|---|:---:|---|
| Assert `TVALID` without waiting for `TREADY` | PASS | Entry into `tx` depends on `newd`, not on `m_axis_tready`. |
| Hold the offered beat during back-pressure | CONDITIONAL PASS | State and count hold, so `TVALID`, `TLAST`, and the count-selected data hold only if external `din` also remains stable. |
| Advance exactly once per handshake | PASS | In `tx`, the counter advances only with `m_axis_tready`; because `m_axis_tvalid` is exactly `state==tx`, this is equivalent to the full fire condition. |
| Preserve the final beat until acceptance | PASS | The FSM leaves `tx` at `count==3` only when `m_axis_tready=1`. |
| Drive `TVALID` LOW during reset | CONDITIONAL PASS | After a rising edge with reset LOW, state becomes `idle` and `m_axis_tvalid` is LOW. Because the sample uses synchronous-reset RTL, a system that permits asynchronous assertion must ensure the interface's reset implementation clears `TVALID` with the required timing. |
| Handle asynchronous reset release safely | SYSTEM REQUIREMENT | The sample RTL uses synchronous reset logic. Any asynchronous external deassertion must be synchronized before it reaches this interface. |
| Accept a new command while busy | NOT DEFINED | `newd` is a local teaching input, not an AXI-Stream signal. A reusable block needs a command handshake or a documented “only pulse while idle” contract. |
| Support arbitrary packet lengths and byte qualifiers | OUT OF SCOPE | Four beats and no `TKEEP`/`TSTRB`/`TUSER` are legal profile choices, not general protocol limitations. |

### Course-slave and integration compliance result

| Check | Result | Reason |
|---|:---:|---|
| Accept data only on `TVALID && TREADY` | PASS AT INTERFACE | In `store`, `TREADY=1`; the Transmitter must hold the first offer while the Receiver moves out of `idle`. |
| Wait for `TVALID` before raising `TREADY` | PASS | A Receiver is explicitly allowed to wait for valid. The cost here is one startup bubble. |
| Preserve packet context across a `TVALID=0` bubble | NOT PROVIDED | The FSM returns to `idle`. No offered beat is lost, because the next valid beat waits for ready, but a packet-processing application would lose its in-packet context. |
| Treat LOW `TVALID` mid-packet as a protocol error | INCORRECT LECTURE CLAIM | Bubbles between accepted transfers are legal in base AXI-Stream. Only an already asserted valid offer must remain asserted and stable until handshake. |
| Present only accepted data on `dout` | FAIL AS LOCAL OUTPUT CONTRACT | `dout` is a combinational mirror of `TDATA` in `store` and has no local valid pulse. Downstream logic needs `fire` or a registered accepted value. |
| Finish only on an accepted `TLAST` beat | PASS IN THIS FSM | The `TLAST && TVALID` test occurs in `store`, where `TREADY` is necessarily HIGH. Writing the full three-term condition would make that dependency explicit. |
| Drive protocol-required reset value | PASS | The Receiver has no `TVALID` output. AXI-Stream does not require `TREADY` or data outputs to take a particular reset value. |
| Use a protocol-compliant slave testbench source | FAIL, THEN IDENTIFIED | The supplied loop changes `TDATA` before the first `TREADY`; the lesson correctly flags it as the assignment to fix. |
| Connect signal ownership correctly at top level | PASS | Valid, data, and last travel master-to-slave; ready returns slave-to-master; both endpoints share the same clock and reset. |
| Verify stalls, bubbles, and data integrity end-to-end | NOT COVERED | The integrated test is a no-back-pressure demonstration without assertions or a scoreboard. |

## Points to remember

- One rising edge with `TVALID && TREADY` means exactly one accepted transfer.
- Never increment the beat counter, change the payload, or consume the upstream
  item during a stall.
- `TLAST` is part of the last beat and obeys the same stability rule as `TDATA`.
- The source cannot wait for ready before asserting valid; the Receiver may wait
  for valid, although early ready reduces latency.
- `TKEEP=1, TSTRB=1` is data; `1,0` is position; `0,0` is null; `0,1` is
  reserved.
- AXI-Stream links have no address channel, but stream interconnects can still
  route among multiple components.
- A waveform is counted by handshake edges, not by how long a signal stays
  HIGH.
- `TVALID` may be LOW between beats of one packet. It must stay HIGH only after
  a specific beat has been offered and until that beat handshakes.
- A Receiver samples or stores data on `fire`, not merely because `TDATA` is
  visible and not merely because its FSM is in a state named `store`.
- A combinational `dout = TDATA` path is not storage. Register the accepted beat
  or propagate a local valid/ready contract.
- Packet completion is `TVALID && TREADY && TLAST`; a later falling edge of
  `TLAST` is implementation behavior, not the protocol event.
- Prefer named module-port connections for multi-signal interfaces so a port
  list change cannot silently corrupt the link.
- `idle` supplies only the initial arbiter tie-break; `s1` and `s2` reverse the
  priority so a persistent competing request cannot starve.
- A grant decoded from registered state appears after the request is sampled;
  it is not a combinational same-cycle acknowledgement.
- Rotate priority when one unit of service is accepted or completed. A
  multi-cycle resource needs a completion event instead of rotating every
  clock.

## Active-recall checkpoint

1. In the middle-stall waveform, why is $D_2$ accepted once rather than three
   times?
2. If `TLAST=1` and `TREADY=0`, which signals must the source preserve?
3. Why is `count <= count + 1` gated by a handshake?
4. What fails if the course master changes `din` while stalled?
5. Why can `TREADY` legally be HIGH before `TVALID`?
6. Why can `TKEEP=0` bytes disappear in an interconnect while position bytes
   cannot?
7. Which part of the course's generic handshake source limits throughput even
   though it remains functionally correct?
8. In the ADC pipeline, which block creates DDR addresses, and why are those
   addresses absent between the ADC and filter?
9. In the AMD video profile, what do `TUSER[0]` and `TLAST` mark?
10. Why can an AXI-Stream FIFO survive a short consumer stall but not an
    indefinitely slower consumer?
11. What extra protection is needed when a camera, ADC, or audio codec cannot
    stop producing physical samples?
12. Why is the I2S interface a protocol converter rather than another name for
    AXI-Stream?
13. Why is the first beat stalled for one cycle when the course slave begins in
    `idle`?
14. Is a cycle with `TVALID=0` between two packet beats an AXI-Stream error?
15. What exact condition should enable a register that captures `s_axis_tdata`?
16. Why does the course `dout` signal not prove that a byte was stored?
17. What is invalid about changing testbench `TDATA` while `TVALID=1` and
    `TREADY=0`?
18. For $din=10$, which four eight-bit values does the course master send?
19. Why is `@(negedge TLAST)` weaker than observing an accepted final beat?
20. Which four link nets connect the master and slave, and who drives each one?
21. Why does `s1` check `req2` before checking `req1`?
22. If both requests remain HIGH after reset, what state and grant sequence
    should appear?
23. What starvation bug appears if `s1` gives `req1` first priority again?
24. Why is the initial `idle` decision not perfectly symmetric even though the
    long-term schedule is fair?
25. Which additional event is needed before rotating a grant for a multi-cycle
    shared resource?
26. Why is the lesson 33 module still not an AXI-Stream arbiter?

## Related question note

The [round-robin fairness question](AXI%20Questions.md#page-1---why-does-s1-check-req2-first)
maps to Video 31 and explains why `s1` checks `req2` first.
