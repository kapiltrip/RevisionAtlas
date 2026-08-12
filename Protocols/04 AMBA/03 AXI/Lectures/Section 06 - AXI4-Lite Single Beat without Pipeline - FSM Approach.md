# Section 6 - AXI4-Lite Single Beat without Pipeline: FSM Approach

[Previous: Section 5](Section%2005%20-%20AXI4-Lite%20Single%20Beat%20without%20Pipeline%20-%20Waveform%20Approach.md) | [Course hub](../Course%20Atlas.md) | [AXI chapter](../README.md) | [Next: Section 7](Section%2007%20-%20AXI4-Lite%20GPIO%20Use%20Case.md)

**Course status:** 9/9 lessons complete, covering lessons 85-93.

Section 5 implemented separate write-only and read-only paths by following a
drawn timing sequence. Section 6 combines both paths in one Manager and makes
the control state explicit. The same AXI4-Lite handshakes still govern every
transition; the FSM is an organization method, not a substitute for channel
rules.

## Lessons 85-93

### Video 85 - Section 6 agenda

![Original full-frame Section 6 agenda](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/085-agenda-50.png)

The agenda has two outcomes: build the combined no-pipeline Manager and connect
it to a Subordinate while retaining protocol checking. “Combined” means the
block can initiate either a read or a write. It does not mean AW/W/B and AR/R
become one channel.

### Video 86 - Building the Manager FSM

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

### Video 87 - Combined Manager I/O ports

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

#### Handwritten page 40 - Combined AXI4-Lite Manager ports

![Handwritten AXI notes: Combined AXI4-Lite Manager ports](../../../../_internal/Protocols/04%20AMBA/03%20AXI/handwritten/images/40-axil-combined-manager-ports-and-channels.jpg)

**Explanation:** The combined block exposes three write channels and two read
channels. With one outstanding operation, the control FSM must arbitrate local
read/write requests and remember which response completes the selected command.

### Video 88 - Manager implementation part 1: write

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

#### Handwritten page 41 - Combined Manager write FSM

![Handwritten AXI notes: Combined Manager write FSM](../../../../_internal/Protocols/04%20AMBA/03%20AXI/handwritten/images/41-axil-manager-write-fsm.jpg)

**Explanation:** The state sketch sequences address/data acceptance and the
write response. Command inputs should be captured before they can change, and
any timeout behavior is a teaching-design policy rather than part of the AXI
protocol.

### Video 89 - Manager implementation part 2: write

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

### Video 90 - Manager implementation part 3: read

![Original full-frame read branch of the combined FSM and AR/R RTL](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/090-master-implementation-p3-read-25.png)

The read branch captures the local address, asserts `ARVALID`, and waits for
`ar_fire`. It then accepts one `RDATA/RRESP` payload on `r_fire`. The result is
not valid merely because wires contain a value; it is valid because `RVALID`
marks it and `RREADY` accepts it.

![Original full-frame completed read-state logic and return-to-idle branch](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/090-master-implementation-p3-read-75.png)

During `RVALID && !RREADY`, the Subordinate holds data/response and the FSM must
remain in its receive state. Returning to idle from a level of `RVALID` without
requiring `RREADY` would lose a stalled response.

#### Handwritten page 42 - Write-response completion and read start

![Handwritten AXI notes: Write-response completion and read start](../../../../_internal/Protocols/04%20AMBA/03%20AXI/handwritten/images/42-axil-manager-write-response-and-read-start.jpg)

**Explanation:** The upper notes finish the `B` channel, while the lower notes
open the read branch. Each state advances on its exact channel handshake; a mere
assertion of `VALID` or `READY` is not completion.

#### Handwritten page 43 - Read-address acceptance and data counting

![Handwritten AXI notes: Read-address acceptance and data counting](../../../../_internal/Protocols/04%20AMBA/03%20AXI/handwritten/images/43-axil-manager-read-address-and-data-count.jpg)

**Explanation:** The Manager sends `AR`, waits for the response, and records
accepted data. In full AXI, completion must agree with an accepted `RLAST`; in
this Lite teaching path there is only one read-data beat.

### Video 91 - Verifying the combined Manager

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

### Lessons 92-93 - Design and testbench code resources

Lesson 92 supplies the combined Manager design and lesson 93 supplies its
testbench. The repository keeps the instructor's module names, state names,
and control structure under [Code](../Code/README.md). Inline comments document:

- the one-command/no-pipeline local contract;
- which optional AXI4-Lite ports are absent;
- how `BRESP` and `RRESP` are handled;
- which event completes each command;
- why caller address/data inputs must not change after command acceptance.

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
