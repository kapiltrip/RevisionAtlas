# AXI Chapters - Integrated Lecture and Handwritten Notes

[Back to AXI](README.md) | [Course atlas](Course%20Atlas.md) | [Instructor code](Code/README.md)

This is the single, course-ordered reading file for all nine AXI chapters. Each
lesson keeps the previously captured lecture screenshots and explanation
together, followed immediately by the matching handwritten page or pages before
the next lesson begins.

The handwritten layer contains 60 pages from the three scanned PDFs added on 12
August 2026, plus the earlier round-robin question. The source scans are
preserved as three cleanly named sets:

- [Pages 1-24](../../../_internal/Protocols/04%20AMBA/03%20AXI/handwritten/sources/axi-handwritten-notes-pages-01-24.pdf)
- [Pages 25-48](../../../_internal/Protocols/04%20AMBA/03%20AXI/handwritten/sources/axi-handwritten-notes-pages-25-48.pdf)
- [Pages 49-60](../../../_internal/Protocols/04%20AMBA/03%20AXI/handwritten/sources/axi-handwritten-notes-pages-49-60.pdf)

## Chapter index

1. [Section 1 - Introduction to AXI](#section-1---introduction-to-axi)
2. [Section 2 - AXI-Stream Interface Fundamentals](#section-2---axi-stream-interface-fundamentals)
3. [Section 3 - Using AXI-Stream to Build IP](#section-3---using-axi-stream-to-build-ip)
4. [Section 4 - Getting Started with AXI4-Lite](#section-4---getting-started-with-axi4-lite)
5. [Section 5 - AXI4-Lite Single Beat without Pipeline: Waveform Approach](#section-5---axi4-lite-single-beat-without-pipeline-waveform-approach)
6. [Section 6 - AXI4-Lite Single Beat without Pipeline: FSM Approach](#section-6---axi4-lite-single-beat-without-pipeline-fsm-approach)
7. [Section 7 - AXI4-Lite GPIO Use Case](#section-7---axi4-lite-gpio-use-case)
8. [Section 8 - AXI4 Full with Hardcoded Next-Address Logic](#section-8---axi4-full-with-hardcoded-next-address-logic)
9. [Section 9 - AXI4 Full with Burst-Based Address Generation](#section-9---axi4-full-with-burst-based-address-generation)

## Section 1 - Introduction to AXI

**Course status:** 10/10 lessons complete. Videos 1-9 are explained below; lesson 10 is the matching code resource.

The section follows one causal path: choose the correct AXI family, identify
the channels and their owners, define the accepted-transfer edge, turn that
rule into source and destination RTL, and finally prove it in a waveform.
Lesson 10 is the matching code resource rather than a separate video.

### Lessons 1-10

#### Video 1 - Agenda

![Agenda listing AXI interface types and the valid-ready implementation](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2001/01-agenda-50.png)

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

#### Video 2 - Use cases of the AXI interfaces

![AXI family comparison and ADC-to-FIR signal-processing path](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2001/02-axi-family-use-cases-30.png)

The right side shows the cleanest AXI-Stream mental model: samples leave an ADC,
enter an FIR filter, and continue in one direction. The filter does not need a
new destination address with every sample. It needs the next sample plus a way
to pause the producer if its pipeline cannot accept one.

![Processor, register peripheral, and the AXI family selection table](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2001/02-axi-family-use-cases-72.png)

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

##### Handwritten page 1 - AXI family selection and use cases

![Handwritten AXI notes: AXI family selection and use cases](../../../_internal/Protocols/04%20AMBA/03%20AXI/handwritten/images/01-axi-family-selection-and-use-cases.jpg)

**Integration note:** This page contrasts unaddressed AXI-Stream flow, AXI4-Lite
register access, and AXI4 burst traffic. Read its application sketches with the
lecture decision table: the interface is chosen from the communication pattern,
not merely from data width.

#### Video 3 - Interface pins

![Lecture comparison of the AXI-Stream, AXI4-Lite, and AXI4 signal groups](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2001/03-interface-pins-28.png)

![Expanded AXI4 signal-group comparison](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2001/03-interface-pins-72.png)

![Fullscreen interface-pin comparison without the course sidebar or player controls](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2001/03-interface-pins-fullscreen.png)

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

##### Handwritten page 2 - AXI variants and the gaps in a simple memory port

![Handwritten AXI notes: AXI variants and the gaps in a simple memory port](../../../_internal/Protocols/04%20AMBA/03%20AXI/handwritten/images/02-axi-variants-and-simple-memory-gaps.jpg)

**Integration note:** The signal-count comparison is configuration-dependent,
while the four questions beside the simple memory are fundamental: address
validity, data validity, acceptance, and completion all need an explicit timing
contract.

##### Handwritten page 3 - Five memory-mapped channels

![Handwritten AXI notes: Five memory-mapped channels](../../../_internal/Protocols/04%20AMBA/03%20AXI/handwritten/images/03-axi-five-channel-overview.jpg)

**Integration note:** The drawing correctly separates write address, write data,
write response, read address, and read data. The key implementation consequence
is that the `AW` and `W` handshakes are independent even though both belong to
one write transaction.

##### Handwritten page 4 - Write response and read-channel directions

![Handwritten AXI notes: Write response and read-channel directions](../../../_internal/Protocols/04%20AMBA/03%20AXI/handwritten/images/04-memory-mapped-response-and-read-channels.jpg)

**Integration note:** This continuation records the remaining channel signals
and their directions. A Manager drives `BREADY` and `RREADY`; a Subordinate
drives `BVALID`, `BRESP`, `RVALID`, `RDATA`, and the read response.

#### Video 4 - Simple memory versus AXI memory

![Simple memory drawing and the four missing-control questions](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2001/04-simple-vs-axi-memory-30.png)

The whiteboard lists four questions: when write/read data is valid, when an
address is valid, whether an update succeeded, and whether the target can accept
work. A bare address/data bundle does not answer them. It needs an external
timing convention or explicit controls.

![Five AXI memory-mapped channels with separate timing waveforms](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2001/04-simple-vs-axi-memory-72.png)

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

#### Video 5 - Understanding `VALID`/`READY`

![Source-to-destination valid-ready waveform beside the Arm rule excerpt](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2001/05-handshake-fundamentals-30.png)

![Three legal relative timings for valid and ready](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2001/05-handshake-fundamentals-72.png)

![Fullscreen valid-ready timing and the three handshake rules](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2001/05-handshake-fullscreen.png)

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

##### Handwritten page 5 - `VALID`/`READY` ownership and acceptance

![Handwritten AXI notes: `VALID`/`READY` ownership and acceptance](../../../_internal/Protocols/04%20AMBA/03%20AXI/handwritten/images/05-valid-ready-handshake-rules.jpg)

**Integration note:** The page captures the central rule: a transfer is accepted
only at a rising edge where both signals are HIGH. `VALID` must not wait for
`READY`; `READY` may be asserted early whenever the destination has capacity.

#### Video 6 - `VALID`/`READY` rules

![Handshake rule slide with the source and destination waveform](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2001/06-handshake-rules-28.png)

![Ready-before-valid, valid-before-ready, and simultaneous cases](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2001/06-handshake-rules-72.png)

![Fullscreen handshake-rule frame with source and destination ownership](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2001/06-handshake-rules-fullscreen.png)

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

##### Handwritten page 6 - Source handshake flowchart

![Handwritten AXI notes: Source handshake flowchart](../../../_internal/Protocols/04%20AMBA/03%20AXI/handwritten/images/06-source-handshake-flowchart.jpg)

**Integration note:** The source flow correctly holds `VALID` until acceptance.
Completion is not caused by `READY` alone: the offered payload transfers only on
an edge satisfying `VALID && READY`, and every payload field must remain stable
during a stall.

#### Video 7 - Handshake RTL part 1

![Two-state source flowchart beside the initial Verilog](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2001/07-handshake-rtl-p1-20.png)

![Source reset and new-data state logic](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2001/07-handshake-rtl-p1-50.png)

![Wait-for-receiver state holding valid until ready](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2001/07-handshake-rtl-p1-82.png)

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

##### Handwritten page 7 - Source and destination handshake RTL

![Handwritten AXI notes: Source and destination handshake RTL](../../../_internal/Protocols/04%20AMBA/03%20AXI/handwritten/images/07-source-and-destination-handshake-rtl.jpg)

**Integration note:** The two local state machines separate source progress from
destination progress. In the source logic, both data and `VALID` must remain
unchanged while the destination keeps `READY` LOW.

#### Video 8 - Handshake RTL part 2

![Receiver flowchart: ready, wait for valid, and receive](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2001/08-handshake-rtl-p2-20.png)

![Receiver wait-for-data state and data capture](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2001/08-handshake-rtl-p2-52.png)

![Receiver process-data state returning to readiness](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2001/08-handshake-rtl-p2-84.png)

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

##### Handwritten page 8 - Destination readiness and data capture

![Handwritten AXI notes: Destination readiness and data capture](../../../_internal/Protocols/04%20AMBA/03%20AXI/handwritten/images/08-destination-ready-and-data-capture-rtl.jpg)

**Integration note:** The destination page reinforces that `READY` and `VALID`
are independently generated. Data capture belongs on the accepted-transfer edge;
avoid a combinational path that lets `READY` and `VALID` depend on each other in
a loop.

#### Video 9 - Verifying the handshake

![Simulation during reset and the first ready state](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2001/09-verify-handshake-18.png)

![Waveform where valid and ready overlap for acceptance](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2001/09-verify-handshake-52.png)

![Post-edge Receiver data update in the verification waveform](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2001/09-verify-handshake-84.png)

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

#### Lesson 10 - Code resource

The course's first code resource belongs to this section. Its reusable rule is
that all state, counter, and payload updates must be enabled by the same
accepted-transfer event used throughout these notes:

$$
\text{fire}=\text{VALID}\land\text{READY}
$$

### Section 1 completion checkpoint

You are ready to leave this section only when you can answer these without the
screenshots:

1. Why is AXI4-Stream natural for an ADC-to-FIR path but AXI4-Lite natural for
   software-visible control registers?
2. Why can no fixed pin count describe every legal AXI-Stream or AXI4
   configuration?
3. Name the five memory-mapped channels, who drives each payload, and the
   handshake that accepts it.
4. Why may AW and W arrive in either order, and what storage does that imply in
   a Subordinate?
5. What exact rising-edge condition accepts one beat?
6. Which complete information bundle must remain stable while `VALID=1` and
   `READY=0`?
7. Why must a source not wait for `READY`, while a destination is allowed to
   wait for `VALID`?
8. Why can the two-state teaching source insert a bubble even though it is
   handshake-correct?
9. In a waveform, how do you distinguish an accepted edge from the post-edge
   update of a destination register?
10. Why do `SLVERR` and `DECERR` not mean “empty memory” or automatic retry?

---

## Section 2 - AXI-Stream Interface Fundamentals

**Course status:** 18/18 lessons complete (lessons 11-28).

This section keeps the complete AXI-Stream signal, waveform, master, slave,
integration, and standards-audit material together. Code-resource lessons 22,
26, and 28 remain inline with the videos that explain them.

### Lessons 11-28

#### Video 11 - AXI-Stream agenda

![Agenda for signals, AXI-Stream transactions, and master/slave RTL](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2001/11-agenda.png)

The second-section agenda moves from vocabulary to hardware in three steps:
identify the signals, understand write/read-style stream movement, and then
build Transmitter and Receiver RTL. AXI-Stream itself is unidirectional, so
“read” and “write” here describe which component is providing or consuming the
stream; they are not separate AXI-Stream read and write channels like the five
memory-mapped AXI channels.

The course builds the Transmitter first and initially supplies `TREADY` from a
testbench. That isolation is useful: it forces the Transmitter to remain correct
for arbitrary Receiver back-pressure before another RTL block is connected.

#### Video 12 - Typical signals part 1

![AXI-Stream waveforms and the first half of the official signal table](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2001/12-typical-signals-p1-25.png)

![Signal table with stream identifiers, destination, user, and wake-up context](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2001/12-typical-signals-p1-75.png)

![Fullscreen signal-table frame showing TID, TDEST, TUSER, and TWAKEUP](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2001/12-typical-signals-fullscreen.png)

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
[Arm IHI 0051B](../../../_internal/Protocols/04%20AMBA/03%20AXI/sources/ARM-IHI-0051B-AMBA-AXI-Stream-Protocol-Specification.pdf).

The small-print rules are also important. `TWAKEUP` must be glitch-free, may
assert before or after `TVALID`, and is recommended at least one cycle before
`TVALID`. If `TWAKEUP` and `TVALID` are HIGH together, `TWAKEUP` must remain
HIGH until `TREADY` is asserted. A Receiver may wait for `TWAKEUP` before
raising `TREADY`, so a Transmitter that implements wake-up but never asserts it
can deadlock the interface. These rules apply only when the AXI5-Stream
`Wakeup_Signal` property is enabled.

##### Handwritten page 9 - AXI-Stream signal set

![Handwritten AXI notes: AXI-Stream signal set](../../../_internal/Protocols/04%20AMBA/03%20AXI/handwritten/images/09-axis-signal-set.jpg)

**Integration note:** The mandatory clock, reset, handshake, and data signals
are separated from packet qualifiers. `TKEEP`, `TLAST`, `TID`, `TDEST`, `TUSER`,
and `TWAKEUP` are feature-dependent, so their presence and widths must match at
integration time.

#### Video 13 - Typical signals part 2

![Eight byte lanes with TKEEP qualification and the Arm qualifier text](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2001/13-typical-signals-p2-30.png)

![Position-byte example and the relationship between TKEEP and TSTRB](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2001/13-typical-signals-p2-72.png)

![Fullscreen TKEEP and TSTRB truth table beside the lecture padding example](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2001/13-byte-qualifiers-fullscreen.png)

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

##### Handwritten page 10 - `TKEEP`, `TSTRB`, and `TLAST`

![Handwritten AXI notes: `TKEEP`, `TSTRB`, and `TLAST`](../../../_internal/Protocols/04%20AMBA/03%20AXI/handwritten/images/10-tkeep-tstrb-and-tlast.jpg)

**Integration note:** The qualifier truth table distinguishes null, position,
and data bytes. `TSTRB` is meaningful only for a byte retained by `TKEEP`, and
`TLAST` marks the packet boundary rather than simply the end of an arbitrary
clock sequence.

#### Video 14 - AXI-Stream use cases

![Five-channel memory-mapped AXI compared with a one-way stream path](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2001/14-use-cases-45.png)

![Lecture use-case slide showing the ADC, camera, audio, DMA, DDR, generator, and FIFO paths](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2001/14-use-cases-pipelines-context.png)

![Fullscreen AXI-Stream use cases with only the video frame visible](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2001/14-use-cases-fullscreen.png)

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

##### Decode the unfamiliar boxes first

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

##### Use case 1 - ADC to filter to DMA to DDR

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

##### Use case 2 - Camera to transform to DMA to DDR

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

##### Use case 3 - Audio to I2S interface to DMA to DDR

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

##### Use case 4 - Generator through an AXI-Stream FIFO

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

##### Same AXI-Stream signals, different application meanings

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

##### Common use-case traps

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

#### Video 15 - AXI-Stream transactions

![DSP, camera, audio, and FIFO stream paths beside the minimal signal set](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2001/15-transactions-28.png)

![Minimal transaction path and the continuously ready packet waveform](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2001/15-transactions-72.png)

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

#### Video 16 - Ways to implement AXI Interface

![The instructor's complete three-path map for implementing a custom AXI interface](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2001/16-ways-to-implement-axi-interface-70.png)

The instructor divides custom AXI-interface development into three paths:

- **Peripheral RTL from scratch:** declare the AXI ports and write the
  handshake, state, datapath, and application behavior directly. This exposes
  every accepted beat and stall, but the designer also owns every protocol
  detail and all verification.
- **Vivado Verilog Template:** let Vivado generate the AXI-facing RTL structure,
  then place the required application logic into that template. This retains a
  Verilog implementation while reducing the work of creating the interface
  shell manually.
- **Vivado HLS:** describe behavior at a higher level and let the tool generate
  RTL and its AXI interface. This can accelerate algorithm-oriented work, but
  the generated scheduling, latency, and resource use still have to be checked.

![The instructor's final annotation selecting the Vivado Verilog Template path](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2001/16-ways-to-implement-axi-interface-90.png)

The final annotation marks **Vivado Verilog Template** as the path followed by
the course. That choice matters for the next lessons: the interface shell comes
from the tool, while the learner can still inspect and edit the exact Verilog
that decides when `TVALID`, `TREADY`, `TDATA`, and `TLAST` change.

“HLS gives less control” is too absolute. HLS exposes pipeline initiation
interval, latency, resource binding, and interface directives, but control is
expressed differently and generated RTL can be harder to reason about
cycle-by-cycle. Working in the generated Verilog template is valuable here
because the learning goal is to see exactly why a beat counter advances or
stalls.

Also, processors do not literally “only understand AXI.” In a Zynq device, AXI
is the standard interface exposed between the processing system and programmable
logic; the processor core itself executes an instruction set and participates
in several internal protocols.

##### Handwritten page 11 - AXI implementation options and source ports

![Handwritten AXI notes: AXI implementation options and source ports](../../../_internal/Protocols/04%20AMBA/03%20AXI/handwritten/images/11-axis-implementation-options-and-master-ports.jpg)

**Integration note:** The page moves from implementation choices to a custom
AXI-Stream source interface. The `m_axis_` payload and `TVALID` are outputs of
the source, while `TREADY` returns from the destination and gates progress.

#### Video 17 - Waveforms part 1

![AXI-Stream master ports above three valid-ready timing scenarios](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2001/17-waveform-p1-30.png)

![Master output bundle and the delayed-ready portions of the waveform](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2001/17-waveform-p1-72.png)

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

#### Video 18 - Waveforms part 2

![Complete three-case waveform with the no-back-pressure packet first](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2001/18-waveform-p2-30.png)

![No-back-pressure trace reaching the final D3 and TLAST beat](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2001/18-waveform-p2-75.png)

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

#### Video 19 - Waveforms part 3

![Middle-of-packet stall beginning on D2](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2001/19-waveform-p3-22.png)

![D2 held across back-pressure until ready returns](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2001/19-waveform-p3-50.png)

![Final D3 and TLAST held together during the last-beat stall](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2001/19-waveform-p3-80.png)

![Fullscreen three-packet waveform with no stall, middle stall, and final-beat stall](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2001/19-waveforms-fullscreen.png)

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

#### Video 20 - Building the AXI-Stream master

![Master ports and the ready/last flowchart](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2001/20-building-master-18.png)

![TX-state next-state logic checking ready and the final count](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2001/20-building-master-52.png)

![Synchronous state register and handshake-gated count logic](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2001/20-building-master-84.png)

![Fullscreen AXIS master next-state RTL around the ready-gated transmit state](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2001/20-building-master-fullscreen.png)

The design sends a fixed four-beat packet. It uses two states:

- `idle`: wait for local `newd` and keep the beat counter at zero;
- `tx`: assert `m_axis_tvalid`, derive the current data from `din` and `count`,
  assert `m_axis_tlast` when `count==3`, and wait for acceptance.

##### State register

The first sequential block tests active-LOW reset inside
`always @(posedge m_axis_aclk)`. This makes reset **synchronous** in the shown
RTL. When reset is asserted, `state <= idle`; otherwise,
`state <= next_state`.

##### Beat counter

The second sequential block resets `count` in `idle`. In `tx`, it increments
only while the Receiver is ready and the current count is below three. Because
`m_axis_tvalid` is defined as `state==tx`, the course condition
`state==tx && m_axis_tready` is equivalent to the full fire condition inside
this design.

If `m_axis_tready=0`, `count` holds. That one hold simultaneously stabilizes:

- `m_axis_tdata`, because it is derived from `din * count`;
- `m_axis_tlast`, because it is derived from `count==3 && state==tx`;
- `m_axis_tvalid`, because the next-state logic remains in `tx`.

##### Last-beat exit

When `count==3`, the source is offering the fourth beat. It leaves `tx` only if
`m_axis_tready=1`, so the final beat and `TLAST` cannot be abandoned during a
stall. On that fire edge the Receiver accepts the last beat; after the edge the
state becomes `idle`, `TVALID` drops, and the counter resets for the next packet.

##### Hidden input-stability requirement

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

##### Why this implementation is a good teaching model

The master directly encodes the protocol invariant in state and counter
movement. It is small enough to trace manually and correctly holds the final
beat. Its limitations—fixed length, generated rather than buffered payload,
unlatched command input, and no `TKEEP`/`TUSER`—are deliberate boundaries, not
general AXI-Stream limitations.

##### Handwritten page 12 - AXI-Stream source flowchart

![Handwritten AXI notes: AXI-Stream source flowchart](../../../_internal/Protocols/04%20AMBA/03%20AXI/handwritten/images/12-axis-master-flowchart.jpg)

**Integration note:** The source sequence waits for new data, asserts the
payload and `TVALID`, and advances only after `TREADY`. The final-beat decision
must use the count of accepted beats, not elapsed cycles, so stalls cannot
shorten a packet.

##### Handwritten page 13 - Source stall handling and destination interface

![Handwritten AXI notes: Source stall handling and destination interface](../../../_internal/Protocols/04%20AMBA/03%20AXI/handwritten/images/13-axis-master-stall-and-slave-interface.jpg)

**Integration note:** The source-side notes identify the stalled transmit state,
while the lower diagram introduces the destination ports. A robust
implementation holds `TDATA`, `TKEEP`, and `TLAST` together whenever `TVALID=1`
and `TREADY=0`.

#### Video 21 - Verifying the master

![Fullscreen master testbench stimulus loop](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2001/21-verify-master-testbench-fullscreen.png)

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

![Fullscreen master waveform with repeated four-beat packets](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2001/21-verify-master-waveform-fullscreen.png)

Read the waveform from handshake edges rather than from the width of the green
regions. With the testbench holding `m_axis_tready=1`, every rising edge with
`m_axis_tvalid=1` accepts one beat. `m_axis_tlast` is meaningful only on the
fourth accepted beat. The next packet may use a new `din`, but the current
packet's `din` must remain stable because the teaching master never latches it.

##### What this simulation proves—and what it does not

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

##### Testbench race and initialization details

The supplied testbench changes reset, `newd`, and `din` using blocking
assignments immediately after `@(posedge m_axis_aclk)`. The DUT also samples on
that edge, so simulation ordering can create a race. A robust testbench drives
inputs on the falling edge, through a clocking block, or with nonblocking
assignments scheduled before the next sampling edge. It should also initialize
`m_axis_tready`, `newd`, and `din` before the reset wait so no accidental `X`
value enters checks.

#### Lesson 22 - Master code resource

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

#### Video 23 - Building the slave part 1

![Fullscreen comparison of master/slave ports and the Receiver flowchart](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2001/23-building-slave-p1-18.png)

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

##### Handwritten page 14 - AXI-Stream destination flowchart

![Handwritten AXI notes: AXI-Stream destination flowchart](../../../_internal/Protocols/04%20AMBA/03%20AXI/handwritten/images/14-axis-slave-flowchart.jpg)

**Integration note:** The destination advertises readiness, samples a beat on
the handshake edge, and uses accepted `TLAST` to end the packet. A packet may
contain bubbles, so a temporary drop in `TVALID` is not itself an end-of-packet
event.

#### Video 24 - Building the slave part 2

![Fullscreen slave state register and next-state decoder](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2001/24-building-slave-p2-18.png)

![Fullscreen store-state conditions beside the Receiver flowchart](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2001/24-building-slave-p2-fsm-fullscreen.png)

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

##### Important correction: packets may contain bubbles

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

##### `dout` is not storage

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

##### Handwritten page 15 - AXI-Stream destination state machine

![Handwritten AXI notes: AXI-Stream destination state machine](../../../_internal/Protocols/04%20AMBA/03%20AXI/handwritten/images/15-axis-slave-state-machine.jpg)

**Integration note:** The state sketch separates waiting, storing, and packet
completion. `dout` represents the captured beat in this teaching design; deeper
buffering requires explicit storage rather than assuming the output register is
a FIFO.

#### Video 25 - Verifying the slave

![Fullscreen supplied slave-testbench stimulus](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2001/25-verify-slave-18.png)

The testbench raises `TVALID` and changes `TDATA` on every loop iteration. The
instructor then correctly identifies the resulting first-cycle violation:
`TREADY` is LOW, yet the stimulus moves to another `TDATA` value. A legal
Transmitter must hold the offered beat until the Receiver accepts it.

![Fullscreen slave waveform ending the packet and returning to idle](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2001/25-verify-slave-waveform-fullscreen.png)

The visible state transition after the final beat is correct only because
`store` implies `TREADY=1`. The decisive edge satisfies all three terms:

$$
\text{final\_fire} = \text{TVALID} \land \text{TREADY} \land \text{TLAST}
$$

After that edge, returning to `idle` is safe. Returning merely because `TLAST`
is visible would be unsafe if the final beat were stalled.

##### Handshake-correct source task

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

#### Lesson 26 - Slave code resource

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

#### Video 27 - Connecting master and slave

![Fullscreen elaborated master-to-slave wiring beside the top-level RTL](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2001/27-connect-master-slave-18.png)

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

![Fullscreen integrated master/slave waveform with repeated packets](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2001/27-connect-master-slave-waveform-fullscreen.png)

For a command value $din=7$, the master offers $0,7,14,21$ and asserts `TLAST`
with 21. For $din=10$, it offers $0,10,20,30$. Those are four **eight-bit
transfers**, not four individual bits. On every edge where the internal
`valid_t && ready_t` is HIGH, `dout` reflects the accepted `data` value because
the slave is in `store`.

##### Startup bubble and back-pressure path

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

##### Handwritten page 16 - Master/slave wiring and round-robin preview

![Handwritten AXI notes: Master/slave wiring and round-robin preview](../../../_internal/Protocols/04%20AMBA/03%20AXI/handwritten/images/16-master-slave-wiring-and-round-robin-intro.jpg)

**Integration note:** The forward signals connect source to destination while
`TREADY` travels backward. The round-robin preview anticipates the next section:
once an AXI-Stream arbiter selects a packet, it must retain that source until an
accepted `TLAST`.

#### Lesson 28 - Integration code resource

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

### Arm IHI 0051B standards audit

This second-pass audit checks the lecture interpretation and sample master
against the small-print requirements in the local
[Arm IHI 0051B specification](../../../_internal/Protocols/04%20AMBA/03%20AXI/sources/ARM-IHI-0051B-AMBA-AXI-Stream-Protocol-Specification.pdf).
“Master” and “slave” are retained when discussing the course RTL port names;
the Issue B specification uses **Transmitter** and **Receiver**.

#### Interface shape and optional-signal details

The signal list and default rules are in
[sections 2.1 and 3.1](../../../_internal/Protocols/04%20AMBA/03%20AXI/sources/ARM-IHI-0051B-AMBA-AXI-Stream-Protocol-Specification.pdf#page=16).

| Minor standard rule | Consequence for design and waveform reading |
|---|---|
| `TDATA_WIDTH` must be an integer number of bytes. Power-of-two byte widths are expected in many designs but are not a protocol requirement. | A non-power-of-two width can still be AXI-Stream compliant. Never infer compliance from a familiar width such as 32 or 64 bits alone. |
| Arm recommends `TDATA` widths of 8, 16, 32, 64, 128, 256, 512, or 1024 bits, but the normative width rule is byte granularity. | “Recommended” and “required” are different. A tool or IP profile may impose a narrower set than the base protocol. |
| `TDATA` itself can be absent. If absent, `TSTRB` must also be absent; `TKEEP`, if present, defines the byte-equivalent width for conversion. | AXI-Stream can transport control/sideband events without a conventional payload. The common `TDATA`-carrying interface is not the only legal form. |
| `TREADY` is optional and defaults HIGH when omitted, although the specification recommends including it. | An omitted `TREADY` means the Transmitter assumes every offered transfer is accepted. It cannot respond to back-pressure; including the pin can still expose an illegal LOW as an error. |
| If `TKEEP` is absent, it defaults to all HIGH. If `TSTRB` is absent, it defaults to `TKEEP`. | A simple interface without either qualifier represents every lane as a data byte. No hidden null or position bytes exist in that configuration. |
| `TID`, `TDEST`, and `TUSER` are optional. Undriven Receiver bits are fixed LOW. | Both endpoints must agree on the sideband contract. Merely having ports with matching names does not guarantee that their meanings match. |
| `TLAST` is optional. For a stream with no packet concept it can be tied LOW, tied HIGH, or generated periodically, but the choice affects merging, arbitration, and buffering. | When topology is unknown and a component has no `TLAST`, Arm recommends defaulting it HIGH so an interconnect cannot delay data indefinitely while waiting for a boundary. Fixed LOW is safe only when the topology guarantees no boundary-dependent draining. |

#### Handshake, clock, and reset details

These rules come from
[sections 2.2 and 2.8](../../../_internal/Protocols/04%20AMBA/03%20AXI/sources/ARM-IHI-0051B-AMBA-AXI-Stream-Protocol-Specification.pdf#page=18).

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

#### Byte, packet, conversion, and ordering details

The relevant clauses are
[sections 2.4-2.7](../../../_internal/Protocols/04%20AMBA/03%20AXI/sources/ARM-IHI-0051B-AMBA-AXI-Stream-Protocol-Specification.pdf#page=21)
and
[chapter 4](../../../_internal/Protocols/04%20AMBA/03%20AXI/sources/ARM-IHI-0051B-AMBA-AXI-Stream-Protocol-Specification.pdf#page=40).

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

#### TUSER and compatibility details

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

#### AXI5-Stream wake-up detail

`TWAKEUP` exists only on AXI5-Stream when `Wakeup_Signal=True`. It is synchronous
to `ACLK` but must also be glitch-free so another clock domain can sample it.
It can assert before or after `TVALID`; if both are HIGH in the same cycle,
`TWAKEUP` remains HIGH until `TREADY` is asserted. A Receiver may wait for
`TWAKEUP` before asserting `TREADY`, which is why an implemented-but-never-driven
wake-up path can deadlock even though the ordinary valid/ready dependency rule
is correct.

#### Course-master compliance result

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

#### Course-slave and integration compliance result

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

### Points to remember

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

### Active-recall checkpoint

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

---

## Section 3 - Using AXI-Stream to Build IP

**Course status:** 16/16 lessons complete (lessons 29-44).

The section moves from a plain fair request/grant decision to a packet-aware
AXI-Stream arbiter and then to a FIFO that decouples producer and consumer
timing. Lessons 33, 38, 42, and 44 are code resources kept beside the videos
that establish their behavior.

### Lessons 29-44

#### Video 29 - Section 3 agenda

![Fullscreen Section 3 agenda: round-robin arbiter, AXIS arbiter, and AXIS FIFO](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2001/29-section3-agenda-18.png)

This agenda is the transition from interface fundamentals to reusable stream
IP. It previews three related but distinct components:

| Component | Core problem | AXI-Stream-specific responsibility |
|---|---|---|
| Round-robin arbiter | Choose fairly among persistent requesters. | Initially none; first learn the grant rotation independently. |
| AXIS arbiter | Multiplex several Transmitters onto one Receiver. | Route the selected payload/sidebands and return `TREADY` only to the selected source while preserving packet/order rules. |
| AXIS FIFO | Buffer accepted transfers when producer and consumer timing differ. | Store the complete beat bundle, generate upstream `TREADY` from space, and generate downstream `TVALID` from occupancy. |

Ethernet is mentioned because packet traffic often needs buffering and fair
arbitration among flows. At this agenda point the implementation is still only
a roadmap; the later lesson entries derive the AXIS datapath and FIFO behavior
from their actual frames.

#### Video 30 - Round-robin arbiter part 1

![Fullscreen two-request timing example and round-robin decision flow](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2001/30-round-robin-p1-concept-fullscreen.png)

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

##### What “equal service” means here

If both requests remain asserted, the steady-state grant sequence is:

$$
gnt1,\ gnt2,\ gnt1,\ gnt2,\ldots
$$

Each persistent requester receives one of every two grant cycles, and after the
initial decision neither can be bypassed twice by the other. This fairness
claim assumes one grant cycle completes one unit of service. If an operation
takes several cycles, the arbiter needs an explicit `done`, `accept`, or
handshake event and must rotate only when service actually completes.

#### Video 31 - Round-robin arbiter part 2

![Fullscreen next-state RTL beside the round-robin flowchart](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2001/31-round-robin-p2-fullscreen.png)

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

##### Why `s1` checks `req2` before `req1`

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
[handwritten fairness page](#earlier-handwritten-question---round-robin-fairness).

##### Reset and decoder details

The plain arbiter uses a synchronous, active-HIGH reset:
`always @(posedge clk)` samples `rst`, then loads `idle` when `rst=1`. That is
different from AXI's active-LOW `ARESETn` naming and reset contract. The
next-state block uses blocking assignments because it models combinational
logic, while the state register uses a nonblocking assignment.

Every state and branch assigns `next_state`, and the output decoder assigns
both grants in every state, so the shown RTL does not infer latches. In `s1`,
the output decoder sets `gnt1=1`; any spoken phrase suggesting grant 1 becomes
zero in `s1` is simply a narration slip—the code and state meaning are clear.

##### Handwritten page 17 - Round-robin priority rotation

![Handwritten AXI notes: Round-robin priority rotation](../../../_internal/Protocols/04%20AMBA/03%20AXI/handwritten/images/17-round-robin-priority-rotation.jpg)

**Integration note:** The highlighted branch order is functional hardware
priority. After requester 1 is served in `s1`, checking `req2` first prevents a
persistent requester 1 from starving requester 2; `s2` applies the symmetric
rule.

##### Earlier handwritten question - Round-robin fairness

![Handwritten round-robin fairness question about the priority order in state s1](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2001/round-robin-fairness-question-s1-priority.jpg)

**Integration note:** This earlier question asks why `s1` tests `req2` before
`req1`. The state already grants requester 1, so requester 2 must receive the
next tie-break; reversing the branch order would let a persistent `req1` starve
requester 2.

#### Video 32 - Round-robin arbiter part 3

![Fullscreen round-robin testbench stimulus sequence](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2001/32-round-robin-p3-testbench-fullscreen.png)

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

#### Lesson 33 - Round-robin code resource

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

##### Code-review findings

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
details are the subject of lessons 34-44 below.

#### Video 34 - Implementing AXIS arbiter part 1

![Full-screen AXI-Stream arbiter architecture, input packets, output packet, and interface ports](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2002/34-axis-arbiter-p1-overview-fullscreen.jpg)

The frame combines the complete problem statement. Two AXI-Stream
Transmitters, `axis_m1` and `axis_m2`, feed one Receiver through `axis_arb`.
Source 1 offers packet $D_0$-$D_3$ and source 2 offers $D_4$-$D_7$; the output
must contain both packets without mixing their beats. The arbiter therefore
has two responsibilities that the plain request/grant block did not have:

1. choose one source and hold that selection for the required service unit;
2. route the **entire** selected beat bundle forward and route back-pressure
   only to that selected source.

For a packet-locking two-input arbiter, a safe combinational datapath is:

```systemverilog
m_axis_tvalid  = select_s1 ? s1_axis_tvalid : s2_axis_tvalid;
m_axis_tdata   = select_s1 ? s1_axis_tdata  : s2_axis_tdata;
m_axis_tlast   = select_s1 ? s1_axis_tlast  : s2_axis_tlast;
s1_axis_tready = select_s1 && m_axis_tready;
s2_axis_tready = select_s2 && m_axis_tready;
```

Every implemented sideband such as `TKEEP`, `TSTRB`, `TID`, `TDEST`, and
`TUSER` must use the same selection. A source that is not selected sees
`TREADY=0`, so it keeps its offered beat stable. The grant may rotate only when
the current packet actually completes:

$$
\text{packet\_done}=\text{TVALID}\land\text{TREADY}\land\text{TLAST}
$$

Checking `TLAST` without the other two terms is insufficient because a final
beat can remain stalled for many cycles.

##### Handwritten page 18 - AXI-Stream arbiter interfaces and states

![Handwritten AXI notes: AXI-Stream arbiter interfaces and states](../../../_internal/Protocols/04%20AMBA/03%20AXI/handwritten/images/18-axis-arbiter-interface-and-states.jpg)

**Integration note:** Two source interfaces feed one destination interface, with
one state per selected source. State is packet ownership: the arbiter must route
payload, `TVALID`, `TLAST`, and the corresponding return `TREADY` consistently.

#### Video 35 - Implementing AXIS arbiter part 2

![Full-screen request timing and three-state packet-arbiter flowchart](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2002/35-axis-arbiter-p2-25.png)

The flowchart reuses `idle`, `s1`, and `s2`, but the meaning is now stronger
than a one-cycle request grant. `s1` means source 1 owns the output path;
`s2` means source 2 owns it. When both sources are active, the next owner is the
one that did not just finish. The source must remain owner across every stall
and every interior packet beat, otherwise the downstream Receiver could see
one packet assembled from two unrelated inputs.

![Full-screen arbiter RTL showing idle selection and the start of state s1](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2002/35-axis-arbiter-p2-65.png)

The visible `idle` branch chooses source 1 first when both are available,
captures its data and `TLAST`, and moves to `s1`; the source-2 path is the
mirror image. This creates the initial tie-break. The later `s1` logic is where
packet ownership must be maintained. A robust state transition is not merely
`m_axis_tready && s1_axis_tlast`; it is:

```systemverilog
if (select_s1 && s1_axis_tvalid && m_axis_tready && s1_axis_tlast)
    next_state = s2_axis_tvalid ? s2 : idle;
```

The explicit `s1_axis_tvalid` term prevents an old or don't-care `TLAST` value
from ending ownership when no beat is being offered.

![Full-screen arbiter RTL showing the complete s1 and s2 packet-selection branches](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2002/35-axis-arbiter-p2-88.png)

The last frame shows the mirrored `s1` and `s2` branches. Symmetry matters:
each state must hold itself while its selected source still owns an
unaccepted/interior beat, then give the other waiting source first choice only
after the accepted final beat. Fairness is therefore measured in **packets**,
not cycles. One source can legitimately occupy many cycles if its packet is
long or the downstream Receiver is applying back-pressure.

##### Handwritten page 19 - Arbiter idle and source-1 logic

![Handwritten AXI notes: Arbiter idle and source-1 logic](../../../_internal/Protocols/04%20AMBA/03%20AXI/handwritten/images/19-axis-arbiter-idle-and-s1-logic.jpg)

**Integration note:** The temporary payload registers preserve the selected
beat. The packet-safe transition condition is an accepted final beat, `TVALID &&
TREADY && TLAST`; seeing `TLAST` without a handshake is not enough to switch
sources.

##### Handwritten page 20 - Arbiter source-1 and source-2 logic

![Handwritten AXI notes: Arbiter source-1 and source-2 logic](../../../_internal/Protocols/04%20AMBA/03%20AXI/handwritten/images/20-axis-arbiter-s1-and-s2-logic.jpg)

**Integration note:** The mirrored branches implement rotating preference
between sources. Back-pressure must freeze both the selection and its entire
payload bundle, even if the competing source becomes valid while the current
packet is stalled.

#### Video 36 - Implementing AXIS arbiter part 3

![Full-screen final arbiter state logic and output assignments](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2002/36-axis-arbiter-p3-25.png)

The final RTL frame brings the state machine and output decoder together. The
registered state stores ownership; the output logic selects data and `TLAST`.
The selected payload must remain unchanged whenever:

$$
\text{TVALID}=1\quad\text{and}\quad\text{TREADY}=0
$$

That stability can be obtained either by holding a registered output beat or
by holding the select state while the selected source itself obeys the
AXI-Stream stability rule. Changing `next_state` during a stall would change
the mux input and violate the downstream channel even if both sources are
individually compliant.

![Full-screen arbiter output decoder for data, last, and valid](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2002/36-axis-arbiter-p3-65.png)

##### Important protocol correction

The shown teaching expression asserts `m_axis_tvalid` only when an upstream
`TVALID` and the corresponding upstream `TREADY` are both HIGH. If upstream
`TREADY` contains `m_axis_tready`, this makes downstream `TVALID` depend on
downstream `TREADY`. That is not a legal reusable AXI-Stream source: a
Transmitter must present `TVALID` without waiting for `TREADY`.

The hardened relationship is:

```systemverilog
m_axis_tvalid = selected_tvalid;          // independent of m_axis_tready
selected_tready = m_axis_tready;          // back-pressure returns upstream
```

Only counters, pointers, and ownership transitions use the fire condition.
`TVALID` describes the offered beat; it is not an "already accepted" pulse.
This distinction is why a no-stall waveform can look correct while a design
still fails as soon as `m_axis_tready` goes LOW.

#### Video 37 - Verifying the AXI-Stream arbiter

![Full-screen arbiter testbench with reset, randomized data, source valid, source last, and downstream ready](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2002/37-verify-axis-arbiter-25.png)

The testbench enables source 1, randomizes both data inputs, marks packet ends,
and keeps `m_axis_tready=1` for the illustrated run. It exercises source
selection and packet order, but constant ready removes the hardest protocol
case. A stronger test must independently randomize downstream back-pressure
and must freeze each source's complete beat whenever its own `TREADY` is LOW.

![Full-screen Vivado waveform showing source packets, output data, TLAST, state, and registered payload](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2002/37-verify-axis-arbiter-65.png)

The waveform shows `state` moving through `idle`, `s1`, and `s2`, while the
output data follows one input packet at a time. Read it by marking only rising
edges where `m_axis_tvalid && m_axis_tready`. Values visible during reset or
before valid becomes known are not accepted transfers.

The minimum self-checking verification set is:

- no output transfer appears unless one selected input transfer exists;
- every accepted input beat appears exactly once at the output;
- output order within each source is preserved;
- selection cannot change while `m_axis_tvalid && !m_axis_tready`;
- only the selected source can observe `TREADY=1`;
- if both sources remain active, packet ownership alternates after accepted
  `TLAST` beats.

#### Lesson 38 - AXI-Stream arbiter code resource

The code resource belongs with videos 34-37. Use the course listing as the
implementation reference, but audit it with the rules above before reuse. In
particular, replace any `TVALID` expression gated by `TREADY`, gate packet
completion with the full three-signal fire condition, and route every enabled
sideband through the same selection as `TDATA`.

#### Video 39 - Implementing AXI-Stream FIFO part 1

![Full-screen FIFO module ports, payload memories, pointers, flags, and occupancy counter](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2002/39-axis-fifo-p1-20.png)

The FIFO interface stores more than `TDATA`. The visible design has separate
arrays for `TDATA`, `TKEEP`, and `TLAST`, because those values describe one
logical AXI-Stream beat and must emerge together. If the interface later adds
`TSTRB`, `TID`, `TDEST`, or `TUSER`, those fields must be buffered at the same
entry index too.

The write and read events are:

$$
\text{push}=s\_axis\_tvalid\land s\_axis\_tready
$$

$$
\text{pop}=m\_axis\_tvalid\land m\_axis\_tready
$$

![Full-screen FIFO timing diagram showing a packet buffered before the consumer becomes ready](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2002/39-axis-fifo-p1-55.png)

The producer sends $D_0$-$D_3$ before the consumer is ready. The FIFO accepts
those beats while space exists, then presents them later in the same order.
This is temporal decoupling: the FIFO absorbs a finite timing mismatch; it does
not create infinite bandwidth. If the consumer remains slower long enough,
occupancy reaches full and `s_axis_tready` must go LOW.

##### Handwritten page 21 - AXI-Stream FIFO interface and data flow

![Handwritten AXI notes: AXI-Stream FIFO interface and data flow](../../../_internal/Protocols/04%20AMBA/03%20AXI/handwritten/images/21-axis-fifo-interface-and-flow.jpg)

**Integration note:** The FIFO decouples producer timing from consumer timing.
Each stored entry is a complete beat bundle - data, keep, and last - while input
readiness follows available capacity and output validity follows occupancy.

#### Video 40 - Implementing AXI-Stream FIFO part 2

![Full-screen FIFO arrays, pointers, count, full detection, and empty detection](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2002/40-axis-fifo-p2-20.png)

The design uses 16-entry arrays and five-bit write/read pointers plus a five-bit
occupancy counter. `empty` is derived from `count==0`. The screenshot derives
`full` from `count==15`, which intentionally or accidentally leaves one of the
16 declared entries unused. A reusable parameterized FIFO should state its
capacity explicitly and use consistent bounds:

```systemverilog
empty = (count == 0);
full  = (count == DEPTH);
```

If entries are indexed `0` through `DEPTH-1`, pointers must wrap at
`DEPTH-1`; simply allowing a five-bit pointer to increment beyond 15 can index
outside a 16-entry array.

![Full-screen FIFO reset block initializing pointers, count, valid, keep, last, and data](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2002/40-axis-fifo-p2-55.png)

Reset establishes empty state: both pointers and count become zero, and the
registered downstream valid is cleared. Clearing every memory element is not
required for protocol correctness because an empty FIFO must not assert
`m_axis_tvalid`; it can also prevent block-RAM inference on some FPGA tools.
Resetting metadata/valid and ignoring unoccupied RAM contents is often the
better implementation.

![Full-screen FIFO write and read branches updating memory, pointers, count, and output valid](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2002/40-axis-fifo-p2-85.png)

The visible code uses an `else if` chain: it either writes or reads in one
cycle. A streaming FIFO should normally permit one push and one pop on the same
edge. The occupancy update is:

| `push` | `pop` | Next `count` |
|:---:|:---:|---|
| 0 | 0 | `count` |
| 1 | 0 | `count + 1` |
| 0 | 1 | `count - 1` |
| 1 | 1 | `count` |

The same frame loads output registers only when `m_axis_tready && !empty`.
That makes `m_axis_tvalid` wait for ready, repeating the dependency problem
seen in the arbiter. A compliant FIFO must present a valid head item whenever
it is nonempty and hold that item through a downstream stall.

##### Handwritten page 22 - FIFO storage and consumer handshake

![Handwritten AXI notes: FIFO storage and consumer handshake](../../../_internal/Protocols/04%20AMBA/03%20AXI/handwritten/images/22-axis-fifo-storage-and-consumer-handshake.jpg)

**Integration note:** The vector-versus-array note leads into the three parallel
memories. Their indices must always move together, and simultaneous push/pop
must preserve occupancy instead of allowing two independent assignments to
overwrite the count update.

##### Handwritten page 23 - FIFO pointers, count, and reset

![Handwritten AXI notes: FIFO pointers, count, and reset](../../../_internal/Protocols/04%20AMBA/03%20AXI/handwritten/images/23-axis-fifo-pointers-count-and-reset.jpg)

**Integration note:** The pointers address storage while `count` distinguishes
full from empty when pointer values coincide. Reset clears validity and
occupancy; pointer widths and full detection must match the actual depth.

##### Handwritten page 24 - FIFO read/write control

![Handwritten AXI notes: FIFO read/write control](../../../_internal/Protocols/04%20AMBA/03%20AXI/handwritten/images/24-axis-fifo-read-write-control.jpg)

**Integration note:** The page traces the write and read branches and the
registered output. A compact invariant is `next_count = count + push - pop`,
where `push` and `pop` are handshake events, including the simultaneous case.

#### Video 41 - FIFO RTL continuation and verification

![Full-screen FIFO testbench signals and DUT instantiation](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2002/41-axis-fifo-p3-course-labeled-p2-20.png)

The course labels this second consecutive item "P2"; in the notes it is treated
as the continuation/verification lesson. The testbench connects the full beat
bundle and exposes internal memory, pointers, flags, and count for waveform
debugging. Those internal signals are useful evidence, but correctness must be
judged from accepted input and output transfers, not from pointer motion alone.

![Full-screen FIFO waveform filling to full, holding occupancy, and draining to empty](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2002/41-axis-fifo-p3-course-labeled-p2-55.png)

The waveform shows the write pointer and count increasing while input beats
arrive, `full` asserting near maximum occupancy, then the read pointer advancing
and count decreasing as output data drains. Add these adversarial checks before
calling the FIFO verified:

- random gaps in `s_axis_tvalid` and random stalls in `m_axis_tready`;
- simultaneous push and pop at middle occupancy;
- push attempts while full and pop attempts while empty;
- pointer wrap more than once;
- a stalled final beat with `TLAST=1` and nontrivial `TKEEP`;
- a scoreboard comparing every accepted input bundle with the accepted output
  bundle.

#### Lesson 42 - FIFO code resource

This resource belongs to the first FIFO implementation. Before reusing it,
resolve the declared-depth/full-threshold mismatch, make pointer wrap explicit,
support simultaneous enqueue/dequeue, and ensure downstream `TVALID` is
independent of downstream `TREADY`.

#### Video 43 - AXI-Stream FIFO alternate implementation

![Full-screen alternate FIFO interface using wire outputs with the same beat memories and pointers](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2002/43-axis-fifo-alternate-20.png)

The alternate version changes downstream outputs from registered signals to
wires. That supports a fall-through view in which the current memory head is
continuously presented:

```systemverilog
m_axis_tvalid = !empty;
m_axis_tdata  = mem_d[rd_ptr];
m_axis_tkeep  = mem_k[rd_ptr];
m_axis_tlast  = mem_l[rd_ptr];
s_axis_tready = !full;
```

This is compliant only if `rd_ptr` and the addressed entry remain unchanged
during `m_axis_tvalid && !m_axis_tready`. A synchronous block RAM cannot always
provide this zero-latency read shape, so implementation style and target memory
primitive must agree.

![Full-screen alternate FIFO sequential memory update and pointer/count logic](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2002/43-axis-fifo-alternate-55.png)

The sequential block still owns `push`, `pop`, pointers, and occupancy. Output
wires do not eliminate the need for the four-case count update. If a priority
`else if` remains, the alternate interface may look more responsive while
still discarding one of two simultaneous events.

![Full-screen alternate FIFO waveform showing fill, full, drain, pointers, and count](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2002/43-axis-fifo-alternate-85.png)

The waveform again demonstrates fill and drain under the supplied stimulus.
Its most useful signals are `count`, `full`, `empty`, `wr_ptr`, and `rd_ptr`:
together they can reveal off-by-one capacity errors that may not appear in the
first short packet. A long wraparound scoreboard remains the decisive test.

#### Lesson 44 - Alternate FIFO code resource

Lesson 44 completes Section 3. Keep the alternate code beside Video 43 and
judge it by externally visible invariants: accepted beats are neither lost nor
duplicated, ordering and sidebands are preserved, and the interface stays
stable under back-pressure.

### Section 3 protocol-hardening checklist

- An AXI-Stream arbiter locks its selected path through a stalled beat and,
  when packet locking is required, through the accepted `TLAST` beat.
- `TVALID` never waits for `TREADY`; state and storage advance on their
  conjunction.
- Non-selected sources see `TREADY=0`.
- A FIFO stores the complete implemented beat bundle, not `TDATA` alone.
- Pointer width, pointer wrap, declared array depth, full threshold, and count
  range describe the same capacity.
- A FIFO can push and pop on the same edge without changing occupancy.
- `m_axis_tvalid && !m_axis_tready` freezes the FIFO head and every sideband.

### Active-recall checkpoint

1. Why must an arbiter not change source when `m_axis_tvalid=1` and
   `m_axis_tready=0`?
2. What exact event ends packet ownership?
3. Why is `m_axis_tvalid = selected_tvalid && m_axis_tready` illegal?
4. Which ready signal does a non-selected source receive?
5. Why must a FIFO store `TKEEP` and `TLAST` at the same index as `TDATA`?
6. What happens to `count` when push and pop occur together?
7. Why can a five-bit pointer be wrong for a 16-entry array even though it can
   represent the value 15?
8. What output behavior proves that a FIFO is stable during back-pressure?

---

## Section 4 - Getting Started with AXI4-Lite

**Course status:** 10/10 lessons complete, covering lessons 45-54.

The section first separates transaction, burst, beat, and channel-transfer
language. It then walks all five memory-mapped channels, the four response
encodings, and the final AXI4-Lite signal set. The page continually removes
AXI3/full-AXI fields that do not belong on an AXI4-Lite interface.

### Read this section with the correct protocol lens

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

#### Video 45 - Section 4 agenda

![Full-screen Section 4 agenda for beat, transfer, transaction, channels, signals, and AXI-Lite](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2002/45-axi-lite-agenda-50.png)

The agenda gives the correct learning order. First decide what event is being
counted; then separate the five memory-mapped channels; then learn the payload
on each channel; finally remove the full-AXI features that AXI4-Lite does not
need. The section therefore begins with full-AXI examples as scaffolding before
arriving at the Lite subset.

#### Video 46 - Transaction versus beat versus transfer

![Full-screen handwritten transaction and multi-beat transfer model above a read-burst waveform](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2002/46-transaction-beat-transfer-20.png)

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

![Full-screen four-beat read waveform with AR address/control and R data/response channels](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2002/46-transaction-beat-transfer-55.png)

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

##### Handwritten page 25 - Transaction, beat, transfer, and write address

![Handwritten AXI notes: Transaction, beat, transfer, and write address](../../../_internal/Protocols/04%20AMBA/03%20AXI/handwritten/images/25-axi-transaction-beat-and-write-address.jpg)

**Integration note:** A transaction contains its address, data beat or beats,
and response; a beat is one data-channel transfer. Bytes are lanes within a
beat, not separate AXI transactions, and the write-address channel carries the
control for the data sequence.

#### Video 47 - Understanding the write address channel

![Full-screen write-address waveform annotated with address, size, burst, length, ID, and encoding tables](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2002/47-write-address-channel-85.png)

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

##### Handwritten page 26 - Write-address burst attributes

![Handwritten AXI notes: Write-address burst attributes](../../../_internal/Protocols/04%20AMBA/03%20AXI/handwritten/images/26-axi-write-address-burst-attributes.jpg)

**Integration note:** `AWSIZE` encodes `log2(bytes_per_beat)` and `AWLEN+1`
gives the number of beats. Burst type, length, and ID are AXI4 features;
AXI4-Lite removes bursts and transaction IDs.

##### Handwritten page 27 - Single-beat pipelining and read addressing

![Handwritten AXI notes: Single-beat pipelining and read addressing](../../../_internal/Protocols/04%20AMBA/03%20AXI/handwritten/images/27-single-beat-pipelining-and-read-address.jpg)

**Integration note:** The page contrasts waiting for a complete transaction with
accepting a following address early. Pipelining changes throughput and required
buffering, not the channel handshake rules, which remain independent in both
implementation styles.

#### Video 48 - Understanding channel IDs

![Full-screen comparison of non-pipelined and pipelined single-beat request/response timing](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2002/48-channel-ids-20.png)

Without pipelining, the requester waits for the response to address $a_0$
before sending $a_1$. The link is simple but round-trip latency creates idle
cycles. With pipelining, the requester can issue $a_1$ before response $d_0$
returns, increasing the number of outstanding transactions and improving
throughput.

![Full-screen pipelined waveform using request and response IDs to associate returned data](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2002/48-channel-ids-55.png)

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

#### Video 49 - Understanding the write data channel

![Full-screen write-data waveform with WVALID, WREADY, WDATA, WSTRB, WID, WLAST, byte lanes, and channel directions](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2002/49-write-data-channel-35.png)

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

##### Worked partial-write example

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

![Full-screen relationship among AWADDR, AWSIZE, AWBURST, AWLEN, four data beats, and burst encodings](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2002/49-write-data-channel-85.png)

This final frame reconnects the data beats to their address command. `AWSIZE`
sets bytes per beat, `AWLEN+1` sets the beat count, and `AWBURST` determines how
successive addresses are generated. These are full-AXI burst controls. In
AXI4-Lite the same conceptual write collapses to one address transfer and one
data transfer; byte-level partial updates still use `WSTRB`.

##### Write-channel independence checkpoint

For one AXI4-Lite write, the master may complete the AW handshake first, the W
handshake first, or both on the same edge. The slave records whichever arrives
and produces a write response only after it has accepted both pieces.

##### Hardware state implied by independent arrival

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

##### Handwritten page 28 - Write data, byte strobes, IDs, and last

![Handwritten AXI notes: Write data, byte strobes, IDs, and last](../../../_internal/Protocols/04%20AMBA/03%20AXI/handwritten/images/28-write-data-byte-strobes-ids-and-last.jpg)

**Integration note:** `WSTRB` qualifies byte lanes of `WDATA`. `WID` belongs to
AXI3 rather than AXI4, while `WLAST` belongs to burst-capable AXI4; AXI4-Lite
has neither IDs nor a last marker because every transaction is single beat.

#### Video 50 - Understanding the write response channel

![Original full-frame write response waveform and master/slave channel directions](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/050-understanding-write-response-channel-25.png)

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

#### Video 51 - The four response encodings

![Original full-frame AXI response-code table, special-operation notes, and interface diagram](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/051-different-types-of-response-25.png)

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

##### Handwritten page 29 - Write responses and channel directions

![Handwritten AXI notes: Write responses and channel directions](../../../_internal/Protocols/04%20AMBA/03%20AXI/handwritten/images/29-write-response-codes-and-channel-directions.jpg)

**Integration note:** The page records the two-bit response encodings and the
five channel directions. The Subordinate owns `BVALID` and `BRESP`; the Manager
owns `BREADY`, and their handshake retires the write response.

#### Video 52 - Read address and read data channels, part 1

![Original full-frame read-address and read-data waveforms beside the AXI master/slave diagram](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/052-understanding-read-address-and-data-channel-p1-25.png)

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

##### Handwritten page 30 - Read channels and memory-mapped signals

![Handwritten AXI notes: Read channels and memory-mapped signals](../../../_internal/Protocols/04%20AMBA/03%20AXI/handwritten/images/30-read-channels-and-memory-mapped-signal-set.jpg)

**Integration note:** The read-address request travels Manager to Subordinate,
while read data and response return on the `R` channel. IDs, burst length, size,
type, and `RLAST` apply to full AXI; the Lite boundary removes them.

#### Video 53 - Read address and read data channels, part 2

![Original full-frame completed AXI read waveform with request, data, response, ID, and last-beat timing](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/053-understanding-read-address-and-data-channel-p2-75.png)

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

#### Video 54 - The complete AXI4-Lite signal set

![Original full-frame five-channel AXI4-Lite waveform and complete signal-direction reference](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/054-axi-lite-signals-75.png)

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

##### Handwritten page 31 - AXI4-Lite signal set and implementation configurations

![Handwritten AXI notes: AXI4-Lite signal set and implementation configurations](../../../_internal/Protocols/04%20AMBA/03%20AXI/handwritten/images/31-axi-lite-signal-set-and-configurations.jpg)

**Integration note:** This summary reduces the interface to the five Lite
channels and lists common implementation profiles. A read-only or write-only
endpoint may omit unused channels, but every retained channel still follows the
same `VALID`/`READY` contract.

### Section 4 points to remember

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

### Active-recall checkpoint

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

---

## Section 5 - AXI4-Lite Single Beat without Pipeline: Waveform Approach

**Course status:** 30/30 lessons complete, covering lessons 55-84.

This section implements one outstanding AXI4-Lite operation at a time. The
instructor first draws the legal waveforms, then makes the Manager and
Subordinate reproduce those waveforms with counters, flags, and small control
blocks. It ends by inserting AMD's AXI Protocol Checker between the two blocks.

The design is intentionally a teaching implementation. Keep its exact signal
and module naming when studying the matching files under [Code](Code/README.md).
The notes below identify the assumptions and ignored signals beside the lesson
that introduces them; they do not replace the instructor's architecture.

### The invariant behind every waveform

Each channel has its own acceptance event:

$$
\begin{aligned}
aw\_fire &= AWVALID \land AWREADY \\
w\_fire  &= WVALID  \land WREADY  \\
b\_fire  &= BVALID  \land BREADY  \\
ar\_fire &= ARVALID \land ARREADY \\
r\_fire  &= RVALID  \land RREADY
\end{aligned}
$$

The waveform-based approach may use delays or counters to make a classroom
trace, but a payload belongs to its channel's `VALID`. If `VALID=1` and
`READY=0`, that payload remains stable until its own `fire` edge.

#### Video 55 - Section 5 agenda

![Original full-frame Section 5 agenda](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/055-agenda-50.png)

The agenda separates four jobs: choose a configuration, draw the no-pipeline
timing, implement the timing, and prove it with a protocol checker. This order
matters. The RTL should be explainable as a direct implementation of a legal
trace; the checker then tests the protocol contract rather than whether the
waveform merely looks plausible.

#### Video 56 - Different AXI configurations

![Original full-frame AXI configuration map with single-beat, burst, pipelined, and implementation choices](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/056-different-axi-configurations-25.png)

The left blocks classify the transaction shape; the handwritten list on the
right classifies implementation style:

- **single beat** versus **burst** says how many data beats belong to one
  address command;
- **without pipeline** versus **with pipeline** says whether a new operation
  may begin before the previous response completes;
- **waveform based** versus **FSM based** says how the teaching control is
  organized, not which AXI rules apply;
- the protocol checker observes the same five channels regardless of how the
  internal control was written.

This section chooses single beat, no pipeline, and waveform-derived control.
That limits throughput but reduces bookkeeping: one operation owns all local
flags until its B or R response handshake finishes.

#### Video 57 - Waveform-based versus FSM-based implementation

![Original full-frame waveform-based implementation and highlighted Verilog timing logic](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/057-implementation-approaches-waveform-vs-fsm-25.png)

The first frame ties counter values to the waveform. A command input starts the
sequence, channel `VALID` values appear at selected phases, and a response
finishes the operation. This is useful for learning because every register can
be traced back to a row of the drawing.

![Original full-frame comparison of the timing waveform with an FSM flowchart](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/057-implementation-approaches-waveform-vs-fsm-75.png)

The second frame shows the FSM alternative. The implementation form changes,
but the safety requirements do not:

- state or counter advances caused by a transfer must be handshake-gated;
- `VALID` cannot be a fixed pulse that expires during back-pressure;
- address, data, strobes, and responses must remain stable with stalled
  `VALID`;
- the no-pipeline policy must block a new command until the current terminal
  response handshakes.

#### Video 58 - Signals for single beat without pipeline, part 1

![Original full-frame no-pipeline write sequence and Manager/Subordinate port diagram](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/058-signals-in-single-beat-without-pipeline-p1-25.png)

The diagonal boxes at the top show three writes serialized in time: address,
data, then response, followed by the next operation. AXI permits AW and W to
handshake in either order; the drawing chooses an order for this teaching
Manager. A compatible Subordinate must still accept either legal order unless
its documented interface imposes a narrower, jointly agreed profile.

The lower block diagram exposes local command inputs such as write enable,
input address, input data, and write strobes. Those are not AXI signals. They
are the course's application-side request interface, translated into AW/W/B
channel activity by the Manager.

##### Handwritten page 32 - Single beat without pipelining

![Handwritten AXI notes: Single beat without pipelining](../../../_internal/Protocols/04%20AMBA/03%20AXI/handwritten/images/32-single-beat-without-pipelining.jpg)

**Integration note:** The three write phases are address, data, and response.
This teaching profile completes all work for one request before starting
another; waveform-oriented and FSM-oriented RTL are two organizations of that
policy, not different AXI protocols.

#### Video 59 - Signals for single beat without pipeline, part 2

![Original full-frame completed single-beat read/write channel diagram and waveforms](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/059-signals-in-single-beat-without-pipeline-p2-25.png)

The read half adds AR and R below the write sequence. A read contains no
separate response channel: `RRESP` travels with `RDATA` on the R channel. The
teaching Manager therefore has two terminal events:

- a write returns to idle after `b_fire`;
- a read returns to idle after `r_fire`.

The visible reset and clock belong to the local block as well as the AXI
interface. On reset, all Manager-driven `VALID` outputs and all
Subordinate-driven `VALID` outputs must become inactive so stale transactions
cannot survive into the next run.

#### Video 60 - I/O ports of the waveform-based design

![Original full-frame Manager I/O declaration beside the five-channel waveform and block diagram](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/060-i-o-ports-in-single-beat-without-pipeline-75.png)

The editor shows the instructor's local names and direction boundary. Read it
from the Manager's point of view:

- AW, W, and AR payload/`VALID` signals are outputs;
- `AWREADY`, `WREADY`, `BVALID/BRESP`, `ARREADY`, and
  `RVALID/RDATA/RRESP` are inputs;
- `BREADY` and `RREADY` are Manager outputs;
- local `i_wr`, `i_addrin`, `i_datain`, and `i_strb` values start or describe
  the classroom operation.

The course port list deliberately omits optional `AxPROT`. When the code is
used only with this paired teaching Subordinate, that simplification is part of
the local interface contract. It is not evidence that `AWPROT`/`ARPROT` never
exist on AXI4-Lite interfaces.

#### Video 61 - Write-only Manager implementation, part 1

![Original full-frame write-only Manager waveform and address-channel RTL](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/061-axil-master-with-only-write-implementation-p1-25.png)

The left waveform is the specification for the registers on the right. Reset
clears channel `VALID` outputs. A new local write causes the address value to be
captured and `AWVALID` to be asserted. Once asserted, `AWVALID` stays HIGH until
`aw_fire`; the address register is not replaced during that stall.

The no-pipeline assumption means a new `i_wr` request is not independently
buffered while a write is already active. The caller must obey the exact local
command contract documented in the instructor code: present a new command only
when the teaching Manager is ready for one.

![Original full-frame continuation of write-only Manager address and control RTL](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/061-axil-master-with-only-write-implementation-p1-75.png)

The continuation makes a common hardware point visible: nonblocking
assignments update after the sampled edge. Conditions inside the same clocked
block read the pre-edge values. When reasoning about “set valid” and “clear on
ready,” explicitly identify which branch wins if both conditions are true.

##### Handwritten page 33 - AXI4-Lite write Manager ports and reset

![Handwritten AXI notes: AXI4-Lite write Manager ports and reset](../../../_internal/Protocols/04%20AMBA/03%20AXI/handwritten/images/33-axil-write-master-ports-and-reset.jpg)

**Integration note:** The port list exposes independent address, data, and
response channels. Reset clears the offered controls, while a new command must
create separate `AWVALID` and `WVALID` obligations that remain until their
respective handshakes.

##### Handwritten page 34 - Write address and response control

![Handwritten AXI notes: Write address and response control](../../../_internal/Protocols/04%20AMBA/03%20AXI/handwritten/images/34-axil-write-master-address-and-response-logic.jpg)

**Integration note:** The Manager starts a write, waits for address acceptance,
and later acknowledges `BVALID`. Do not clear address and data validity from a
single combined condition unless the design has separately recorded which
handshake has completed.

#### Video 62 - Write-only Manager implementation, part 2

![Original full-frame write-data and write-response logic beside the reference waveform](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/062-axil-master-with-only-write-implementation-p2-25.png)

This part adds `WDATA`, `WSTRB`, `WVALID`, and response readiness. Data and
strobes are one payload and must be captured together. During
`WVALID && !WREADY`, neither can change.

The response side completes the operation. `BREADY` indicates that the Manager
can accept `BRESP`; completion is `b_fire`, not the first cycle in which
`BVALID` becomes visible. The teaching design keeps one operation active until
that edge, which is the state that enforces “without pipeline.”

![Original full-frame completed write-only Manager RTL and waveform correspondence](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/062-axil-master-with-only-write-implementation-p2-75.png)

When reviewing this frame, follow one command through three independent flags:
address offered/accepted, data offered/accepted, response awaited/accepted.
Treating them as one universal “write done” pulse hides legal AW/W timing
differences and is the first thing a protocol checker will expose.

##### Handwritten page 35 - Write data control and Subordinate ports

![Handwritten AXI notes: Write data control and Subordinate ports](../../../_internal/Protocols/04%20AMBA/03%20AXI/handwritten/images/35-axil-write-data-and-subordinate-ports.jpg)

**Integration note:** `WDATA` and `WSTRB` must remain stable until `WREADY`. The
Subordinate interface below must be prepared for `AW` and `W` to arrive in
either order and retain the first item until its partner arrives.

#### Video 63 - Write-only Subordinate implementation, part 1

![Original full-frame write-only Subordinate address logic beside the transaction waveform](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/063-axil-slave-with-only-write-implementation-p1-25.png)

The Subordinate owns `AWREADY`. Its address-capture register changes only on
`aw_fire`. If it lowers `AWREADY`, the Manager continues holding the offered
address; the Subordinate must not consume it early.

Because the paired lesson is one-outstanding and no-pipeline, one address slot
is sufficient. That is an implementation capacity limit, not an AXI rule. The
flag representing a stored address is cleared only when the write has advanced
far enough that the slot can safely be reused.

##### Handwritten page 36 - Subordinate write-address control

![Handwritten AXI notes: Subordinate write-address control](../../../_internal/Protocols/04%20AMBA/03%20AXI/handwritten/images/36-axil-subordinate-write-address-control.jpg)

**Integration note:** The page begins the `AWREADY` logic and then contrasts
write and read channels. A correct Subordinate must not discard an accepted
address merely because the matching data has not arrived in the same cycle.

#### Video 64 - Write-only Subordinate implementation, part 2

![Original full-frame Subordinate write-data capture and response logic](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/064-axil-slave-with-only-write-implementation-p2-25.png)

The data branch qualifies storage with `w_fire`. `WSTRB` determines which byte
lanes are updated; a low strobe bit preserves the previous byte. The response
branch asserts `BVALID` only after the design regards both address and data as
accepted.

![Original full-frame completed Subordinate response logic and signal directions](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/064-axil-slave-with-only-write-implementation-p2-75.png)

Once `BVALID` is HIGH, `BRESP` is held until `b_fire`. The course normally
returns `OKAY` for the demonstrated address range. If address decode or the
register operation can fail, the same held response mechanism must carry
`SLVERR` or `DECERR` as appropriate.

#### Video 65 - Verifying the write-only Manager and Subordinate

![Original full-frame testbench stimulus for the write-only Manager/Subordinate pair](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/065-verifying-operation-of-master-and-slave-with-only-write-25.png)

The testbench frame shows reset, command generation, and repeated data/address
values. A useful trace starts at the local request and records five edges:
request capture, `aw_fire`, `w_fire`, `b_fire`, and local completion. AW and W
may share an edge in this test, but the scoreboard should track them
independently.

![Original full-frame Vivado waveform for completed AXI4-Lite writes](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/065-verifying-operation-of-master-and-slave-with-only-write-75.png)

In the waveform, check that every address/data item remains unchanged across a
stall, `BVALID` follows accepted write inputs, and the next command begins only
after the response handshake. Seeing expected data is necessary but not
sufficient; these channel-timing checks prove the interface behavior.

#### Lessons 66-67 - Design and testbench code resources

The instructor supplies the write-only design and testbench as separate code
resources. The repository preserves them under the Section 5 area in
[Code](Code/README.md), with comments identifying local-command assumptions,
omitted optional AXI4-Lite signals, one-outstanding capacity, and the exact
event that completes a write. The code remains the instructor's teaching
architecture rather than a redesigned implementation.

#### Video 68 - Adding the AXI Protocol Checker, part 1

![Original full-frame AMD PG101 protocol-independent port descriptions used by the lesson](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/068-validating-transactions-with-axi-protocol-checker-p1-25.png)

The documentation frame separates checker infrastructure from monitored AXI
signals. The checker receives a clock and resets, observes the interface, and
reports violations. It does not become a participant in the handshakes.

![Original full-frame Vivado checker instantiation and teaching design connection](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/068-validating-transactions-with-axi-protocol-checker-p1-75.png)

AMD PG101 describes the core as an AXI4/AXI3/AXI4-Lite traffic monitor that can
report violations in simulation, a status vector, and debug nets. The monitor
must see the same clock/reset domain as the observed interface. Tying off an
unused checker port must match the configured protocol; it must not fabricate
a handshake that the DUT never drove.

#### Video 69 - Adding the AXI Protocol Checker, part 2

![Original full-frame Vivado block design containing Manager, Subordinate, and AXI checker](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/069-validating-transactions-with-axi-protocol-checker-p2-25.png)

The block design places the checker alongside the link. Both endpoints remain
connected directly; the checker taps AW, W, B, AR, and R. This is observation,
not arbitration or buffering.

![Original full-frame expanded checker-to-interface wiring in Vivado](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/069-validating-transactions-with-axi-protocol-checker-p2-75.png)

For the write-only demonstration, unused read-channel monitor inputs must be
configured or tied consistently. The important monitored properties include
payload stability while stalled, `VALID` persistence, response ordering, and
reset behavior. A green connection diagram is not proof; the checker result
and waveform are the proof surfaces.

#### Video 70 - Adding the AXI Protocol Checker, part 3

![Original full-frame checker-related testbench code and configured signals](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/070-validating-transactions-with-axi-protocol-checker-p3-25.png)

The source frame shows the final integration. Keep checker status visible in
simulation so a passing data comparison cannot hide a protocol violation. A
test should deliberately apply delayed `READY` values; otherwise the most
important hold-until-handshake rules are never exercised.

![Original full-frame Vivado waveform with the AXI checker active](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/070-validating-transactions-with-axi-protocol-checker-p3-75.png)

The waveform should be read in two layers: first confirm expected transaction
data, then confirm that no checker assertion/status bit reports a violation.
The official [AMD AXI Protocol Checker overview](https://docs.amd.com/r/en-US/pg101-axi-protocol-checker/Overview)
explains those reporting paths.

#### Lessons 71-72 - Checker design and testbench resources

These resources preserve the checker-connected design and its testbench. Their
comments identify which read-side inputs are unused in the write-only lesson,
how they are tied for the selected checker configuration, and which checker
outputs are observation-only.

#### Video 73 - Read-only Manager implementation, part 1

![Original full-frame read-only Manager architecture, AR/R waveform, and port directions](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/073-axil-master-with-only-read-implementation-p1-25.png)

The frame mirrors the earlier write design with fewer phases: capture a local
read address, offer it on AR, then wait for one R result. `ARADDR` is held with
`ARVALID` until `ar_fire`. The Manager must be prepared to accept both `RDATA`
and `RRESP` as one payload.

![Original full-frame read-only Manager block relationship and timing](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/073-axil-master-with-only-read-implementation-p1-75.png)

With no pipeline, the local side cannot issue a second address while the first
read result is outstanding. The terminal event is `r_fire`; merely seeing
`RVALID` is not completion if `RREADY` is LOW.

##### Handwritten page 37 - AXI4-Lite read Manager interface

![Handwritten AXI notes: AXI4-Lite read Manager interface](../../../_internal/Protocols/04%20AMBA/03%20AXI/handwritten/images/37-axil-read-master-interface.jpg)

**Integration note:** The read path contains an `AR` request and an `R`
response. The Manager owns `ARVALID`, `ARADDR`, and `RREADY`; the Subordinate
owns `ARREADY`, `RVALID`, `RDATA`, and `RRESP`.

##### Handwritten page 38 - Read-address and read-data control

![Handwritten AXI notes: Read-address and read-data control](../../../_internal/Protocols/04%20AMBA/03%20AXI/handwritten/images/38-axil-read-master-address-and-data-control.jpg)

**Integration note:** The Manager holds `ARVALID` until the address handshake
and asserts `RREADY` when it can accept the response. `RVALID` must be generated
by the Subordinate independently of whether the Manager has already raised
`RREADY`.

#### Video 74 - Read-only Manager implementation, part 2

![Original full-frame read-address register and ARVALID logic](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/074-axil-master-with-only-read-implementation-p2-25.png)

The editor shows the address register and valid-control branches. Reset clears
`ARVALID`; a new local read captures the address and asserts it; `ar_fire`
releases the offered request. The input address must not feed the bus
combinationally after `ARVALID` is asserted, because the caller could change it
during back-pressure.

![Original full-frame continuation into read-result capture logic](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/074-axil-master-with-only-read-implementation-p2-75.png)

The read-result branch samples `RDATA` and `RRESP` on `r_fire`. If the local
interface exposes only data, an error response can be silently lost; the file
comments must state whether `RRESP` is consumed, ignored, or assumed `OKAY` in
the paired demonstration.

#### Video 75 - Read-only Manager implementation, part 3

![Original full-frame completed Manager read-control RTL and waveform](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/075-axil-master-with-only-read-implementation-p3-25.png)

The completed logic links local busy/completion state to the R handshake. A
robust trace proves that `RREADY` is asserted according to available local
storage, not as a cosmetic pulse after `RVALID`.

![Original full-frame final read-only Manager branches and reset behavior](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/075-axil-master-with-only-read-implementation-p3-75.png)

The teaching implementation has one result slot. If the downstream local logic
cannot always consume the result, `RREADY` must reflect that capacity and the
captured result needs its own valid flag. The exact course code documents the
simpler assumed local behavior rather than silently claiming an unbounded
buffer.

##### Handwritten page 39 - Read-response readiness

![Handwritten AXI notes: Read-response readiness](../../../_internal/Protocols/04%20AMBA/03%20AXI/handwritten/images/39-axil-read-response-ready-control.jpg)

**Integration note:** This page finishes the registered `RREADY` behavior and
response storage. The architectural event is the `RVALID && RREADY` edge; a
pulse policy is acceptable only if it cannot miss a response and meets the
intended throughput.

#### Video 76 - Read-only Subordinate implementation, part 1

![Original full-frame read-only Subordinate port list, decode path, and read waveform](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/076-axil-slave-with-only-read-implementation-p1-25.png)

The Subordinate accepts `ARADDR` on `ar_fire`, decodes the addressed register,
and prepares `RDATA/RRESP`. `ARREADY` describes address-slot capacity; it does
not mean that a read result has already transferred.

![Original full-frame read-data generation and channel directions](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/076-axil-slave-with-only-read-implementation-p1-75.png)

After the result is prepared, `RVALID` remains HIGH until `r_fire`. If the
address is unsupported, the response should describe the decode or slave
error. The classroom design's chosen address range and default behavior are
explicit assumptions in its source comments.

#### Video 77 - Read-only Subordinate implementation, part 2

![Original full-frame read-only Subordinate AR and R channel RTL](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/077-axil-slave-with-only-read-implementation-p2-25.png)

The clocked branches expose the lifetime of a returned result. Data is selected
from the accepted address, `RVALID` marks the result, and `r_fire` frees the
one-entry result slot.

![Original full-frame completed read response logic and reset branches](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/077-axil-slave-with-only-read-implementation-p2-75.png)

Check branch priority when `RREADY` is already HIGH in the cycle `RVALID` is
raised. The intended course timing must not clear a newly produced result using
the pre-edge state incorrectly. Following nonblocking-assignment semantics is
essential here.

#### Video 78 - Connecting the read-only Manager and Subordinate

![Original full-frame top-level Verilog wiring for the read-only pair](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/078-connecting-master-and-slave-25.png)

The top level wires every AR and R signal once, with opposite endpoint
directions. `ARREADY` and `RVALID/RDATA/RRESP` travel from Subordinate to
Manager; `ARVALID/ARADDR` and `RREADY` travel from Manager to Subordinate.

![Original full-frame elaborated Vivado schematic of the read-only connection](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/078-connecting-master-and-slave-75.png)

The elaborated view checks width and direction, but not protocol behavior.
Common clock/reset connection and a clean elaboration are prerequisites for
the waveform test, not its conclusion.

#### Video 79 - Verifying read operation, part 1

![Original full-frame read-only testbench stimulus and expected-data setup](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/079-verifying-operation-p1-25.png)

The testbench issues addresses and observes returned values. The self-checking
model should associate expected data with each accepted AR request, then compare
only on `r_fire`. Comparing whenever `RVALID` is visible can count the same
stalled result more than once.

![Original full-frame continuation of read verification and signal setup](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/079-verifying-operation-p1-75.png)

Reset and first-request timing deserve special attention. A request applied on
the same edge as reset release must obey the synchronous reset convention used
by the DUT; otherwise the testbench may create a race that the protocol does
not define.

#### Video 80 - Verifying read operation, part 2

![Original full-frame Vivado waveform of repeated AXI4-Lite reads](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/080-verifying-operation-p2-25.png)

The waveform exposes the full sequence: local command, AR handshake, R valid,
R handshake, and return to idle. Confirm that every accepted address has one
and only one accepted result.

![Original full-frame later portion of the read waveform with response timing](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/080-verifying-operation-p2-75.png)

Introduce an `RREADY` stall mentally while reading the second frame: the
Subordinate's data and response must freeze, and the Manager must not declare
completion until the eventual handshake.

#### Lesson 81 - Read-path code resource

The resource contains the paired read-only Manager, Subordinate, connection,
and testbench material. Inline comments identify the one-outstanding rule,
local command assumptions, address-decode behavior, and the disposition of
`RRESP`.

#### Videos 82-84 - Protocol checker on the read path

![Original full-frame checker-connected read-path source for lesson 82](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/082-adding-axi-protocol-checker-p1-25.png)

Lesson 82 adds the monitor ports to the read-only pair. AW/W/B monitor inputs
are unused by this teaching path and must be configured consistently; AR/R are
live. The checker should observe the exact `RDATA/RRESP` payload that the
Manager sees.

![Original full-frame checker configuration and source integration for lesson 83](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/083-adding-axi-protocol-checker-p2-75.png)

Lesson 83 completes the source and simulation setup. The blue-highlighted tool
area is configuration, not DUT behavior. Preserve the chosen protocol mode and
data/address widths so the checker interprets the monitored wires correctly.

![Original full-frame final Vivado checker waveform for lesson 84](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/084-adding-axi-protocol-checker-p3-75.png)

Lesson 84 is the proof surface. A passing run requires both correct returned
data and no protocol violation. The most valuable directed tests delay
`ARREADY` and `RREADY`, because those stalls expose request-payload and
result-payload stability errors.

### Section 5 assumptions and boundaries

- One local command is active at a time; there is no request queue.
- AXI4-Lite operations are single beat and use no IDs, burst fields, or last
  signals.
- Optional protection signals are omitted in the paired classroom interface.
- Write and read demonstrations are separated before they are combined in
  Section 6.
- Any ignored response or checker signal is named explicitly in the matching
  source file; omission never silently changes who owns a handshake.
- The Protocol Checker observes the bus and reports violations; it does not
  repair timing.

### Active-recall checkpoint

1. Which edge releases the no-pipeline Manager after a write?
2. Why must AW and W be tracked independently even when the waveform usually
   places them in a convenient order?
3. What local-side assumption prevents a second command from being lost?
4. Which values must remain stable during `WVALID && !WREADY`?
5. When may a Subordinate first assert `BVALID`?
6. Why is an elaborated schematic not proof of AXI compliance?
7. Which event should enqueue an expected read value in a scoreboard?
8. Which event should compare and retire that value?
9. What does the protocol checker observe, and what does it not control?
10. Why are delayed-ready tests more revealing than an always-ready test?

---

## Section 6 - AXI4-Lite Single Beat without Pipeline: FSM Approach

**Course status:** 9/9 lessons complete, covering lessons 85-93.

Section 5 implemented separate write-only and read-only paths by following a
drawn timing sequence. Section 6 combines both paths in one Manager and makes
the control state explicit. The same AXI4-Lite handshakes still govern every
transition; the FSM is an organization method, not a substitute for channel
rules.

### Lessons 85-93

#### Video 85 - Section 6 agenda

![Original full-frame Section 6 agenda](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/085-agenda-50.png)

The agenda has two outcomes: build the combined no-pipeline Manager and connect
it to a Subordinate while retaining protocol checking. “Combined” means the
block can initiate either a read or a write. It does not mean AW/W/B and AR/R
become one channel.

#### Video 86 - Building the Manager FSM

![Original full-frame combined Manager FSM beside write and read waveforms](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/086-buidling-fsm-for-master-25.png)

The flowchart begins in idle, tests the local command type, and enters either a
write path or a read path. The write path must remember two independent request
completions before waiting for B; the read path accepts AR before waiting for
R. Terminal response handshakes return the machine to idle.

![Original full-frame later FSM annotation showing branch and completion conditions](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/086-buidling-fsm-for-master-75.png)

Read the diamonds as sampled events, not level-only labels:

- an AW transition is enabled by `aw_fire`;
- a W transition is enabled by `w_fire`;
- write completion is `b_fire`;
- an AR transition is enabled by `ar_fire`;
- read completion is `r_fire`.

If the drawing serializes AW then W, that is the teaching Manager's issuance
policy. The external AXI4-Lite protocol still defines AW and W as independent,
so the paired Subordinate and any reusable endpoint must not assume universal
same-cycle arrival.

#### Video 87 - Combined Manager I/O ports

![Original full-frame FSM and first half of the combined Manager port list](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/087-master-i-o-ports-25.png)

The first port frame combines the local command interface with write-channel
signals. The local write/read selector and input address are sampled only when
idle accepts a new command. Once an AXI `VALID` is raised, its payload comes
from held registers rather than a changing caller input.

![Original full-frame complete Manager I/O list including the read channels](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/087-master-i-o-ports-75.png)

The second frame completes AR/R. Verify signal ownership at the declaration:
the Manager outputs `AWVALID`, `WVALID`, `BREADY`, `ARVALID`, and `RREADY`; it
inputs the corresponding ready/valid response signals. `BRESP` and `RRESP` are
status payloads, not ready signals.

The course interface omits optional protection fields and supports one command
at a time. Those are declared teaching constraints in the matching
[Code](Code/README.md), not alternate AXI meanings.

##### Handwritten page 40 - Combined AXI4-Lite Manager ports

![Handwritten AXI notes: Combined AXI4-Lite Manager ports](../../../_internal/Protocols/04%20AMBA/03%20AXI/handwritten/images/40-axil-combined-manager-ports-and-channels.jpg)

**Integration note:** The combined block exposes three write channels and two
read channels. With one outstanding operation, the control FSM must arbitrate
local read/write requests and remember which response completes the selected
command.

#### Video 88 - Manager implementation part 1: write

![Original full-frame write FSM branch beside the first write-control RTL](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/088-master-implementation-p1-write-25.png)

The state register is reset to idle. The next-state block gives a default before
the `case`, avoiding unintended latches. In the write path, address and data
valid flags correspond to outstanding channel items, not arbitrary one-cycle
pulses.

![Original full-frame later write-state RTL with handshake conditions](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/088-master-implementation-p1-write-75.png)

The highlighted branches show why pre-edge versus post-edge state matters. A
handshake condition consumes the currently offered item. If a flag is both set
for a new item and cleared for an old handshake in one clocked block, branch
priority must preserve the instructor's intended single-item lifetime.

##### Handwritten page 41 - Combined Manager write FSM

![Handwritten AXI notes: Combined Manager write FSM](../../../_internal/Protocols/04%20AMBA/03%20AXI/handwritten/images/41-axil-manager-write-fsm.jpg)

**Integration note:** The state sketch sequences address/data acceptance and the
write response. Command inputs should be captured before they can change, and
any timeout behavior is a teaching-design policy rather than part of the AXI
protocol.

#### Video 89 - Manager implementation part 2: write

![Original full-frame completed write-side state flow and address/data logic](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/089-master-implementation-p2-write-25.png)

The flowchart now reaches response wait. Address and data acceptance may occur
on different edges; local completion must wait for `b_fire`. `BRESP` is sampled
with that event. If the teaching local interface does not expose an error, the
source comments identify the response assumption rather than pretending errors
cannot occur.

![Original full-frame write response and ready-control RTL](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/089-master-implementation-p2-write-75.png)

`BREADY` expresses capacity to retire the response. The no-pipeline FSM keeps
new command acceptance disabled until the B handshake returns it to idle. This
single outstanding restriction is what makes one response unambiguous without
an internal queue.

#### Video 90 - Manager implementation part 3: read

![Original full-frame read branch of the combined FSM and AR/R RTL](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/090-master-implementation-p3-read-25.png)

The read branch captures the local address, asserts `ARVALID`, and waits for
`ar_fire`. It then accepts one `RDATA/RRESP` payload on `r_fire`. The result is
not valid merely because wires contain a value; it is valid because `RVALID`
marks it and `RREADY` accepts it.

![Original full-frame completed read-state logic and return-to-idle branch](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/090-master-implementation-p3-read-75.png)

During `RVALID && !RREADY`, the Subordinate holds data/response and the FSM must
remain in its receive state. Returning to idle from a level of `RVALID` without
requiring `RREADY` would lose a stalled response.

##### Handwritten page 42 - Write-response completion and read start

![Handwritten AXI notes: Write-response completion and read start](../../../_internal/Protocols/04%20AMBA/03%20AXI/handwritten/images/42-axil-manager-write-response-and-read-start.jpg)

**Integration note:** The upper notes finish the `B` channel, while the lower
notes open the read branch. Each state advances on its exact channel handshake;
a mere assertion of `VALID` or `READY` is not completion.

##### Handwritten page 43 - Read-address acceptance and data counting

![Handwritten AXI notes: Read-address acceptance and data counting](../../../_internal/Protocols/04%20AMBA/03%20AXI/handwritten/images/43-axil-manager-read-address-and-data-count.jpg)

**Integration note:** The Manager sends `AR`, waits for the response, and
records accepted data. In full AXI, completion must agree with an accepted
`RLAST`; in this Lite teaching path there is only one read-data beat.

#### Video 91 - Verifying the combined Manager

![Original full-frame combined-Manager testbench stimulus](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/091-verifying-operation-of-master-25.png)

The testbench alternates command types. A clean scoreboard maintains separate
expectations for writes and reads: writes retire on B, while reads compare data
and response on R. The local command must be issued only when the one-command
FSM is idle.

![Original full-frame Vivado waveform for combined read and write operation](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/091-verifying-operation-of-master-75.png)

Use the visible state signal as an explanation aid, then verify behavior from
the bus itself. Every `VALID` must persist through stalls, each response must
follow its request, and the FSM must not accept overlapping local operations.
Randomized ready delays are the decisive test for those properties.

#### Lessons 92-93 - Design and testbench code resources

Lesson 92 supplies the combined Manager design and lesson 93 supplies its
testbench. The repository keeps the instructor's module names, state names,
and control structure under [Code](Code/README.md). Inline comments document:

- the one-command/no-pipeline local contract;
- which optional AXI4-Lite ports are absent;
- how `BRESP` and `RRESP` are handled;
- which event completes each command;
- why caller address/data inputs must not change after command acceptance.

### FSM audit checklist

- Every combinational output and `next_state` has a default assignment.
- Reset clears all Manager-driven AXI `VALID` outputs and returns to idle.
- AW, W, B, AR, and R transitions use their own handshake events.
- A stalled payload is held even if an internal counter or unrelated channel
  changes.
- The FSM cannot accept a second local command while a response is outstanding.
- Error responses are either surfaced or explicitly documented as ignored by
  the teaching local interface.

### Active-recall checkpoint

1. Which two write-request events are independent even in one FSM?
2. Why does the write branch return to idle on `b_fire`, not `BVALID` alone?
3. What is held while `ARVALID=1` and `ARREADY=0`?
4. What is held while `RVALID=1` and `RREADY=0`?
5. What internal capacity limit enforces the no-pipeline policy?
6. Why must state-machine branch priority be checked with nonblocking
   assignment semantics?

---

## Section 7 - AXI4-Lite GPIO Use Case

**Course status:** 7/7 lessons complete, covering lessons 94-100.

This section turns the earlier protocol exercises into a small memory-mapped
peripheral. Software-visible register writes control an LED-like GPIO output;
reads return GPIO or status information. The address channel chooses a
register, `WSTRB` chooses bytes inside that register, and the peripheral logic
connects those stored bits to pins.

### Lessons 94-100

#### Video 94 - Section 7 agenda

![Original full-frame Section 7 agenda](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/094-agenda-50.png)

The single agenda item—build AXI4-Lite GPIO from scratch—contains three separate
engineering problems: protocol termination, register-file semantics, and safe
external-pin handling. Keeping those layers separate makes the design easier
to verify.

#### Video 95 - Generating register data from `WDATA` and `WSTRB`

![Original full-frame GPIO register map, byte lanes, and AXI4-Lite write waveform](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/095-building-axi-lite-gpio-ip-p1-generating-data-from-wdata-and-wstrb-25.png)

The handwritten byte boxes show the exact register update. For a 32-bit data
bus, `WSTRB[0]` controls bits `[7:0]`, `WSTRB[1]` controls `[15:8]`, and so on.
For byte lane $i$:

$$
gpio\_q[8i+7:8i] \leftarrow
\begin{cases}
WDATA[8i+7:8i], & WSTRB[i]=1 \\
gpio\_q[8i+7:8i], & WSTRB[i]=0
\end{cases}
$$

![Original full-frame completed WSTRB example beside read and write timing](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/095-building-axi-lite-gpio-ip-p1-generating-data-from-wdata-and-wstrb-75.png)

The merge occurs only for an accepted write-data item associated with the
accepted target address. A low strobe preserves the old byte; it does not write
zero. Address decode and strobe merge therefore belong to the same committed
write operation, even if AW and W arrived on different cycles.

##### Handwritten page 44 - GPIO registers and byte strobes

![Handwritten AXI notes: GPIO registers and byte strobes](../../../_internal/Protocols/04%20AMBA/03%20AXI/handwritten/images/44-axi-lite-gpio-registers-and-byte-strobes.jpg)

**Integration note:** Each `WSTRB` bit enables one byte lane of the GPIO
register update. Partial writes therefore require per-byte write enables rather
than replacing all 32 bits whenever any strobe is asserted.

#### Video 96 - Debouncing the GPIO input

![Original full-frame debounce counter RTL and switch-bounce diagram](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/096-building-axi-lite-gpio-ip-p2-debouncing-25.png)

The right diagram shows a mechanical button oscillating before it settles. The
counter on the left accepts a new logical level only after the sampled input
has remained consistently different for the selected interval. A short glitch
resets or fails to complete the count.

![Original full-frame later debounce RTL with stable-level timing notes](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/096-building-axi-lite-gpio-ip-p2-debouncing-75.png)

Debouncing and clock-domain safety are different jobs. A physical button is
asynchronous to `ACLK`; production hardware normally passes it through a
metastability synchronizer before the debounce counter consumes it. The course
code demonstrates the debounce decision and its chosen count width. Its inline
comments identify the assumed clock rate, debounce interval, initial level,
and whether synchronization is outside the lesson block.

##### Handwritten page 45 - GPIO button debouncing

![Handwritten AXI notes: GPIO button debouncing](../../../_internal/Protocols/04%20AMBA/03%20AXI/handwritten/images/45-gpio-button-debouncing.jpg)

**Integration note:** The sample-wait-sample idea rejects short mechanical
transitions. Because the external switch is asynchronous to `ACLK`,
synchronization must precede the debounce filter so metastability is not treated
as an ordinary bounce sample.

#### Video 97 - GPIO write FSM

![Original full-frame GPIO write FSM beside the first write-channel RTL](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/097-building-axi-lite-gpio-ip-p3-write-fsm-25.png)

The flowchart accepts address and data, performs the register update, then
returns one B response. The register must update once per logical write, not
once per cycle that `AWVALID` or `WVALID` happens to remain HIGH.

![Original full-frame completed GPIO write FSM and WSTRB-controlled update code](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/097-building-axi-lite-gpio-ip-p3-write-fsm-75.png)

The editor makes the byte-loop hardware explicit: each strobe controls one
byte's write enable. The address decoder determines which GPIO register those
enables target. Unsupported or read-only addresses must not modify storage;
the paired teaching code documents the response used for that case.

`BVALID` remains asserted until `b_fire`. Clearing it after one clock would
make the register update visible while potentially losing the response—the
software-visible operation would no longer have a reliable completion.

##### Handwritten page 46 - GPIO read/write flowchart

![Handwritten AXI notes: GPIO read/write flowchart](../../../_internal/Protocols/04%20AMBA/03%20AXI/handwritten/images/46-gpio-read-write-flowchart.jpg)

**Integration note:** The flowchart serializes register access and returns
either a response or read data. It should accept `AW` and `W` independently
rather than requiring both `VALID` signals in the same cycle, while still
allowing only the intended number of outstanding commands.

##### Handwritten page 47 - GPIO Subordinate write FSM

![Handwritten AXI notes: GPIO Subordinate write FSM](../../../_internal/Protocols/04%20AMBA/03%20AXI/handwritten/images/47-gpio-subordinate-write-fsm.jpg)

**Integration note:** The detailed states retain the write address and wait for
write data before updating the register. `AWREADY` and `WREADY` may be
controlled separately, provided an accepted item is stored until the transaction
can finish.

#### Video 98 - GPIO read FSM

![Original full-frame GPIO read FSM and address-decode RTL](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/098-building-axi-lite-gpio-ip-p4-read-fsm-25.png)

The read path accepts one `ARADDR`, selects the addressed register or input
status, and presents one `RDATA/RRESP` item. Sampling a debounced input into
`RDATA` should create a coherent value for the held response.

![Original full-frame completed read-data mux and response-valid logic](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/098-building-axi-lite-gpio-ip-p4-read-fsm-75.png)

Once `RVALID` is asserted, the selected `RDATA` cannot follow a changing GPIO
pin while stalled. The result must be captured or otherwise guaranteed stable
until `r_fire`. This is the boundary between a live pin and an AXI response
payload.

#### Video 99 - Testing GPIO operation

![Original full-frame GPIO testbench stimulus and expected register values](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/099-building-axi-lite-gpio-ip-p4-testing-operation-25.png)

The source frame drives writes, reads, and GPIO input changes. A strong
scoreboard keeps a byte-accurate shadow register: on each committed write it
merges only enabled lanes, and on each accepted read it compares the returned
value and response.

![Original full-frame GPIO Vivado waveform with AXI writes, reads, and pin behavior](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/099-building-axi-lite-gpio-ip-p4-testing-operation-75.png)

The waveform should prove four relationships:

- output GPIO changes after the intended accepted write;
- disabled strobe lanes retain their previous values;
- a read returns the decoded register or debounced input;
- B and R responses remain held through any injected ready stall.

The debounce test also needs a pulse shorter than the threshold and a stable
level longer than the threshold. Otherwise the waveform only proves direct
sampling, not debouncing.

#### Lesson 100 - GPIO code resource

The Section 7 code folder preserves the instructor's AXI4-Lite GPIO module and
testbench. Its comments state the address map, data width, byte-lane mapping,
clock/debounce assumptions, GPIO synchronization boundary, unsupported-address
behavior, response handling, and one-outstanding capacity. These comments make
the exact classroom implementation safe to revise without replacing it with a
different architecture.

### Peripheral-design checkpoints

- Protocol handshakes decide when a request/result is accepted.
- Address decode decides which register the request targets.
- `WSTRB` decides which bytes inside that register change.
- A stalled `RDATA` value is a held response, not a continuously changing view
  of an input pin.
- Synchronization limits metastability risk; debouncing rejects repeated
  mechanical transitions. One does not replace the other.
- Register side effects occur exactly once for each committed operation.

### Active-recall checkpoint

1. What happens to a byte whose `WSTRB` bit is zero?
2. Why must address and data capture be associated before changing a GPIO
   register?
3. Why is a debounce counter not automatically a metastability synchronizer?
4. Which event should update the scoreboard's shadow register?
5. Why must read data stop following a live pin after `RVALID` is asserted?
6. What two directed stimuli prove the debounce threshold?

---

## Section 8 - AXI4 Full with Hardcoded Next-Address Logic

**Course status:** 12/12 lessons complete, covering lessons 101-112.

This section moves from AXI4-Lite to full AXI4. Bursts, beat counts, last-beat
markers, and transaction IDs return. To isolate channel control from address
mathematics, the first implementation uses a fixed next-address assumption;
Section 9 replaces that shortcut with burst-type-driven generation.

### Full-AXI state that must travel with a transaction

A burst command contains more than an address. At minimum, the teaching logic
must preserve the accepted ID, length, size, and burst type until the data and
response phases have completed. For a burst:

$$
N_{beats}=AxLEN+1
$$

The beat counter advances on an accepted W or R beat. `WLAST`/`RLAST` identify
the final offered beat and are held with that beat during back-pressure.

#### Video 101 - Section 8 agenda

![Original full-frame Section 8 agenda](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/101-agenda-50.png)

The agenda separates full-AXI signal study, single/burst transaction timing,
and paired Manager/Subordinate implementation. “Hardcoded next address” is a
declared teaching boundary, not a general AXI4 address generator.

#### Video 102 - Typical full-AXI transactions

![Original full-frame initial full-AXI burst flow and channel waveforms](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/102-typical-axi-full-transactions-25.png)

The first frame shows a command state feeding repeated data beats. One accepted
AW command controls `AWLEN+1` accepted W items and one B response. One accepted
AR command controls `ARLEN+1` accepted R items.

![Original full-frame expanded read/write transaction flowcharts with beat waveforms](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/102-typical-axi-full-transactions-75.png)

The expanded flowcharts make terminal events visible:

- write address: one `aw_fire`;
- write data: repeat `w_fire`, assert `WLAST` on the final offered beat;
- write completion: one `b_fire`;
- read address: one `ar_fire`;
- read data: repeat `r_fire`, with `RLAST` on the final returned beat.

The counter must not advance during `WVALID && !WREADY` or
`RVALID && !RREADY`. Otherwise the held payload and its last marker would no
longer describe the same beat.

##### Handwritten page 48 - AXI4 single-beat signal set

![Handwritten AXI notes: AXI4 single-beat signal set](../../../_internal/Protocols/04%20AMBA/03%20AXI/handwritten/images/48-axi4-single-beat-signals.jpg)

**Integration note:** The full-AXI address channel retains size, length, burst,
and ID fields even for a single-beat teaching example. A single beat uses
`AWLEN=0`, and the only accepted write-data beat carries `WLAST=1`.

#### Video 103 - Write FSM

![Original full-frame write FSM and burst waveform](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/103-write-fsm-25.png)

The write flow begins with address issue, iterates over data, then waits for the
response. The state alone does not count beats; a handshake-gated counter
determines when the current data item is the last one.

![Original full-frame completed write FSM with final-beat and response branches](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/103-write-fsm-75.png)

For zero-based counter `beat_q`, the last offered beat is typically identified
by `beat_q == AWLEN_q`. The counter increments only on `w_fire`; `WLAST` is
derived from or registered with that same held beat. After final `w_fire`, the
FSM waits for `BVALID` and completes on `b_fire`.

##### Handwritten page 49 - AXI4 write FSM: address and data

![Handwritten AXI notes: AXI4 write FSM: address and data](../../../_internal/Protocols/04%20AMBA/03%20AXI/handwritten/images/49-axi4-write-fsm-address-and-data.jpg)

**Integration note:** The FSM issues the address, streams write beats, and
advances its counter only on `WVALID && WREADY`. Both `AWVALID` and each write
payload must remain stable until their own acceptance edges.

##### Handwritten page 50 - AXI4 write FSM: last beat and response

![Handwritten AXI notes: AXI4 write FSM: last beat and response](../../../_internal/Protocols/04%20AMBA/03%20AXI/handwritten/images/50-axi4-write-fsm-last-and-response.jpg)

**Integration note:** `WLAST` is asserted with the final valid write beat and
held through any stall. Only the accepted final beat leads to the write-response
phase, which finishes on `BVALID && BREADY`.

#### Video 104 - Read FSM

![Original full-frame read FSM and returned burst waveform](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/104-read-fsm-25.png)

The Manager issues one AR command and accepts repeated R beats. `RID` and
`RRESP` accompany every returned beat; `RLAST` marks the final one. A scoreboard
associates the burst with the accepted `ARID`.

![Original full-frame completed read FSM with RLAST termination](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/104-read-fsm-75.png)

The Manager must remain ready only when it has storage for the next result. If
it lowers `RREADY`, `RDATA`, `RRESP`, `RID`, and `RLAST` freeze. The read FSM
leaves its data state only on an accepted beat with `RLAST=1`.

##### Handwritten page 51 - AXI4 read FSM

![Handwritten AXI notes: AXI4 read FSM](../../../_internal/Protocols/04%20AMBA/03%20AXI/handwritten/images/51-axi4-read-fsm.jpg)

**Integration note:** The read sequence sends `AR`, accepts `R` beats, and
completes on an accepted `RLAST`. The Manager controls `RREADY`; the Subordinate
controls `RVALID`, `RDATA`, `RRESP`, and `RLAST`.

#### Video 105 - Implementing the write channel

![Original full-frame write FSM beside Manager write-channel RTL](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/105-implementing-write-channel-25.png)

The editor introduces address/control registers, data/strb/last outputs, and
the write-response inputs. Accepted command fields are held for the complete
burst. The instructor's hardcoded data-width/address-step assumptions are
documented in the matching source rather than generalized silently.

![Original full-frame later write implementation with beat counter and WLAST logic](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/105-implementing-write-channel-75.png)

Trace one stall at the highlighted counter logic: while `WREADY=0`, the counter
does not change, `WDATA/WSTRB/WLAST` do not change, and `WVALID` remains HIGH.
When `w_fire` occurs, the design advances to the next teaching data value or
enters response wait after the final beat.

The implementation uses one outstanding write. Although full AXI supports
multiple IDs and outstanding operations, this block does not need a reorder or
ID queue because it does not overlap commands.

#### Video 106 - Implementing the read channel

![Original full-frame read FSM beside Manager AR/R RTL](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/106-implementing-read-channel-25.png)

The AR registers carry the teaching ID/length/size/burst configuration. After
`ar_fire`, the Manager waits for R items and checks `RLAST` on accepted beats.

![Original full-frame read-result handling and completion logic](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/106-implementing-read-channel-75.png)

`RRESP` must be sampled with each `RDATA` beat. If the teaching local interface
uses only data, the source comments identify that response status is observed,
ignored, or assumed `OKAY`. `RLAST` without `r_fire` is not completion.

#### Lesson 107 - Manager code resource

The instructor's Manager source is preserved under [Code](Code/README.md).
Its inline contract names the fixed data width, hardcoded address step, chosen
burst length/ID behavior, one-outstanding restriction, omitted optional user
signals, and the handling of `BRESP`/`RRESP`.

#### Video 108 - Implementing Subordinate write operation

![Original full-frame full-AXI Subordinate write FSM and first RTL branches](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/108-implementing-slave-write-operation-25.png)

The Subordinate captures AW control, accepts each W beat, applies strobes, and
returns B. It must associate the data stream with the accepted command even
though AXI4 removed AXI3's `WID`.

![Original full-frame later Subordinate write counter, WLAST, and response logic](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/108-implementing-slave-write-operation-75.png)

The expected beat count and accepted `WLAST` must agree. An early or missing
`WLAST` is a protocol error. After the final data handshake, `BID` is derived
from the stored `AWID` and held with `BRESP/BVALID` until `b_fire`.

The memory update occurs only on `w_fire`. `WSTRB` still supplies per-byte write
enables on every full-AXI beat.

#### Video 109 - Subordinate read operation

![Original full-frame full-AXI Subordinate read FSM and address capture](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/109-slave-read-operation-25.png)

The Subordinate stores AR control and produces a sequence of R payloads. `RID`
comes from the stored `ARID`, and `RLAST` is attached to the final offered
beat.

![Original full-frame read-data generation, counter, response, and RLAST RTL](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/109-slave-read-operation-75.png)

The read address used for each teaching beat advances only after `r_fire`.
During an R stall, both the memory-selected data and all sidebands must remain
stable. Re-reading a live memory location combinationally while stalled can
violate that rule if another agent can modify the location; the classroom
memory assumptions are therefore part of the source contract.

#### Lesson 110 - Subordinate code resource

The Subordinate source comments list its accepted ID/length/size/burst fields,
hardcoded next-address rule, memory geometry, response behavior, one-command
capacity, and any ignored protection/cache/QoS/user inputs. The code remains
the instructor's design with its boundaries made explicit.

#### Video 111 - Connecting and verifying the full-AXI pair

![Original full-frame top-level Manager/Subordinate connection RTL](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/111-connecting-master-and-slave-together-and-verifying-design-25.png)

The top level connects all five full-AXI channels, including ID, length, size,
burst, response, and last-beat fields. Width equality and direction are the
first checks; transaction association is the behavioral check.

![Original full-frame Vivado waveform of connected full-AXI write and read transactions](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/111-connecting-master-and-slave-together-and-verifying-design-75.png)

The waveform should prove accepted beat count, monotonic teaching addresses,
correct final-beat markers, ID return, and response completion. A useful
scoreboard records each accepted command and retires it only after the matching
terminal B response or final accepted R beat.

#### Lesson 112 - Connected design code resource

The final resource preserves the paired design and testbench. The testbench
comments identify the fixed burst/data assumptions and which checks would fail
if a different `AxSIZE` or `AxBURST` were applied. Section 9 is the deliberate
extension point for those cases.

### Hardcoded-address boundary

The teaching implementation is correct only for the exact configured profile
named in its source comments. A general full-AXI endpoint must derive beat
addresses from `AxSIZE` and `AxBURST`, enforce the 4-KiB transaction boundary,
and implement WRAP alignment/length rules. Do not remove the comments and reuse
the hardcoded step as if it supported arbitrary AXI4 bursts.

### Active-recall checkpoint

1. Why is `AxLEN` stored as beats minus one?
2. Which event advances the write beat counter?
3. Which signals freeze with a stalled final W beat?
4. Why does AXI4 need no `WID`?
5. Where do `BID` and `RID` originate in a one-outstanding design?
6. Why is a hardcoded four-byte increment not a general AXI4 address
   generator?
7. Which terminal events retire write and read commands in a scoreboard?

---

## Section 9 - AXI4 Full with Burst-Based Address Generation

**Course status:** 16/16 lessons complete, covering lessons 113-128.

The final section replaces the hardcoded next-address shortcut with logic based
on `AxBURST`, `AxSIZE`, and `AxLEN`. It then rebuilds the Manager and
Subordinate around that generator and verifies the connected pair.

For all modes, define:

$$
bytes\_per\_beat=2^{AxSIZE}
$$

`AxSIZE` must describe no more bytes than the data bus can carry. The complete
transaction must also remain within one 4-KiB address region.

### Lessons 113-128

#### Video 113 - Section 9 agenda

![Original full-frame Section 9 agenda](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/113-agenda-50.png)

The agenda explicitly names burst modes, full-AXI read/write transactions,
Manager/Subordinate implementation, and protocol checking. Address generation
is now part of the protocol payload interpretation rather than a fixed local
constant.

#### Video 114 - Understanding FIXED mode

![Original full-frame handwritten FIXED-burst address example](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/114-understanding-fixed-mode-25.png)

In a FIXED burst every beat uses the same byte address:

$$
A_k=A_0
$$

This is useful for FIFO-style or device ports where repeated transfers target
one location whose meaning changes internally. `AxLEN+1` still sets the number
of beats; fixed address does not mean single beat.

![Original full-frame FIXED-burst memory mapping and repeated-address notes](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/114-understanding-fixed-mode-75.png)

The memory sketch shows why the address is not a normal array walk. Each
accepted data beat is a separate transfer even though the address value repeats.
Beat counters and last markers still advance only on data-channel handshakes.

##### Handwritten page 52 - Burst types and a FIXED-address example

![Handwritten AXI notes: Burst types and a FIXED-address example](../../../_internal/Protocols/04%20AMBA/03%20AXI/handwritten/images/52-axi4-burst-types-and-fixed-address-example.jpg)

**Integration note:** The page motivates bursts by amortizing memory-access
latency and lists FIXED, INCR, and WRAP. In FIXED mode every beat uses the same
transfer address even though the data sequence contains multiple beats.

##### Handwritten page 53 - `AxSIZE` and bytes per beat

![Handwritten AXI notes: `AxSIZE` and bytes per beat](../../../_internal/Protocols/04%20AMBA/03%20AXI/handwritten/images/53-axsize-and-bytes-per-beat.jpg)

**Integration note:** The worked values apply `bytes_per_beat = 2^AxSIZE`. A
four-byte beat occupies four byte lanes; an unaligned starting address is
possible only within the protocol's alignment and lane rules, with strobes
identifying valid write lanes.

##### Handwritten page 54 - Beat, burst length, and FIXED addresses

![Handwritten AXI notes: Beat, burst length, and FIXED addresses](../../../_internal/Protocols/04%20AMBA/03%20AXI/handwritten/images/54-beat-burst-length-and-fixed-addresses.jpg)

**Integration note:** A beat is one data-channel transfer, while a burst is the
transaction's ordered beat sequence. `AxLEN+1` is the beat count, and FIXED
leaves the transfer address unchanged for every accepted beat.

#### Video 115 - Implementing FIXED writes

![Original full-frame Verilog FIXED-mode next-address selection](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/115-implementation-of-fixed-mode-during-write-25.png)

The write generator selects the fixed branch from `AWBURST` and keeps the
current address unchanged after each `w_fire`. Address/control fields were
captured at `aw_fire`; a changing external AW bus after that acceptance must not
alter the active burst.

![Original full-frame completed FIXED write-data and address-control RTL](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/115-implementation-of-fixed-mode-during-write-75.png)

The memory side must still apply each beat's `WSTRB`. A repeated address with
different strobes can update different bytes across successive transfers, or
can represent repeated pushes into a side-effecting port depending on the
mapped target.

#### Video 116 - Understanding INCR mode

![Original full-frame handwritten INCR burst with beat spacing](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/116-understanding-incr-mode-25.png)

For aligned incrementing transfers, the teaching sequence is:

$$
A_k=A_0+k\times 2^{AxSIZE}
$$

The handwritten line illustrates successive beats separated by the number of
bytes per transfer, not necessarily by the full bus width.

![Original full-frame INCR examples for several beat sizes and addresses](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/116-understanding-incr-mode-75.png)

For a narrow transfer, byte-lane selection and `WSTRB` must match the current
address. A reusable generator also handles an unaligned first address according
to the AXI rules. The course code's supported alignment and data-width profile
is documented directly in the source.

##### Handwritten page 55 - FIXED and incrementing address examples

![Handwritten AXI notes: FIXED and incrementing address examples](../../../_internal/Protocols/04%20AMBA/03%20AXI/handwritten/images/55-fixed-and-incrementing-address-examples.jpg)

**Integration note:** The top example revisits FIXED addressing; the lower
example begins INCR. For INCR, the next transfer address advances by `2^AxSIZE`
after each beat, subject to the burst boundary rules.

#### Video 117 - Implementing INCR writes

![Original full-frame INCR branch in the write next-address RTL](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/117-implementation-of-incr-mode-during-write-25.png)

The increment branch adds `1 << AWSIZE` after each accepted W beat. It must not
increment merely because `WVALID` is HIGH; a back-pressured beat retains both
its address association and payload.

![Original full-frame later INCR implementation with counter and terminal logic](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/117-implementation-of-incr-mode-during-write-75.png)

Before issuing the command, a Manager or interconnect must ensure the burst does
not cross a 4-KiB boundary. This is a transaction-level condition: compare the
start and final byte-address region, not just each local increment.

#### Video 118 - Understanding WRAP mode

![Original full-frame handwritten WRAP boundary formula and examples](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/118-understanding-wrap-mode-25.png)

A wrapping burst increments normally inside a fixed-size aligned window. Let:

$$
burst\_bytes=(AxLEN+1)\times 2^{AxSIZE}
$$

$$
lower=\left\lfloor\frac{A_0}{burst\_bytes}\right\rfloor burst\_bytes,
\qquad upper=lower+burst\_bytes
$$

When the next increment would reach `upper`, the address wraps to `lower`.

![Original full-frame worked WRAP sequences and wrap-window notes](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/118-understanding-wrap-mode-75.png)

AXI wrapping bursts have 2, 4, 8, or 16 beats, and the start address is aligned
to the transfer size. The start can be inside the wrap window rather than at
its lower boundary, so the visible sequence can increment to the upper edge,
wrap, and finish below the starting address.

##### Handwritten page 56 - WRAP boundary formula

![Handwritten AXI notes: WRAP boundary formula](../../../_internal/Protocols/04%20AMBA/03%20AXI/handwritten/images/56-wrap-boundary-formula.jpg)

**Integration note:** A WRAP burst uses a window of `beats * bytes_per_beat`.
The lower boundary is `floor(start/window) * window`, and the upper boundary is
one window above it; address generation wraps to the lower boundary on reaching
the upper one.

##### Handwritten page 57 - Wrapping address sequence

![Handwritten AXI notes: Wrapping address sequence](../../../_internal/Protocols/04%20AMBA/03%20AXI/handwritten/images/57-wrapping-address-sequence.jpg)

**Integration note:** For four beats of four bytes, the window is 16 bytes. The
address sequence advances by four bytes inside that window and returns to its
lower boundary after the highest transfer address.

##### Handwritten page 58 - WRAP boundary examples

![Handwritten AXI notes: WRAP boundary examples](../../../_internal/Protocols/04%20AMBA/03%20AXI/handwritten/images/58-wrap-boundary-examples.jpg)

**Integration note:** The examples vary `AxLEN`, `AxSIZE`, and the starting
address. Legal AXI WRAP burst lengths are 2, 4, 8, or 16 beats - encoded by
`AxLEN` values 1, 3, 7, or 15.

##### Handwritten page 59 - WRAP length validity and boundary alignment

![Handwritten AXI notes: WRAP length validity and boundary alignment](../../../_internal/Protocols/04%20AMBA/03%20AXI/handwritten/images/59-wrap-length-validity-and-boundary-alignment.jpg)

**Integration note:** The highlighted six-beat case is intentionally invalid:
WRAP length must be a supported power-of-two beat count. The boundary
calculation must use integer floor division so the lower boundary stays aligned
to the complete wrap window.

#### Video 119 - Implementing WRAP writes

![Original full-frame handwritten wrap-boundary calculation used by the RTL](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/119-implementation-of-wrap-mode-during-write-25.png)

The first frame derives lower and upper boundaries from captured length and
size. Hardware implements the powers of two as shifts and masks; no general
divider is required for the legal burst sizes.

![Original full-frame WRAP next-address implementation and worked sequence](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/119-implementation-of-wrap-mode-during-write-75.png)

The branch compares the incremented address with the upper boundary and selects
either that increment or the lower boundary. Boundary state belongs to the
active command and must remain unchanged through W stalls.

The source comments name the supported legal lengths and alignment assumption.
An illegal WRAP length is not made legal by producing some modular sequence; it
must be prevented or reported by the surrounding design/checker policy.

#### Video 120 - Burst modes during read operation

![Original full-frame read-side FIXED, INCR, and WRAP selection RTL](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/120-burst-modes-implementation-during-read-operation-25.png)

The read generator mirrors the write formulas using `ARBURST`, `ARSIZE`, and
`ARLEN`. The Subordinate chooses the address for the next offered R beat after
the current one is accepted.

![Original full-frame completed read next-address, RLAST, and counter logic](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/120-burst-modes-implementation-during-read-operation-75.png)

During `RVALID && !RREADY`, the current address, selected `RDATA`, `RRESP`,
`RID`, and `RLAST` remain stable. The generator advances on `r_fire`; tying it
to the clock or `RVALID` alone would skip memory locations under back-pressure.

##### Handwritten page 60 - AXI course summary and next steps

![Handwritten AXI notes: AXI course summary and next steps](../../../_internal/Protocols/04%20AMBA/03%20AXI/handwritten/images/60-axi-course-summary-and-next-steps.jpg)

**Integration note:** The final page summarizes the three interface families and
the five channels of memory-mapped AXI. AXI-Stream itself has one forward
payload handshake, while AXI4-Lite and AXI4 use the five-channel read/write
structure.

#### Video 121 - Implementing the full Manager

![Original full-frame Manager write/read FSM and complete full-AXI port list](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/121-implementing-master-25.png)

The combined Manager holds command fields, chooses a burst generator, and
controls terminal responses. It remains one-outstanding in the teaching model,
so the active ID and burst context fit in one register set.

![Original full-frame later Manager RTL with burst fields and address updates](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/121-implementing-master-75.png)

Follow the lifetime of each captured field: `AxID` returns on B/R, `AxLEN`
defines counter terminal count, `AxSIZE` defines byte spacing, and `AxBURST`
selects FIXED/INCR/WRAP. Optional lock/cache/protection/QoS/region/user signals
that the course does not implement are listed as omitted or tied assumptions in
the exact source, not given invented behavior.

#### Lesson 122 - Manager code resource

The Section 9 Manager source preserves the instructor's naming and FSM. Its
comments identify legal burst modes and lengths, alignment/data-width profile,
one-outstanding capacity, response handling, 4-KiB responsibility, and every
full-AXI sideband that the teaching interface omits.

#### Video 123 - Implementing Subordinate write

![Original full-frame Subordinate write FSM and burst-address RTL](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/123-implementing-slave-write-25.png)

The write Subordinate captures AW context once and consumes `AWLEN+1` W beats.
The burst generator selects the target byte address for each accepted data
item. `WSTRB` qualifies bytes at that address.

![Original full-frame later Subordinate write logic with WLAST and response generation](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/123-implementing-slave-write-75.png)

The final accepted beat must have `WLAST=1`. After it, the design returns one
held B response with the stored ID. A protocol checker should flag early,
late, or missing `WLAST`; the memory update must not conceal that violation.

#### Video 124 - Implementing Subordinate read

![Original full-frame Subordinate read FSM, address generator, and R-channel RTL](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/124-implementing-slave-read-25.png)

The read Subordinate captures AR context and offers data for the current burst
address. It returns the stored ID on every beat and marks the counter's final
item with `RLAST`.

![Original full-frame later Subordinate read logic with held response and last beat](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/124-implementing-slave-read-75.png)

The final state transition requires `r_fire && RLAST`. If `RLAST` is HIGH while
`RREADY` is LOW, the FSM, address, data, ID, and response all remain on that
final item.

#### Lesson 125 - Subordinate code resource

The source records memory geometry, read/write address calculation, allowed
burst profile, byte-strobe semantics, unsupported-address behavior, response
generation, and ignored optional sidebands. This makes the exact teaching code
auditable without redesigning it.

#### Video 126 - Connecting the final Manager and Subordinate

![Original full-frame final top-level AXI4 connection source](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/126-connecting-master-and-slave-together-25.png)

The top-level source wires all command context and return context with matching
widths. Do a direction audit channel by channel before simulation; a swapped
ready/valid direction can elaborate yet produce a dead interface.

![Original full-frame final full-AXI waveform with burst addresses, data, IDs, and last markers](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/126-connecting-master-and-slave-together-75.png)

The final waveform is the course-level proof. For each command, reconstruct the
expected address sequence from mode/size/length, circle accepted data beats,
check the final marker, then verify ID and response. Repeat with ready stalls so
the sequence proves hold behavior as well as the no-stall result.

#### Lessons 127-128 - Final design and testbench resources

Lesson 127 contains the connected design and lesson 128 contains the final
testbench. The code comments map each stimulus to FIXED, INCR, or WRAP and state
the expected address sequence, response, ID, beat count, and last-beat edge.
The testbench preserves the instructor's scenario order and naming.

### Burst-address reference

- **FIXED:** keep the same address for every beat.
- **INCR:** add `1 << AxSIZE` after each accepted beat.
- **WRAP:** increment inside an aligned window of
  `(AxLEN+1) << AxSIZE` bytes and wrap from its upper boundary to its lower
  boundary.
- Advance only on the appropriate data-channel handshake.
- Hold command context for the whole burst.
- Never allow one transaction to cross a 4-KiB boundary.
- Legal WRAP lengths are 2, 4, 8, and 16 beats.

These rules are checked against the official
[Arm AMBA AXI and ACE Protocol Specification](https://developer.arm.com/-/media/Arm%20Developer%20Community/PDF/IHI0022H_amba_axi_protocol_spec.pdf).

### Active-recall checkpoint

1. What address sequence does FIXED mode generate?
2. What quantity does `1 << AxSIZE` represent?
3. How are WRAP lower and upper boundaries calculated?
4. Why must WRAP length be known before the first data beat?
5. Which event advances a write address generator? Which advances a read
   generator?
6. What remains stable during a stalled final R beat?
7. Why is one register set sufficient for the course's active burst context?
8. What extra structure would multiple outstanding IDs require?
9. What must a final scoreboard derive before it can check data?
