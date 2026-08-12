# Section 5 - AXI4-Lite Single Beat without Pipeline: Waveform Approach

[Previous: Section 4](Section%2004%20-%20Getting%20Started%20with%20AXI4-Lite.md) | [Course hub](../Course%20Atlas.md) | [AXI chapter](../README.md) | [Next: Section 6](Section%2006%20-%20AXI4-Lite%20Single%20Beat%20without%20Pipeline%20-%20FSM%20Approach.md)

**Course status:** 30/30 lessons complete, covering lessons 55-84.

This section implements one outstanding AXI4-Lite operation at a time. The
instructor first draws the legal waveforms, then makes the Manager and
Subordinate reproduce those waveforms with counters, flags, and small control
blocks. It ends by inserting AMD's AXI Protocol Checker between the two blocks.

The design is intentionally a teaching implementation. Keep its exact signal
and module naming when studying the matching files under [Code](../Code/README.md).
The notes below identify the assumptions and ignored signals beside the lesson
that introduces them; they do not replace the instructor's architecture.

## The invariant behind every waveform

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

### Video 55 - Section 5 agenda

![Original full-frame Section 5 agenda](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/055-agenda-50.png)

The agenda separates four jobs: choose a configuration, draw the no-pipeline
timing, implement the timing, and prove it with a protocol checker. This order
matters. The RTL should be explainable as a direct implementation of a legal
trace; the checker then tests the protocol contract rather than whether the
waveform merely looks plausible.

### Video 56 - Different AXI configurations

![Original full-frame AXI configuration map with single-beat, burst, pipelined, and implementation choices](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/056-different-axi-configurations-25.png)

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

### Video 57 - Waveform-based versus FSM-based implementation

![Original full-frame waveform-based implementation and highlighted Verilog timing logic](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/057-implementation-approaches-waveform-vs-fsm-25.png)

The first frame ties counter values to the waveform. A command input starts the
sequence, channel `VALID` values appear at selected phases, and a response
finishes the operation. This is useful for learning because every register can
be traced back to a row of the drawing.

![Original full-frame comparison of the timing waveform with an FSM flowchart](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/057-implementation-approaches-waveform-vs-fsm-75.png)

The second frame shows the FSM alternative. The implementation form changes,
but the safety requirements do not:

- state or counter advances caused by a transfer must be handshake-gated;
- `VALID` cannot be a fixed pulse that expires during back-pressure;
- address, data, strobes, and responses must remain stable with stalled
  `VALID`;
- the no-pipeline policy must block a new command until the current terminal
  response handshakes.

### Video 58 - Signals for single beat without pipeline, part 1

![Original full-frame no-pipeline write sequence and Manager/Subordinate port diagram](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/058-signals-in-single-beat-without-pipeline-p1-25.png)

The diagonal boxes at the top show three writes serialized in time: address,
data, then response, followed by the next operation. AXI permits AW and W to
handshake in either order; the drawing chooses an order for this teaching
Manager. A compatible Subordinate must still accept either legal order unless
its documented interface imposes a narrower, jointly agreed profile.

The lower block diagram exposes local command inputs such as write enable,
input address, input data, and write strobes. Those are not AXI signals. They
are the course's application-side request interface, translated into AW/W/B
channel activity by the Manager.

#### Handwritten page 32 - Single beat without pipelining

![Handwritten AXI notes: Single beat without pipelining](../../../../_internal/Protocols/04%20AMBA/03%20AXI/handwritten/images/32-single-beat-without-pipelining.jpg)

**Explanation:** The three write phases are address, data, and response. This
teaching profile completes all work for one request before starting another;
waveform-oriented and FSM-oriented RTL are two organizations of that policy, not
different AXI protocols.

### Video 59 - Signals for single beat without pipeline, part 2

![Original full-frame completed single-beat read/write channel diagram and waveforms](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/059-signals-in-single-beat-without-pipeline-p2-25.png)

The read half adds AR and R below the write sequence. A read contains no
separate response channel: `RRESP` travels with `RDATA` on the R channel. The
teaching Manager therefore has two terminal events:

- a write returns to idle after `b_fire`;
- a read returns to idle after `r_fire`.

The visible reset and clock belong to the local block as well as the AXI
interface. On reset, all Manager-driven `VALID` outputs and all
Subordinate-driven `VALID` outputs must become inactive so stale transactions
cannot survive into the next run.

### Video 60 - I/O ports of the waveform-based design

![Original full-frame Manager I/O declaration beside the five-channel waveform and block diagram](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/060-i-o-ports-in-single-beat-without-pipeline-75.png)

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

### Video 61 - Write-only Manager implementation, part 1

![Original full-frame write-only Manager waveform and address-channel RTL](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/061-axil-master-with-only-write-implementation-p1-25.png)

The left waveform is the specification for the registers on the right. Reset
clears channel `VALID` outputs. A new local write causes the address value to be
captured and `AWVALID` to be asserted. Once asserted, `AWVALID` stays HIGH until
`aw_fire`; the address register is not replaced during that stall.

The no-pipeline assumption means a new `i_wr` request is not independently
buffered while a write is already active. The caller must obey the exact local
command contract documented in the instructor code: present a new command only
when the teaching Manager is ready for one.

![Original full-frame continuation of write-only Manager address and control RTL](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/061-axil-master-with-only-write-implementation-p1-75.png)

The continuation makes a common hardware point visible: nonblocking
assignments update after the sampled edge. Conditions inside the same clocked
block read the pre-edge values. When reasoning about “set valid” and “clear on
ready,” explicitly identify which branch wins if both conditions are true.

#### Handwritten page 33 - AXI4-Lite write Manager ports and reset

![Handwritten AXI notes: AXI4-Lite write Manager ports and reset](../../../../_internal/Protocols/04%20AMBA/03%20AXI/handwritten/images/33-axil-write-master-ports-and-reset.jpg)

**Explanation:** The port list exposes independent address, data, and response
channels. Reset clears the offered controls, while a new command must create
separate `AWVALID` and `WVALID` obligations that remain until their respective
handshakes.

#### Handwritten page 34 - Write address and response control

![Handwritten AXI notes: Write address and response control](../../../../_internal/Protocols/04%20AMBA/03%20AXI/handwritten/images/34-axil-write-master-address-and-response-logic.jpg)

**Explanation:** The Manager starts a write, waits for address acceptance, and
later acknowledges `BVALID`. Do not clear address and data validity from a
single combined condition unless the design has separately recorded which
handshake has completed.

### Video 62 - Write-only Manager implementation, part 2

![Original full-frame write-data and write-response logic beside the reference waveform](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/062-axil-master-with-only-write-implementation-p2-25.png)

This part adds `WDATA`, `WSTRB`, `WVALID`, and response readiness. Data and
strobes are one payload and must be captured together. During
`WVALID && !WREADY`, neither can change.

The response side completes the operation. `BREADY` indicates that the Manager
can accept `BRESP`; completion is `b_fire`, not the first cycle in which
`BVALID` becomes visible. The teaching design keeps one operation active until
that edge, which is the state that enforces “without pipeline.”

![Original full-frame completed write-only Manager RTL and waveform correspondence](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/062-axil-master-with-only-write-implementation-p2-75.png)

When reviewing this frame, follow one command through three independent flags:
address offered/accepted, data offered/accepted, response awaited/accepted.
Treating them as one universal “write done” pulse hides legal AW/W timing
differences and is the first thing a protocol checker will expose.

#### Handwritten page 35 - Write data control and Subordinate ports

![Handwritten AXI notes: Write data control and Subordinate ports](../../../../_internal/Protocols/04%20AMBA/03%20AXI/handwritten/images/35-axil-write-data-and-subordinate-ports.jpg)

**Explanation:** `WDATA` and `WSTRB` must remain stable until `WREADY`. The
Subordinate interface below must be prepared for `AW` and `W` to arrive in
either order and retain the first item until its partner arrives.

### Video 63 - Write-only Subordinate implementation, part 1

![Original full-frame write-only Subordinate address logic beside the transaction waveform](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/063-axil-slave-with-only-write-implementation-p1-25.png)

The Subordinate owns `AWREADY`. Its address-capture register changes only on
`aw_fire`. If it lowers `AWREADY`, the Manager continues holding the offered
address; the Subordinate must not consume it early.

Because the paired lesson is one-outstanding and no-pipeline, one address slot
is sufficient. That is an implementation capacity limit, not an AXI rule. The
flag representing a stored address is cleared only when the write has advanced
far enough that the slot can safely be reused.

#### Handwritten page 36 - Subordinate write-address control

![Handwritten AXI notes: Subordinate write-address control](../../../../_internal/Protocols/04%20AMBA/03%20AXI/handwritten/images/36-axil-subordinate-write-address-control.jpg)

**Explanation:** The page begins the `AWREADY` logic and then contrasts write
and read channels. A correct Subordinate must not discard an accepted address
merely because the matching data has not arrived in the same cycle.

### Video 64 - Write-only Subordinate implementation, part 2

![Original full-frame Subordinate write-data capture and response logic](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/064-axil-slave-with-only-write-implementation-p2-25.png)

The data branch qualifies storage with `w_fire`. `WSTRB` determines which byte
lanes are updated; a low strobe bit preserves the previous byte. The response
branch asserts `BVALID` only after the design regards both address and data as
accepted.

![Original full-frame completed Subordinate response logic and signal directions](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/064-axil-slave-with-only-write-implementation-p2-75.png)

Once `BVALID` is HIGH, `BRESP` is held until `b_fire`. The course normally
returns `OKAY` for the demonstrated address range. If address decode or the
register operation can fail, the same held response mechanism must carry
`SLVERR` or `DECERR` as appropriate.

### Video 65 - Verifying the write-only Manager and Subordinate

![Original full-frame testbench stimulus for the write-only Manager/Subordinate pair](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/065-verifying-operation-of-master-and-slave-with-only-write-25.png)

The testbench frame shows reset, command generation, and repeated data/address
values. A useful trace starts at the local request and records five edges:
request capture, `aw_fire`, `w_fire`, `b_fire`, and local completion. AW and W
may share an edge in this test, but the scoreboard should track them
independently.

![Original full-frame Vivado waveform for completed AXI4-Lite writes](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/065-verifying-operation-of-master-and-slave-with-only-write-75.png)

In the waveform, check that every address/data item remains unchanged across a
stall, `BVALID` follows accepted write inputs, and the next command begins only
after the response handshake. Seeing expected data is necessary but not
sufficient; these channel-timing checks prove the interface behavior.

### Lessons 66-67 - Design and testbench code resources

The instructor supplies the write-only design and testbench as separate code
resources. The repository preserves them under the Section 5 area in
[Code](../Code/README.md), with comments identifying local-command assumptions,
omitted optional AXI4-Lite signals, one-outstanding capacity, and the exact
event that completes a write. The code remains the instructor's teaching
architecture rather than a redesigned implementation.

### Video 68 - Adding the AXI Protocol Checker, part 1

![Original full-frame AMD PG101 protocol-independent port descriptions used by the lesson](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/068-validating-transactions-with-axi-protocol-checker-p1-25.png)

The documentation frame separates checker infrastructure from monitored AXI
signals. The checker receives a clock and resets, observes the interface, and
reports violations. It does not become a participant in the handshakes.

![Original full-frame Vivado checker instantiation and teaching design connection](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/068-validating-transactions-with-axi-protocol-checker-p1-75.png)

AMD PG101 describes the core as an AXI4/AXI3/AXI4-Lite traffic monitor that can
report violations in simulation, a status vector, and debug nets. The monitor
must see the same clock/reset domain as the observed interface. Tying off an
unused checker port must match the configured protocol; it must not fabricate
a handshake that the DUT never drove.

### Video 69 - Adding the AXI Protocol Checker, part 2

![Original full-frame Vivado block design containing Manager, Subordinate, and AXI checker](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/069-validating-transactions-with-axi-protocol-checker-p2-25.png)

The block design places the checker alongside the link. Both endpoints remain
connected directly; the checker taps AW, W, B, AR, and R. This is observation,
not arbitration or buffering.

![Original full-frame expanded checker-to-interface wiring in Vivado](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/069-validating-transactions-with-axi-protocol-checker-p2-75.png)

For the write-only demonstration, unused read-channel monitor inputs must be
configured or tied consistently. The important monitored properties include
payload stability while stalled, `VALID` persistence, response ordering, and
reset behavior. A green connection diagram is not proof; the checker result
and waveform are the proof surfaces.

### Video 70 - Adding the AXI Protocol Checker, part 3

![Original full-frame checker-related testbench code and configured signals](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/070-validating-transactions-with-axi-protocol-checker-p3-25.png)

The source frame shows the final integration. Keep checker status visible in
simulation so a passing data comparison cannot hide a protocol violation. A
test should deliberately apply delayed `READY` values; otherwise the most
important hold-until-handshake rules are never exercised.

![Original full-frame Vivado waveform with the AXI checker active](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/070-validating-transactions-with-axi-protocol-checker-p3-75.png)

The waveform should be read in two layers: first confirm expected transaction
data, then confirm that no checker assertion/status bit reports a violation.
The official [AMD AXI Protocol Checker overview](https://docs.amd.com/r/en-US/pg101-axi-protocol-checker/Overview)
explains those reporting paths.

### Lessons 71-72 - Checker design and testbench resources

These resources preserve the checker-connected design and its testbench. Their
comments identify which read-side inputs are unused in the write-only lesson,
how they are tied for the selected checker configuration, and which checker
outputs are observation-only.

### Video 73 - Read-only Manager implementation, part 1

![Original full-frame read-only Manager architecture, AR/R waveform, and port directions](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/073-axil-master-with-only-read-implementation-p1-25.png)

The frame mirrors the earlier write design with fewer phases: capture a local
read address, offer it on AR, then wait for one R result. `ARADDR` is held with
`ARVALID` until `ar_fire`. The Manager must be prepared to accept both `RDATA`
and `RRESP` as one payload.

![Original full-frame read-only Manager block relationship and timing](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/073-axil-master-with-only-read-implementation-p1-75.png)

With no pipeline, the local side cannot issue a second address while the first
read result is outstanding. The terminal event is `r_fire`; merely seeing
`RVALID` is not completion if `RREADY` is LOW.

#### Handwritten page 37 - AXI4-Lite read Manager interface

![Handwritten AXI notes: AXI4-Lite read Manager interface](../../../../_internal/Protocols/04%20AMBA/03%20AXI/handwritten/images/37-axil-read-master-interface.jpg)

**Explanation:** The read path contains an `AR` request and an `R` response. The
Manager owns `ARVALID`, `ARADDR`, and `RREADY`; the Subordinate owns `ARREADY`,
`RVALID`, `RDATA`, and `RRESP`.

#### Handwritten page 38 - Read-address and read-data control

![Handwritten AXI notes: Read-address and read-data control](../../../../_internal/Protocols/04%20AMBA/03%20AXI/handwritten/images/38-axil-read-master-address-and-data-control.jpg)

**Explanation:** The Manager holds `ARVALID` until the address handshake and
asserts `RREADY` when it can accept the response. `RVALID` must be generated by
the Subordinate independently of whether the Manager has already raised
`RREADY`.

### Video 74 - Read-only Manager implementation, part 2

![Original full-frame read-address register and ARVALID logic](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/074-axil-master-with-only-read-implementation-p2-25.png)

The editor shows the address register and valid-control branches. Reset clears
`ARVALID`; a new local read captures the address and asserts it; `ar_fire`
releases the offered request. The input address must not feed the bus
combinationally after `ARVALID` is asserted, because the caller could change it
during back-pressure.

![Original full-frame continuation into read-result capture logic](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/074-axil-master-with-only-read-implementation-p2-75.png)

The read-result branch samples `RDATA` and `RRESP` on `r_fire`. If the local
interface exposes only data, an error response can be silently lost; the file
comments must state whether `RRESP` is consumed, ignored, or assumed `OKAY` in
the paired demonstration.

### Video 75 - Read-only Manager implementation, part 3

![Original full-frame completed Manager read-control RTL and waveform](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/075-axil-master-with-only-read-implementation-p3-25.png)

The completed logic links local busy/completion state to the R handshake. A
robust trace proves that `RREADY` is asserted according to available local
storage, not as a cosmetic pulse after `RVALID`.

![Original full-frame final read-only Manager branches and reset behavior](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/075-axil-master-with-only-read-implementation-p3-75.png)

The teaching implementation has one result slot. If the downstream local logic
cannot always consume the result, `RREADY` must reflect that capacity and the
captured result needs its own valid flag. The exact course code documents the
simpler assumed local behavior rather than silently claiming an unbounded
buffer.

#### Handwritten page 39 - Read-response readiness

![Handwritten AXI notes: Read-response readiness](../../../../_internal/Protocols/04%20AMBA/03%20AXI/handwritten/images/39-axil-read-response-ready-control.jpg)

**Explanation:** This page finishes the registered `RREADY` behavior and
response storage. The architectural event is the `RVALID && RREADY` edge; a
pulse policy is acceptable only if it cannot miss a response and meets the
intended throughput.

### Video 76 - Read-only Subordinate implementation, part 1

![Original full-frame read-only Subordinate port list, decode path, and read waveform](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/076-axil-slave-with-only-read-implementation-p1-25.png)

The Subordinate accepts `ARADDR` on `ar_fire`, decodes the addressed register,
and prepares `RDATA/RRESP`. `ARREADY` describes address-slot capacity; it does
not mean that a read result has already transferred.

![Original full-frame read-data generation and channel directions](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/076-axil-slave-with-only-read-implementation-p1-75.png)

After the result is prepared, `RVALID` remains HIGH until `r_fire`. If the
address is unsupported, the response should describe the decode or slave
error. The classroom design's chosen address range and default behavior are
explicit assumptions in its source comments.

### Video 77 - Read-only Subordinate implementation, part 2

![Original full-frame read-only Subordinate AR and R channel RTL](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/077-axil-slave-with-only-read-implementation-p2-25.png)

The clocked branches expose the lifetime of a returned result. Data is selected
from the accepted address, `RVALID` marks the result, and `r_fire` frees the
one-entry result slot.

![Original full-frame completed read response logic and reset branches](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/077-axil-slave-with-only-read-implementation-p2-75.png)

Check branch priority when `RREADY` is already HIGH in the cycle `RVALID` is
raised. The intended course timing must not clear a newly produced result using
the pre-edge state incorrectly. Following nonblocking-assignment semantics is
essential here.

### Video 78 - Connecting the read-only Manager and Subordinate

![Original full-frame top-level Verilog wiring for the read-only pair](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/078-connecting-master-and-slave-25.png)

The top level wires every AR and R signal once, with opposite endpoint
directions. `ARREADY` and `RVALID/RDATA/RRESP` travel from Subordinate to
Manager; `ARVALID/ARADDR` and `RREADY` travel from Manager to Subordinate.

![Original full-frame elaborated Vivado schematic of the read-only connection](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/078-connecting-master-and-slave-75.png)

The elaborated view checks width and direction, but not protocol behavior.
Common clock/reset connection and a clean elaboration are prerequisites for
the waveform test, not its conclusion.

### Video 79 - Verifying read operation, part 1

![Original full-frame read-only testbench stimulus and expected-data setup](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/079-verifying-operation-p1-25.png)

The testbench issues addresses and observes returned values. The self-checking
model should associate expected data with each accepted AR request, then compare
only on `r_fire`. Comparing whenever `RVALID` is visible can count the same
stalled result more than once.

![Original full-frame continuation of read verification and signal setup](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/079-verifying-operation-p1-75.png)

Reset and first-request timing deserve special attention. A request applied on
the same edge as reset release must obey the synchronous reset convention used
by the DUT; otherwise the testbench may create a race that the protocol does
not define.

### Video 80 - Verifying read operation, part 2

![Original full-frame Vivado waveform of repeated AXI4-Lite reads](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/080-verifying-operation-p2-25.png)

The waveform exposes the full sequence: local command, AR handshake, R valid,
R handshake, and return to idle. Confirm that every accepted address has one
and only one accepted result.

![Original full-frame later portion of the read waveform with response timing](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/080-verifying-operation-p2-75.png)

Introduce an `RREADY` stall mentally while reading the second frame: the
Subordinate's data and response must freeze, and the Manager must not declare
completion until the eventual handshake.

### Lesson 81 - Read-path code resource

The resource contains the paired read-only Manager, Subordinate, connection,
and testbench material. Inline comments identify the one-outstanding rule,
local command assumptions, address-decode behavior, and the disposition of
`RRESP`.

### Videos 82-84 - Protocol checker on the read path

![Original full-frame checker-connected read-path source for lesson 82](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/082-adding-axi-protocol-checker-p1-25.png)

Lesson 82 adds the monitor ports to the read-only pair. AW/W/B monitor inputs
are unused by this teaching path and must be configured consistently; AR/R are
live. The checker should observe the exact `RDATA/RRESP` payload that the
Manager sees.

![Original full-frame checker configuration and source integration for lesson 83](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/083-adding-axi-protocol-checker-p2-75.png)

Lesson 83 completes the source and simulation setup. The blue-highlighted tool
area is configuration, not DUT behavior. Preserve the chosen protocol mode and
data/address widths so the checker interprets the monitored wires correctly.

![Original full-frame final Vivado checker waveform for lesson 84](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/084-adding-axi-protocol-checker-p3-75.png)

Lesson 84 is the proof surface. A passing run requires both correct returned
data and no protocol violation. The most valuable directed tests delay
`ARREADY` and `RREADY`, because those stalls expose request-payload and
result-payload stability errors.

## Section 5 assumptions and boundaries

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

## Active-recall checkpoint

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

[Continue to Section 6](Section%2006%20-%20AXI4-Lite%20Single%20Beat%20without%20Pipeline%20-%20FSM%20Approach.md).
