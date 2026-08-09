# Section 1 - Introduction to AXI

[Course hub](README.md) | [AXI chapter](../README.md) | [Next: Section 2](Section%2002%20-%20AXI-Stream%20Interface%20Fundamentals.md)

**Course status:** 10/10 lessons complete. Videos 1-9 are explained below; lesson 10 is the matching code resource.

The section follows one causal path: choose the correct AXI family, identify
the channels and their owners, define the accepted-transfer edge, turn that
rule into source and destination RTL, and finally prove it in a waveform.
Lesson 10 is the matching code resource rather than a separate video.

## Lessons 1-10

### Video 1 - Agenda

![Agenda listing AXI interface types and the valid-ready implementation](../images/Day%2001/01-agenda-50.png)

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

![AXI family comparison and ADC-to-FIR signal-processing path](../images/Day%2001/02-axi-family-use-cases-30.png)

The right side shows the cleanest AXI-Stream mental model: samples leave an ADC,
enter an FIR filter, and continue in one direction. The filter does not need a
new destination address with every sample. It needs the next sample plus a way
to pause the producer if its pipeline cannot accept one.

![Processor, register peripheral, and the AXI family selection table](../images/Day%2001/02-axi-family-use-cases-72.png)

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

![Lecture comparison of the AXI-Stream, AXI4-Lite, and AXI4 signal groups](../images/Day%2001/03-interface-pins-28.png)

![Expanded AXI4 signal-group comparison](../images/Day%2001/03-interface-pins-72.png)

![Fullscreen interface-pin comparison without the course sidebar or player controls](../images/Day%2001/03-interface-pins-fullscreen.png)

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

![Simple memory drawing and the four missing-control questions](../images/Day%2001/04-simple-vs-axi-memory-30.png)

The whiteboard lists four questions: when write/read data is valid, when an
address is valid, whether an update succeeded, and whether the target can accept
work. A bare address/data bundle does not answer them. It needs an external
timing convention or explicit controls.

![Five AXI memory-mapped channels with separate timing waveforms](../images/Day%2001/04-simple-vs-axi-memory-72.png)

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

![Source-to-destination valid-ready waveform beside the Arm rule excerpt](../images/Day%2001/05-handshake-fundamentals-30.png)

![Three legal relative timings for valid and ready](../images/Day%2001/05-handshake-fundamentals-72.png)

![Fullscreen valid-ready timing and the three handshake rules](../images/Day%2001/05-handshake-fullscreen.png)

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

![Handshake rule slide with the source and destination waveform](../images/Day%2001/06-handshake-rules-28.png)

![Ready-before-valid, valid-before-ready, and simultaneous cases](../images/Day%2001/06-handshake-rules-72.png)

![Fullscreen handshake-rule frame with source and destination ownership](../images/Day%2001/06-handshake-rules-fullscreen.png)

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

![Two-state source flowchart beside the initial Verilog](../images/Day%2001/07-handshake-rtl-p1-20.png)

![Source reset and new-data state logic](../images/Day%2001/07-handshake-rtl-p1-50.png)

![Wait-for-receiver state holding valid until ready](../images/Day%2001/07-handshake-rtl-p1-82.png)

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

![Receiver flowchart: ready, wait for valid, and receive](../images/Day%2001/08-handshake-rtl-p2-20.png)

![Receiver wait-for-data state and data capture](../images/Day%2001/08-handshake-rtl-p2-52.png)

![Receiver process-data state returning to readiness](../images/Day%2001/08-handshake-rtl-p2-84.png)

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

![Simulation during reset and the first ready state](../images/Day%2001/09-verify-handshake-18.png)

![Waveform where valid and ready overlap for acceptance](../images/Day%2001/09-verify-handshake-52.png)

![Post-edge Receiver data update in the verification waveform](../images/Day%2001/09-verify-handshake-84.png)

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

### Lesson 10 - Code resource

The course's first code resource belongs to this section. Its reusable rule is
that all state, counter, and payload updates must be enabled by the same
accepted-transfer event used throughout these notes:

$$
\text{fire}=\text{VALID}\land\text{READY}
$$

## Section 1 completion checkpoint

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

[Return to the course hub](README.md).
