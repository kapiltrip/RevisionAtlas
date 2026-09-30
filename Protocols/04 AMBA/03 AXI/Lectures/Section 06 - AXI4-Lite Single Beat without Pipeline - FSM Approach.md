# Section 6 - AXI4-Lite Single Beat without Pipeline: FSM Approach

[Previous: Section 5](Section%2005%20-%20AXI4-Lite%20Single%20Beat%20without%20Pipeline%20-%20Waveform%20Approach.md) | [Section index](README.md) | [AXI chapter](../README.md) | [Next: Section 7](Section%2007%20-%20AXI4-Lite%20GPIO%20Use%20Case.md)

**Course status:** 9/9 lessons complete, covering lessons 85-93.

Section 5 implemented separate write-only and read-only paths by following a
drawn timing sequence. Section 6 combines both paths in one Manager and makes
the control state explicit. The same AXI4-Lite handshakes still govern every
transition; the FSM is an organization method, not a substitute for channel
rules.

## Lesson index

| Lesson | Topic | Notebook pages |
|---:|---|---|
| <a id="index-lesson-085"></a>[85](#lesson-085) | Section 6 agenda | — |
| <a id="index-lesson-086"></a>[86](#lesson-086) | Building the Manager FSM | — |
| <a id="index-lesson-087"></a>[87](#lesson-087) | Combined Manager I/O ports | <a id="index-page-40"></a>[40](#page-40) |
| <a id="index-lesson-088"></a>[88](#lesson-088) | Manager implementation part 1: write | <a id="index-page-41"></a>[41](#page-41) |
| <a id="index-lesson-089"></a>[89](#lesson-089) | Manager implementation part 2: write | — |
| <a id="index-lesson-090"></a>[90](#lesson-090) | Manager implementation part 3: read | <a id="index-page-42"></a>[42](#page-42), <a id="index-page-43"></a>[43](#page-43) |
| <a id="index-lesson-091"></a>[91](#lesson-091) | Verifying the combined Manager | — |
| <a id="index-lesson-092"></a>[92](#lesson-092), <a id="index-lesson-093"></a>[93](#lesson-093) | Design and testbench code resources | — |

## Formal standard explanation

The AXI specification does not prescribe an FSM or require AW to precede W.
Those are internal design decisions. Whatever state encoding is chosen, a
transition that launches `AWVALID`, `WVALID`, or `ARVALID` must retain that
signal and its payload until the corresponding handshake. Likewise, response
states must retain `BVALID` or `RVALID` until accepted. State transitions must
therefore be driven by channel `fire` events, not by elapsed cycles or by
`READY` alone.

A serialized Manager that issues AW and then W is legal, but a reusable
Subordinate cannot depend on that order because another legal Manager may send
W first or present both together. The no-pipeline FSM's single outstanding
operation is also a local resource choice. It simplifies storage and ordering,
but it must not be mistaken for a protocol limit.

**Standard basis:** [Arm IHI 0022H, §§A3.2-A3.3 and B1.1](https://developer.arm.com/-/media/Arm%20Developer%20Community/PDF/IHI0022H_amba_axi_protocol_spec.pdf).

## Lessons 85-93

<a id="lesson-085"></a>

### Video 85 - Section 6 agenda

[Back to index — lesson 85](#index-lesson-085)

![Original full-frame Section 6 agenda](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/085-agenda-50.png)

The agenda has two outcomes: build the combined no-pipeline Manager and connect
it to a Subordinate while retaining protocol checking. “Combined” means the
block can initiate either a read or a write. It does not mean AW/W/B and AR/R
become one channel.

[Back to index — lesson 85](#index-lesson-085)

<a id="lesson-086"></a>

### Video 86 - Building the Manager FSM

[Back to index — lesson 86](#index-lesson-086)

![Original full-frame combined Manager FSM beside write and read waveforms](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/086-buidling-fsm-for-master-25.png)

The flowchart begins in idle, tests the local command type, and enters either a
write path or a read path. The write path must remember two independent request
completions before waiting for B; the read path accepts AR before waiting for
R. Terminal response handshakes return the machine to idle.

![Original full-frame later FSM annotation showing branch and completion conditions](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/086-buidling-fsm-for-master-75.png)

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

[Back to index — lesson 86](#index-lesson-086)

<a id="lesson-087"></a>

### Video 87 - Combined Manager I/O ports

[Back to index — lesson 87](#index-lesson-087)

![Original full-frame FSM and first half of the combined Manager port list](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/087-master-i-o-ports-25.png)

The first port frame combines the local command interface with write-channel
signals. The local write/read selector and input address are sampled only when
idle accepts a new command. Once an AXI `VALID` is raised, its payload comes
from held registers rather than a changing caller input.

![Original full-frame complete Manager I/O list including the read channels](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/087-master-i-o-ports-75.png)

The second frame completes AR/R. Verify signal ownership at the declaration:
the Manager outputs `AWVALID`, `WVALID`, `BREADY`, `ARVALID`, and `RREADY`; it
inputs the corresponding ready/valid response signals. `BRESP` and `RRESP` are
status payloads, not ready signals.

The course interface omits optional protection fields and supports one command
at a time. Those are declared teaching constraints in the matching
[Code](../Code/README.md), not alternate AXI meanings.

<a id="page-40"></a>

#### Handwritten page 40 - Combined AXI4-Lite Manager ports

[Back to index — notebook page 40](#index-page-40)

![Handwritten AXI notes: Combined AXI4-Lite Manager ports](../../../../_internal/Protocols/04%20AMBA/03%20AXI/handwritten/images/40-axil-combined-manager-ports-and-channels.jpg)

**Explanation:** The combined block exposes three write channels and two read
channels. With one outstanding operation, the control FSM must arbitrate local
read/write requests and remember which response completes the selected command.

[Back to index — lesson 87](#index-lesson-087)

[Back to index — notebook page 40](#index-page-40)

<a id="lesson-088"></a>

### Video 88 - Manager implementation part 1: write

[Back to index — lesson 88](#index-lesson-088)

![Original full-frame write FSM branch beside the first write-control RTL](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/088-master-implementation-p1-write-25.png)

The state register is reset to idle. The next-state block gives a default before
the `case`, avoiding unintended latches. In the write path, address and data
valid flags correspond to outstanding channel items, not arbitrary one-cycle
pulses.

![Original full-frame later write-state RTL with handshake conditions](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/088-master-implementation-p1-write-75.png)

The highlighted branches show why pre-edge versus post-edge state matters. A
handshake condition consumes the currently offered item. If a flag is both set
for a new item and cleared for an old handshake in one clocked block, branch
priority must preserve the instructor's intended single-item lifetime.

<a id="page-41"></a>

#### Handwritten page 41 - Combined Manager write FSM

[Back to index — notebook page 41](#index-page-41)

![Handwritten AXI notes: Combined Manager write FSM](../../../../_internal/Protocols/04%20AMBA/03%20AXI/handwritten/images/41-axil-manager-write-fsm.jpg)

**Explanation:** The state sketch sequences address/data acceptance and the
write response. Command inputs should be captured before they can change, and
any timeout behavior is a teaching-design policy rather than part of the AXI
protocol.

[Back to index — lesson 88](#index-lesson-088)

[Back to index — notebook page 41](#index-page-41)

<a id="lesson-089"></a>

### Video 89 - Manager implementation part 2: write

[Back to index — lesson 89](#index-lesson-089)

![Original full-frame completed write-side state flow and address/data logic](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/089-master-implementation-p2-write-25.png)

The flowchart now reaches response wait. Address and data acceptance may occur
on different edges; local completion must wait for `b_fire`. `BRESP` is sampled
with that event. If the teaching local interface does not expose an error, the
source comments identify the response assumption rather than pretending errors
cannot occur.

![Original full-frame write response and ready-control RTL](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/089-master-implementation-p2-write-75.png)

`BREADY` expresses capacity to retire the response. The no-pipeline FSM keeps
new command acceptance disabled until the B handshake returns it to idle. This
single outstanding restriction is what makes one response unambiguous without
an internal queue.

[Back to index — lesson 89](#index-lesson-089)

<a id="lesson-090"></a>

### Video 90 - Manager implementation part 3: read

[Back to index — lesson 90](#index-lesson-090)

![Original full-frame read branch of the combined FSM and AR/R RTL](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/090-master-implementation-p3-read-25.png)

The read branch captures the local address, asserts `ARVALID`, and waits for
`ar_fire`. It then accepts one `RDATA/RRESP` payload on `r_fire`. The result is
not valid merely because wires contain a value; it is valid because `RVALID`
marks it and `RREADY` accepts it.

![Original full-frame completed read-state logic and return-to-idle branch](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/090-master-implementation-p3-read-75.png)

During `RVALID && !RREADY`, the Subordinate holds data/response and the FSM must
remain in its receive state. Returning to idle from a level of `RVALID` without
requiring `RREADY` would lose a stalled response.

<a id="page-42"></a>

#### Handwritten page 42 - Write-response completion and read start

[Back to index — notebook page 42](#index-page-42)

![Handwritten AXI notes: Write-response completion and read start](../../../../_internal/Protocols/04%20AMBA/03%20AXI/handwritten/images/42-axil-manager-write-response-and-read-start.jpg)

**Explanation:** The upper notes finish the `B` channel, while the lower notes
open the read branch. Each state advances on its exact channel handshake; a mere
assertion of `VALID` or `READY` is not completion.

[Back to index — notebook page 42](#index-page-42)

<a id="page-43"></a>

#### Handwritten page 43 - Read-address acceptance and data counting

[Back to index — notebook page 43](#index-page-43)

![Handwritten AXI notes: Read-address acceptance and data counting](../../../../_internal/Protocols/04%20AMBA/03%20AXI/handwritten/images/43-axil-manager-read-address-and-data-count.jpg)

**Explanation:** The Manager sends `AR`, waits for the response, and records
accepted data. In full AXI, completion must agree with an accepted `RLAST`; in
this Lite teaching path there is only one read-data beat.

[Back to index — lesson 90](#index-lesson-090)

[Back to index — notebook page 43](#index-page-43)

<a id="lesson-091"></a>

### Video 91 - Verifying the combined Manager

[Back to index — lesson 91](#index-lesson-091)

![Original full-frame combined-Manager testbench stimulus](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/091-verifying-operation-of-master-25.png)

The testbench alternates command types. A clean scoreboard maintains separate
expectations for writes and reads: writes retire on B, while reads compare data
and response on R. The local command must be issued only when the one-command
FSM is idle.

![Original full-frame Vivado waveform for combined read and write operation](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/091-verifying-operation-of-master-75.png)

Use the visible state signal as an explanation aid, then verify behavior from
the bus itself. Every `VALID` must persist through stalls, each response must
follow its request, and the FSM must not accept overlapping local operations.
Randomized ready delays are the decisive test for those properties.

[Back to index — lesson 91](#index-lesson-091)

<a id="lesson-092"></a>

<a id="lesson-093"></a>

### Lessons 92-93 - Design and testbench code resources

[Back to index — lesson 92](#index-lesson-092) | [Back to index — lesson 93](#index-lesson-093)

Lesson 92 supplies the combined Manager design and lesson 93 supplies its
testbench. The repository keeps the instructor's module names, state names,
and control structure under [Code](../Code/README.md). Inline comments document:

- the one-command/no-pipeline local contract;
- which optional AXI4-Lite ports are absent;
- how `BRESP` and `RRESP` are handled;
- which event completes each command;
- why caller address/data inputs must not change after command acceptance.

[Back to index — lesson 92](#index-lesson-092) | [Back to index — lesson 93](#index-lesson-093)

## FSM audit checklist

- Every combinational output and `next_state` has a default assignment.
- Reset clears all Manager-driven AXI `VALID` outputs and returns to idle.
- AW, W, B, AR, and R transitions use their own handshake events.
- A stalled payload is held even if an internal counter or unrelated channel
  changes.
- The FSM cannot accept a second local command while a response is outstanding.
- Error responses are either surfaced or explicitly documented as ignored by
  the teaching local interface.

## Active-recall checkpoint

1. Which two write-request events are independent even in one FSM?
2. Why does the write branch return to idle on `b_fire`, not `BVALID` alone?
3. What is held while `ARVALID=1` and `ARREADY=0`?
4. What is held while `RVALID=1` and `RREADY=0`?
5. What internal capacity limit enforces the no-pipeline policy?
6. Why must state-machine branch priority be checked with nonblocking
   assignment semantics?

[Continue to Section 7](Section%2007%20-%20AXI4-Lite%20GPIO%20Use%20Case.md).
