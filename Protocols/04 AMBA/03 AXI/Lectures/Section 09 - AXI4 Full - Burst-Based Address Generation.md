# Section 9 - AXI4 Full with Burst-Based Address Generation

[Previous: Section 8](Section%2008%20-%20AXI4%20Full%20-%20Hardcoded%20Next%20Address.md) | [Course hub](../Course%20Atlas.md) | [AXI chapter](../README.md)

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

## Lessons 113-128

### Video 113 - Section 9 agenda

![Original full-frame Section 9 agenda](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/113-agenda-50.png)

The agenda explicitly names burst modes, full-AXI read/write transactions,
Manager/Subordinate implementation, and protocol checking. Address generation
is now part of the protocol payload interpretation rather than a fixed local
constant.

### Video 114 - Understanding FIXED mode

![Original full-frame handwritten FIXED-burst address example](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/114-understanding-fixed-mode-25.png)

In a FIXED burst every beat uses the same byte address:

$$
A_k=A_0
$$

This is useful for FIFO-style or device ports where repeated transfers target
one location whose meaning changes internally. `AxLEN+1` still sets the number
of beats; fixed address does not mean single beat.

![Original full-frame FIXED-burst memory mapping and repeated-address notes](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/114-understanding-fixed-mode-75.png)

The memory sketch shows why the address is not a normal array walk. Each
accepted data beat is a separate transfer even though the address value repeats.
Beat counters and last markers still advance only on data-channel handshakes.

### Video 115 - Implementing FIXED writes

![Original full-frame Verilog FIXED-mode next-address selection](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/115-implementation-of-fixed-mode-during-write-25.png)

The write generator selects the fixed branch from `AWBURST` and keeps the
current address unchanged after each `w_fire`. Address/control fields were
captured at `aw_fire`; a changing external AW bus after that acceptance must not
alter the active burst.

![Original full-frame completed FIXED write-data and address-control RTL](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/115-implementation-of-fixed-mode-during-write-75.png)

The memory side must still apply each beat's `WSTRB`. A repeated address with
different strobes can update different bytes across successive transfers, or
can represent repeated pushes into a side-effecting port depending on the
mapped target.

### Video 116 - Understanding INCR mode

![Original full-frame handwritten INCR burst with beat spacing](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/116-understanding-incr-mode-25.png)

For aligned incrementing transfers, the teaching sequence is:

$$
A_k=A_0+k\times 2^{AxSIZE}
$$

The handwritten line illustrates successive beats separated by the number of
bytes per transfer, not necessarily by the full bus width.

![Original full-frame INCR examples for several beat sizes and addresses](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/116-understanding-incr-mode-75.png)

For a narrow transfer, byte-lane selection and `WSTRB` must match the current
address. A reusable generator also handles an unaligned first address according
to the AXI rules. The course code's supported alignment and data-width profile
is documented directly in the source.

### Video 117 - Implementing INCR writes

![Original full-frame INCR branch in the write next-address RTL](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/117-implementation-of-incr-mode-during-write-25.png)

The increment branch adds `1 << AWSIZE` after each accepted W beat. It must not
increment merely because `WVALID` is HIGH; a back-pressured beat retains both
its address association and payload.

![Original full-frame later INCR implementation with counter and terminal logic](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/117-implementation-of-incr-mode-during-write-75.png)

Before issuing the command, a Manager or interconnect must ensure the burst does
not cross a 4-KiB boundary. This is a transaction-level condition: compare the
start and final byte-address region, not just each local increment.

### Video 118 - Understanding WRAP mode

![Original full-frame handwritten WRAP boundary formula and examples](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/118-understanding-wrap-mode-25.png)

A wrapping burst increments normally inside a fixed-size aligned window. Let:

$$
burst\_bytes=(AxLEN+1)\times 2^{AxSIZE}
$$

$$
lower=\left\lfloor\frac{A_0}{burst\_bytes}\right\rfloor burst\_bytes,
\qquad upper=lower+burst\_bytes
$$

When the next increment would reach `upper`, the address wraps to `lower`.

![Original full-frame worked WRAP sequences and wrap-window notes](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/118-understanding-wrap-mode-75.png)

AXI wrapping bursts have 2, 4, 8, or 16 beats, and the start address is aligned
to the transfer size. The start can be inside the wrap window rather than at
its lower boundary, so the visible sequence can increment to the upper edge,
wrap, and finish below the starting address.

### Video 119 - Implementing WRAP writes

![Original full-frame handwritten wrap-boundary calculation used by the RTL](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/119-implementation-of-wrap-mode-during-write-25.png)

The first frame derives lower and upper boundaries from captured length and
size. Hardware implements the powers of two as shifts and masks; no general
divider is required for the legal burst sizes.

![Original full-frame WRAP next-address implementation and worked sequence](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/119-implementation-of-wrap-mode-during-write-75.png)

The branch compares the incremented address with the upper boundary and selects
either that increment or the lower boundary. Boundary state belongs to the
active command and must remain unchanged through W stalls.

The source comments name the supported legal lengths and alignment assumption.
An illegal WRAP length is not made legal by producing some modular sequence; it
must be prevented or reported by the surrounding design/checker policy.

### Video 120 - Burst modes during read operation

![Original full-frame read-side FIXED, INCR, and WRAP selection RTL](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/120-burst-modes-implementation-during-read-operation-25.png)

The read generator mirrors the write formulas using `ARBURST`, `ARSIZE`, and
`ARLEN`. The Subordinate chooses the address for the next offered R beat after
the current one is accepted.

![Original full-frame completed read next-address, RLAST, and counter logic](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/120-burst-modes-implementation-during-read-operation-75.png)

During `RVALID && !RREADY`, the current address, selected `RDATA`, `RRESP`,
`RID`, and `RLAST` remain stable. The generator advances on `r_fire`; tying it
to the clock or `RVALID` alone would skip memory locations under back-pressure.

### Video 121 - Implementing the full Manager

![Original full-frame Manager write/read FSM and complete full-AXI port list](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/121-implementing-master-25.png)

The combined Manager holds command fields, chooses a burst generator, and
controls terminal responses. It remains one-outstanding in the teaching model,
so the active ID and burst context fit in one register set.

![Original full-frame later Manager RTL with burst fields and address updates](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/121-implementing-master-75.png)

Follow the lifetime of each captured field: `AxID` returns on B/R, `AxLEN`
defines counter terminal count, `AxSIZE` defines byte spacing, and `AxBURST`
selects FIXED/INCR/WRAP. Optional lock/cache/protection/QoS/region/user signals
that the course does not implement are listed as omitted or tied assumptions in
the exact source, not given invented behavior.

### Lesson 122 - Manager code resource

The Section 9 Manager source preserves the instructor's naming and FSM. Its
comments identify legal burst modes and lengths, alignment/data-width profile,
one-outstanding capacity, response handling, 4-KiB responsibility, and every
full-AXI sideband that the teaching interface omits.

### Video 123 - Implementing Subordinate write

![Original full-frame Subordinate write FSM and burst-address RTL](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/123-implementing-slave-write-25.png)

The write Subordinate captures AW context once and consumes `AWLEN+1` W beats.
The burst generator selects the target byte address for each accepted data
item. `WSTRB` qualifies bytes at that address.

![Original full-frame later Subordinate write logic with WLAST and response generation](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/123-implementing-slave-write-75.png)

The final accepted beat must have `WLAST=1`. After it, the design returns one
held B response with the stored ID. A protocol checker should flag early,
late, or missing `WLAST`; the memory update must not conceal that violation.

### Video 124 - Implementing Subordinate read

![Original full-frame Subordinate read FSM, address generator, and R-channel RTL](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/124-implementing-slave-read-25.png)

The read Subordinate captures AR context and offers data for the current burst
address. It returns the stored ID on every beat and marks the counter's final
item with `RLAST`.

![Original full-frame later Subordinate read logic with held response and last beat](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/124-implementing-slave-read-75.png)

The final state transition requires `r_fire && RLAST`. If `RLAST` is HIGH while
`RREADY` is LOW, the FSM, address, data, ID, and response all remain on that
final item.

### Lesson 125 - Subordinate code resource

The source records memory geometry, read/write address calculation, allowed
burst profile, byte-strobe semantics, unsupported-address behavior, response
generation, and ignored optional sidebands. This makes the exact teaching code
auditable without redesigning it.

### Video 126 - Connecting the final Manager and Subordinate

![Original full-frame final top-level AXI4 connection source](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/126-connecting-master-and-slave-together-25.png)

The top-level source wires all command context and return context with matching
widths. Do a direction audit channel by channel before simulation; a swapped
ready/valid direction can elaborate yet produce a dead interface.

![Original full-frame final full-AXI waveform with burst addresses, data, IDs, and last markers](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/126-connecting-master-and-slave-together-75.png)

The final waveform is the course-level proof. For each command, reconstruct the
expected address sequence from mode/size/length, circle accepted data beats,
check the final marker, then verify ID and response. Repeat with ready stalls so
the sequence proves hold behavior as well as the no-stall result.

### Lessons 127-128 - Final design and testbench resources

Lesson 127 contains the connected design and lesson 128 contains the final
testbench. The code comments map each stimulus to FIXED, INCR, or WRAP and state
the expected address sequence, response, ID, beat count, and last-beat edge.
The testbench preserves the instructor's scenario order and naming.

## Burst-address reference

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

## Active-recall checkpoint

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

[Return to the course hub](../Course%20Atlas.md).
