# Section 3 - Using AXI-Stream to Build IP

[Previous: Section 2](Section%2002%20-%20AXI-Stream%20Interface%20Fundamentals.md) | [Section index](README.md) | [Next: Section 4](Section%2004%20-%20Getting%20Started%20with%20AXI4-Lite.md)

**Course status:** 16/16 lessons complete (lessons 29-44).

The section moves from a plain fair request/grant decision to a packet-aware
AXI-Stream arbiter and then to a FIFO that decouples producer and consumer
timing. Lessons 33, 38, 42, and 44 are code resources kept beside the videos
that establish their behavior.

## Lessons 29-44

### Video 29 - Section 3 agenda

![Fullscreen Section 3 agenda: round-robin arbiter, AXIS arbiter, and AXIS FIFO](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2001/29-section3-agenda-18.png)

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

### Video 30 - Round-robin arbiter part 1

![Fullscreen two-request timing example and round-robin decision flow](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2001/30-round-robin-p1-concept-fullscreen.png)

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

![Fullscreen next-state RTL beside the round-robin flowchart](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2001/31-round-robin-p2-fullscreen.png)

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
[handwritten fairness page](#earlier-handwritten-question---round-robin-fairness)
below.

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

#### Handwritten page 17 - Round-robin priority rotation

![Handwritten AXI notes: Round-robin priority rotation](../../../../_internal/Protocols/04%20AMBA/03%20AXI/handwritten/images/17-round-robin-priority-rotation.jpg)

**Explanation:** The highlighted branch order is functional hardware priority.
After requester 1 is served in `s1`, checking `req2` first prevents a persistent
requester 1 from starving requester 2; `s2` applies the symmetric rule.

#### Earlier handwritten question - Round-robin fairness

![Handwritten round-robin fairness question about the priority order in state s1](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2001/round-robin-fairness-question-s1-priority.jpg)

**Explanation:** This earlier question asks why `s1` tests `req2` before `req1`.
State `s1` already grants requester 1, so requester 2 must receive the next
tie-break. Reversing the branch order would let a persistent `req1` keep the FSM
in `s1` and starve requester 2.

### Video 32 - Round-robin arbiter part 3

![Fullscreen round-robin testbench stimulus sequence](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2001/32-round-robin-p3-testbench-fullscreen.png)

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
details are the subject of lessons 34-44 below.

### Video 34 - Implementing AXIS arbiter part 1

![Full-screen AXI-Stream arbiter architecture, input packets, output packet, and interface ports](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2002/34-axis-arbiter-p1-overview-fullscreen.jpg)

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

#### Handwritten page 18 - AXI-Stream arbiter interfaces and states

![Handwritten AXI notes: AXI-Stream arbiter interfaces and states](../../../../_internal/Protocols/04%20AMBA/03%20AXI/handwritten/images/18-axis-arbiter-interface-and-states.jpg)

**Explanation:** Two source interfaces feed one destination interface, with one
state per selected source. State is packet ownership: the arbiter must route
payload, `TVALID`, `TLAST`, and the corresponding return `TREADY` consistently.

### Video 35 - Implementing AXIS arbiter part 2

![Full-screen request timing and three-state packet-arbiter flowchart](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2002/35-axis-arbiter-p2-25.png)

The flowchart reuses `idle`, `s1`, and `s2`, but the meaning is now stronger
than a one-cycle request grant. `s1` means source 1 owns the output path;
`s2` means source 2 owns it. When both sources are active, the next owner is the
one that did not just finish. The source must remain owner across every stall
and every interior packet beat, otherwise the downstream Receiver could see
one packet assembled from two unrelated inputs.

![Full-screen arbiter RTL showing idle selection and the start of state s1](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2002/35-axis-arbiter-p2-65.png)

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

![Full-screen arbiter RTL showing the complete s1 and s2 packet-selection branches](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2002/35-axis-arbiter-p2-88.png)

The last frame shows the mirrored `s1` and `s2` branches. Symmetry matters:
each state must hold itself while its selected source still owns an
unaccepted/interior beat, then give the other waiting source first choice only
after the accepted final beat. Fairness is therefore measured in **packets**,
not cycles. One source can legitimately occupy many cycles if its packet is
long or the downstream Receiver is applying back-pressure.

#### Handwritten page 19 - Arbiter idle and source-1 logic

![Handwritten AXI notes: Arbiter idle and source-1 logic](../../../../_internal/Protocols/04%20AMBA/03%20AXI/handwritten/images/19-axis-arbiter-idle-and-s1-logic.jpg)

**Explanation:** The temporary payload registers preserve the selected beat. The
packet-safe transition condition is an accepted final beat, `TVALID && TREADY &&
TLAST`; seeing `TLAST` without a handshake is not enough to switch sources.

#### Handwritten page 20 - Arbiter source-1 and source-2 logic

![Handwritten AXI notes: Arbiter source-1 and source-2 logic](../../../../_internal/Protocols/04%20AMBA/03%20AXI/handwritten/images/20-axis-arbiter-s1-and-s2-logic.jpg)

**Explanation:** The mirrored branches implement rotating preference between
sources. Back-pressure must freeze both the selection and its entire payload
bundle, even if the competing source becomes valid while the current packet is
stalled.

### Video 36 - Implementing AXIS arbiter part 3

![Full-screen final arbiter state logic and output assignments](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2002/36-axis-arbiter-p3-25.png)

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

![Full-screen arbiter output decoder for data, last, and valid](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2002/36-axis-arbiter-p3-65.png)

#### Important protocol correction

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

### Video 37 - Verifying the AXI-Stream arbiter

![Full-screen arbiter testbench with reset, randomized data, source valid, source last, and downstream ready](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2002/37-verify-axis-arbiter-25.png)

The testbench enables source 1, randomizes both data inputs, marks packet ends,
and keeps `m_axis_tready=1` for the illustrated run. It exercises source
selection and packet order, but constant ready removes the hardest protocol
case. A stronger test must independently randomize downstream back-pressure
and must freeze each source's complete beat whenever its own `TREADY` is LOW.

![Full-screen Vivado waveform showing source packets, output data, TLAST, state, and registered payload](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2002/37-verify-axis-arbiter-65.png)

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

### Lesson 38 - AXI-Stream arbiter code resource

The code resource belongs with videos 34-37. Use the course listing as the
implementation reference, but audit it with the rules above before reuse. In
particular, replace any `TVALID` expression gated by `TREADY`, gate packet
completion with the full three-signal fire condition, and route every enabled
sideband through the same selection as `TDATA`.

### Video 39 - Implementing AXI-Stream FIFO part 1

![Full-screen FIFO module ports, payload memories, pointers, flags, and occupancy counter](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2002/39-axis-fifo-p1-20.png)

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

![Full-screen FIFO timing diagram showing a packet buffered before the consumer becomes ready](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2002/39-axis-fifo-p1-55.png)

The producer sends $D_0$-$D_3$ before the consumer is ready. The FIFO accepts
those beats while space exists, then presents them later in the same order.
This is temporal decoupling: the FIFO absorbs a finite timing mismatch; it does
not create infinite bandwidth. If the consumer remains slower long enough,
occupancy reaches full and `s_axis_tready` must go LOW.

#### Handwritten page 21 - AXI-Stream FIFO interface and data flow

![Handwritten AXI notes: AXI-Stream FIFO interface and data flow](../../../../_internal/Protocols/04%20AMBA/03%20AXI/handwritten/images/21-axis-fifo-interface-and-flow.jpg)

**Explanation:** The FIFO decouples producer timing from consumer timing. Each
stored entry is a complete beat bundle - data, keep, and last - while input
readiness follows available capacity and output validity follows occupancy.

### Video 40 - Implementing AXI-Stream FIFO part 2

![Full-screen FIFO arrays, pointers, count, full detection, and empty detection](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2002/40-axis-fifo-p2-20.png)

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

![Full-screen FIFO reset block initializing pointers, count, valid, keep, last, and data](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2002/40-axis-fifo-p2-55.png)

Reset establishes empty state: both pointers and count become zero, and the
registered downstream valid is cleared. Clearing every memory element is not
required for protocol correctness because an empty FIFO must not assert
`m_axis_tvalid`; it can also prevent block-RAM inference on some FPGA tools.
Resetting metadata/valid and ignoring unoccupied RAM contents is often the
better implementation.

![Full-screen FIFO write and read branches updating memory, pointers, count, and output valid](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2002/40-axis-fifo-p2-85.png)

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

#### Handwritten page 22 - FIFO storage and consumer handshake

![Handwritten AXI notes: FIFO storage and consumer handshake](../../../../_internal/Protocols/04%20AMBA/03%20AXI/handwritten/images/22-axis-fifo-storage-and-consumer-handshake.jpg)

**Explanation:** The vector-versus-array note leads into the three parallel
memories. Their indices must always move together, and simultaneous push/pop
must preserve occupancy instead of allowing two independent assignments to
overwrite the count update.

#### Handwritten page 23 - FIFO pointers, count, and reset

![Handwritten AXI notes: FIFO pointers, count, and reset](../../../../_internal/Protocols/04%20AMBA/03%20AXI/handwritten/images/23-axis-fifo-pointers-count-and-reset.jpg)

**Explanation:** The pointers address storage while `count` distinguishes full
from empty when pointer values coincide. Reset clears validity and occupancy;
pointer widths and full detection must match the actual depth.

#### Handwritten page 24 - FIFO read/write control

![Handwritten AXI notes: FIFO read/write control](../../../../_internal/Protocols/04%20AMBA/03%20AXI/handwritten/images/24-axis-fifo-read-write-control.jpg)

**Explanation:** The page traces the write and read branches and the registered
output. A compact invariant is `next_count = count + push - pop`, where `push`
and `pop` are handshake events, including the simultaneous case.

### Video 41 - FIFO RTL continuation and verification

![Full-screen FIFO testbench signals and DUT instantiation](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2002/41-axis-fifo-p3-course-labeled-p2-20.png)

The course labels this second consecutive item "P2"; in the notes it is treated
as the continuation/verification lesson. The testbench connects the full beat
bundle and exposes internal memory, pointers, flags, and count for waveform
debugging. Those internal signals are useful evidence, but correctness must be
judged from accepted input and output transfers, not from pointer motion alone.

![Full-screen FIFO waveform filling to full, holding occupancy, and draining to empty](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2002/41-axis-fifo-p3-course-labeled-p2-55.png)

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

### Lesson 42 - FIFO code resource

This resource belongs to the first FIFO implementation. Before reusing it,
resolve the declared-depth/full-threshold mismatch, make pointer wrap explicit,
support simultaneous enqueue/dequeue, and ensure downstream `TVALID` is
independent of downstream `TREADY`.

### Video 43 - AXI-Stream FIFO alternate implementation

![Full-screen alternate FIFO interface using wire outputs with the same beat memories and pointers](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2002/43-axis-fifo-alternate-20.png)

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

![Full-screen alternate FIFO sequential memory update and pointer/count logic](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2002/43-axis-fifo-alternate-55.png)

The sequential block still owns `push`, `pop`, pointers, and occupancy. Output
wires do not eliminate the need for the four-case count update. If a priority
`else if` remains, the alternate interface may look more responsive while
still discarding one of two simultaneous events.

![Full-screen alternate FIFO waveform showing fill, full, drain, pointers, and count](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2002/43-axis-fifo-alternate-85.png)

The waveform again demonstrates fill and drain under the supplied stimulus.
Its most useful signals are `count`, `full`, `empty`, `wr_ptr`, and `rd_ptr`:
together they can reveal off-by-one capacity errors that may not appear in the
first short packet. A long wraparound scoreboard remains the decisive test.

### Lesson 44 - Alternate FIFO code resource

Lesson 44 completes Section 3. Keep the alternate code beside Video 43 and
judge it by externally visible invariants: accepted beats are neither lost nor
duplicated, ordering and sidebands are preserved, and the interface stays
stable under back-pressure.

## Section 3 protocol-hardening checklist

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

## Active-recall checkpoint

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

[Continue to Section 4](Section%2004%20-%20Getting%20Started%20with%20AXI4-Lite.md).
