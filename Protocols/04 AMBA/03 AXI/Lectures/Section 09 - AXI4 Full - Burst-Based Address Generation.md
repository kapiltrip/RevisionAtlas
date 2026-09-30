# Section 9 - AXI4 Full with Burst-Based Address Generation

[Previous: Section 8](Section%2008%20-%20AXI4%20Full%20-%20Hardcoded%20Next%20Address.md) | [Section index](README.md) | [AXI chapter](../README.md)

**Course status:** 16/16 lessons complete, covering lessons 113-128.

The final section replaces the hardcoded next-address shortcut with logic based
on `AxBURST`, `AxSIZE`, and `AxLEN`. It then rebuilds the Manager and
Subordinate around that generator and verifies the connected pair.

## Lesson index

| Lesson | Topic | Notebook pages |
|---:|---|---|
| <a id="index-lesson-113"></a>[113](#lesson-113) | Section 9 agenda | — |
| <a id="index-lesson-114"></a>[114](#lesson-114) | Understanding FIXED mode | <a id="index-page-52"></a>[52](#page-52), <a id="index-page-53"></a>[53](#page-53), <a id="index-page-54"></a>[54](#page-54) |
| <a id="index-lesson-115"></a>[115](#lesson-115) | Implementing FIXED writes | — |
| <a id="index-lesson-116"></a>[116](#lesson-116) | Understanding INCR mode | <a id="index-page-55"></a>[55](#page-55) |
| <a id="index-lesson-117"></a>[117](#lesson-117) | Implementing INCR writes | — |
| <a id="index-lesson-118"></a>[118](#lesson-118) | Understanding WRAP mode | <a id="index-page-56"></a>[56](#page-56), <a id="index-page-57"></a>[57](#page-57), <a id="index-page-58"></a>[58](#page-58), <a id="index-page-59"></a>[59](#page-59) |
| <a id="index-lesson-119"></a>[119](#lesson-119) | Implementing WRAP writes | — |
| <a id="index-lesson-120"></a>[120](#lesson-120) | Burst modes during read operation | <a id="index-page-60"></a>[60](#page-60) |
| <a id="index-lesson-121"></a>[121](#lesson-121) | Implementing the full Manager | — |
| <a id="index-lesson-122"></a>[122](#lesson-122) | Manager code resource | — |
| <a id="index-lesson-123"></a>[123](#lesson-123) | Implementing Subordinate write | — |
| <a id="index-lesson-124"></a>[124](#lesson-124) | Implementing Subordinate read | — |
| <a id="index-lesson-125"></a>[125](#lesson-125) | Subordinate code resource | — |
| <a id="index-lesson-126"></a>[126](#lesson-126) | Connecting the final Manager and Subordinate | — |
| <a id="index-lesson-127"></a>[127](#lesson-127), <a id="index-lesson-128"></a>[128](#lesson-128) | Final design and testbench resources | — |

## Formal standard explanation

For all modes, define:

$$
bytes\_per\_beat=2^{AxSIZE}
$$

and:

$$
beats=AxLEN+1
$$

`AxSIZE` must describe no more bytes than the data bus can carry. The complete
transaction must also remain within one 4-KiB address region.

For FIXED, every beat uses the starting address. For INCR, the first transfer
uses the commanded address; subsequent transfers advance from the aligned
address in steps of `bytes_per_beat`. For WRAP, define:

$$
wrap\_bytes=bytes\_per\_beat \times beats
$$

and align the wrap boundary downward to that many bytes. Address increments
that reach the upper boundary return to the lower boundary. A WRAP burst must
contain 2, 4, 8, or 16 beats and its starting address must be aligned to the
transfer size. AXI4 permits up to 256 beats for INCR and up to 16 for the other
burst types. Bursts cannot cross a 4-KiB boundary and cannot terminate early;
even unwanted remaining beats must complete according to the original command.

**Standard basis:** [Arm IHI 0022H, §§A3.4.1-A3.4.2](https://developer.arm.com/-/media/Arm%20Developer%20Community/PDF/IHI0022H_amba_axi_protocol_spec.pdf).

## Lessons 113-128

<a id="lesson-113"></a>

### Video 113 - Section 9 agenda

[Back to index — lesson 113](#index-lesson-113)

![Original full-frame Section 9 agenda](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/113-agenda-50.png)

The agenda explicitly names burst modes, full-AXI read/write transactions,
Manager/Subordinate implementation, and protocol checking. Address generation
is now part of the protocol payload interpretation rather than a fixed local
constant.

[Back to index — lesson 113](#index-lesson-113)

<a id="lesson-114"></a>

### Video 114 - Understanding FIXED mode

[Back to index — lesson 114](#index-lesson-114)

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

<a id="page-52"></a>

#### Handwritten page 52 - Burst types and a FIXED-address example

[Back to index — notebook page 52](#index-page-52)

![Handwritten AXI notes: Burst types and a FIXED-address example](../../../../_internal/Protocols/04%20AMBA/03%20AXI/handwritten/images/52-axi4-burst-types-and-fixed-address-example.jpg)

**Explanation:** Bursts amortize memory-access latency across multiple beats and use FIXED, INCR, or WRAP addressing. In FIXED mode every beat uses the same transfer
address even though the data sequence contains multiple beats.

[Back to index — notebook page 52](#index-page-52)

<a id="page-53"></a>

#### Handwritten page 53 - `AxSIZE` and bytes per beat

[Back to index — notebook page 53](#index-page-53)

![Handwritten AXI notes: `AxSIZE` and bytes per beat](../../../../_internal/Protocols/04%20AMBA/03%20AXI/handwritten/images/53-axsize-and-bytes-per-beat.jpg)

**Explanation:** The worked values apply `bytes_per_beat = 2^AxSIZE`. A
four-byte beat occupies four byte lanes; an unaligned starting address is
possible only within the protocol's alignment and lane rules, with strobes
identifying valid write lanes.

[Back to index — notebook page 53](#index-page-53)

<a id="page-54"></a>

#### Handwritten page 54 - Beat, burst length, and FIXED addresses

[Back to index — notebook page 54](#index-page-54)

![Handwritten AXI notes: Beat, burst length, and FIXED addresses](../../../../_internal/Protocols/04%20AMBA/03%20AXI/handwritten/images/54-beat-burst-length-and-fixed-addresses.jpg)

**Explanation:** A beat is one data-channel transfer, while a burst is the
transaction's ordered beat sequence. `AxLEN+1` is the beat count, and FIXED
leaves the transfer address unchanged for every accepted beat.

[Back to index — lesson 114](#index-lesson-114)

[Back to index — notebook page 54](#index-page-54)

<a id="lesson-115"></a>

### Video 115 - Implementing FIXED writes

[Back to index — lesson 115](#index-lesson-115)

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

[Back to index — lesson 115](#index-lesson-115)

<a id="lesson-116"></a>

### Video 116 - Understanding INCR mode

[Back to index — lesson 116](#index-lesson-116)

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

<a id="page-55"></a>

#### Handwritten page 55 - FIXED and incrementing address examples

[Back to index — notebook page 55](#index-page-55)

![Handwritten AXI notes: FIXED and incrementing address examples](../../../../_internal/Protocols/04%20AMBA/03%20AXI/handwritten/images/55-fixed-and-incrementing-address-examples.jpg)

**Explanation:** The top example revisits FIXED addressing; the lower example
begins INCR. For INCR, the next transfer address advances by `2^AxSIZE` after
each beat, subject to the burst boundary rules.

[Back to index — lesson 116](#index-lesson-116)

[Back to index — notebook page 55](#index-page-55)

<a id="lesson-117"></a>

### Video 117 - Implementing INCR writes

[Back to index — lesson 117](#index-lesson-117)

![Original full-frame INCR branch in the write next-address RTL](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/117-implementation-of-incr-mode-during-write-25.png)

The increment branch adds `1 << AWSIZE` after each accepted W beat. It must not
increment merely because `WVALID` is HIGH; a back-pressured beat retains both
its address association and payload.

![Original full-frame later INCR implementation with counter and terminal logic](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/117-implementation-of-incr-mode-during-write-75.png)

Before issuing the command, a Manager or interconnect must ensure the burst does
not cross a 4-KiB boundary. This is a transaction-level condition: compare the
start and final byte-address region, not just each local increment.

[Back to index — lesson 117](#index-lesson-117)

<a id="lesson-118"></a>

### Video 118 - Understanding WRAP mode

[Back to index — lesson 118](#index-lesson-118)

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

<a id="page-56"></a>

#### Handwritten page 56 - WRAP boundary formula

[Back to index — notebook page 56](#index-page-56)

![Handwritten AXI notes: WRAP boundary formula](../../../../_internal/Protocols/04%20AMBA/03%20AXI/handwritten/images/56-wrap-boundary-formula.jpg)

**Explanation:** A WRAP burst uses a window of `beats * bytes_per_beat`. The
lower boundary is `floor(start/window) * window`, and the upper boundary is one
window above it; address generation wraps to the lower boundary on reaching the
upper one.

[Back to index — notebook page 56](#index-page-56)

<a id="page-57"></a>

#### Handwritten page 57 - Wrapping address sequence

[Back to index — notebook page 57](#index-page-57)

![Handwritten AXI notes: Wrapping address sequence](../../../../_internal/Protocols/04%20AMBA/03%20AXI/handwritten/images/57-wrapping-address-sequence.jpg)

**Explanation:** For four beats of four bytes, the window is 16 bytes. The
address sequence advances by four bytes inside that window and returns to its
lower boundary after the highest transfer address.

[Back to index — notebook page 57](#index-page-57)

<a id="page-58"></a>

#### Handwritten page 58 - WRAP boundary examples

[Back to index — notebook page 58](#index-page-58)

![Handwritten AXI notes: WRAP boundary examples](../../../../_internal/Protocols/04%20AMBA/03%20AXI/handwritten/images/58-wrap-boundary-examples.jpg)

**Explanation:** The examples vary `AxLEN`, `AxSIZE`, and the starting address.
Legal AXI WRAP burst lengths are 2, 4, 8, or 16 beats - encoded by `AxLEN`
values 1, 3, 7, or 15.

[Back to index — notebook page 58](#index-page-58)

<a id="page-59"></a>

#### Handwritten page 59 - WRAP length validity and boundary alignment

[Back to index — notebook page 59](#index-page-59)

![Handwritten AXI notes: WRAP length validity and boundary alignment](../../../../_internal/Protocols/04%20AMBA/03%20AXI/handwritten/images/59-wrap-length-validity-and-boundary-alignment.jpg)

**Explanation:** The highlighted six-beat case is intentionally invalid: WRAP
length must be a supported power-of-two beat count. The boundary calculation
must use integer floor division so the lower boundary stays aligned to the
complete wrap window.

[Back to index — lesson 118](#index-lesson-118)

[Back to index — notebook page 59](#index-page-59)

<a id="lesson-119"></a>

### Video 119 - Implementing WRAP writes

[Back to index — lesson 119](#index-lesson-119)

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

[Back to index — lesson 119](#index-lesson-119)

<a id="lesson-120"></a>

### Video 120 - Burst modes during read operation

[Back to index — lesson 120](#index-lesson-120)

![Original full-frame read-side FIXED, INCR, and WRAP selection RTL](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/120-burst-modes-implementation-during-read-operation-25.png)

The read generator mirrors the write formulas using `ARBURST`, `ARSIZE`, and
`ARLEN`. The Subordinate chooses the address for the next offered R beat after
the current one is accepted.

![Original full-frame completed read next-address, RLAST, and counter logic](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/120-burst-modes-implementation-during-read-operation-75.png)

During `RVALID && !RREADY`, the current address, selected `RDATA`, `RRESP`,
`RID`, and `RLAST` remain stable. The generator advances on `r_fire`; tying it
to the clock or `RVALID` alone would skip memory locations under back-pressure.

<a id="page-60"></a>

#### Handwritten page 60 - AXI course summary and next steps

[Back to index — notebook page 60](#index-page-60)

![Handwritten AXI notes: AXI course summary and next steps](../../../../_internal/Protocols/04%20AMBA/03%20AXI/handwritten/images/60-axi-course-summary-and-next-steps.jpg)

**Explanation:** AXI has three interface families with different channel structures. AXI-Stream itself has one forward payload
handshake, while AXI4-Lite and AXI4 use the five-channel read/write structure.

[Back to index — lesson 120](#index-lesson-120)

[Back to index — notebook page 60](#index-page-60)

<a id="lesson-121"></a>

### Video 121 - Implementing the full Manager

[Back to index — lesson 121](#index-lesson-121)

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

[Back to index — lesson 121](#index-lesson-121)

<a id="lesson-122"></a>

### Lesson 122 - Manager code resource

[Back to index — lesson 122](#index-lesson-122)

The Section 9 Manager source preserves the instructor's naming and FSM. Its
comments identify legal burst modes and lengths, alignment/data-width profile,
one-outstanding capacity, response handling, 4-KiB responsibility, and every
full-AXI sideband that the teaching interface omits.

[Back to index — lesson 122](#index-lesson-122)

<a id="lesson-123"></a>

### Video 123 - Implementing Subordinate write

[Back to index — lesson 123](#index-lesson-123)

![Original full-frame Subordinate write FSM and burst-address RTL](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/123-implementing-slave-write-25.png)

The write Subordinate captures AW context once and consumes `AWLEN+1` W beats.
The burst generator selects the target byte address for each accepted data
item. `WSTRB` qualifies bytes at that address.

![Original full-frame later Subordinate write logic with WLAST and response generation](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/123-implementing-slave-write-75.png)

The final accepted beat must have `WLAST=1`. After it, the design returns one
held B response with the stored ID. A protocol checker should flag early,
late, or missing `WLAST`; the memory update must not conceal that violation.

[Back to index — lesson 123](#index-lesson-123)

<a id="lesson-124"></a>

### Video 124 - Implementing Subordinate read

[Back to index — lesson 124](#index-lesson-124)

![Original full-frame Subordinate read FSM, address generator, and R-channel RTL](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/124-implementing-slave-read-25.png)

The read Subordinate captures AR context and offers data for the current burst
address. It returns the stored ID on every beat and marks the counter's final
item with `RLAST`.

![Original full-frame later Subordinate read logic with held response and last beat](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/124-implementing-slave-read-75.png)

The final state transition requires `r_fire && RLAST`. If `RLAST` is HIGH while
`RREADY` is LOW, the FSM, address, data, ID, and response all remain on that
final item.

[Back to index — lesson 124](#index-lesson-124)

<a id="lesson-125"></a>

### Lesson 125 - Subordinate code resource

[Back to index — lesson 125](#index-lesson-125)

The source records memory geometry, read/write address calculation, allowed
burst profile, byte-strobe semantics, unsupported-address behavior, response
generation, and ignored optional sidebands. This makes the exact teaching code
auditable without redesigning it.

[Back to index — lesson 125](#index-lesson-125)

<a id="lesson-126"></a>

### Video 126 - Connecting the final Manager and Subordinate

[Back to index — lesson 126](#index-lesson-126)

![Original full-frame final top-level AXI4 connection source](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/126-connecting-master-and-slave-together-25.png)

The top-level source wires all command context and return context with matching
widths. Do a direction audit channel by channel before simulation; a swapped
ready/valid direction can elaborate yet produce a dead interface.

![Original full-frame final full-AXI waveform with burst addresses, data, IDs, and last markers](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/126-connecting-master-and-slave-together-75.png)

The final waveform is the course-level proof. For each command, reconstruct the
expected address sequence from mode/size/length, circle accepted data beats,
check the final marker, then verify ID and response. Repeat with ready stalls so
the sequence proves hold behavior as well as the no-stall result.

[Back to index — lesson 126](#index-lesson-126)

<a id="lesson-127"></a>

<a id="lesson-128"></a>

### Lessons 127-128 - Final design and testbench resources

[Back to index — lesson 127](#index-lesson-127) | [Back to index — lesson 128](#index-lesson-128)

Lesson 127 contains the connected design and lesson 128 contains the final
testbench. The code comments map each stimulus to FIXED, INCR, or WRAP and state
the expected address sequence, response, ID, beat count, and last-beat edge.
The testbench preserves the instructor's scenario order and naming.

[Back to index — lesson 127](#index-lesson-127) | [Back to index — lesson 128](#index-lesson-128)

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

[Return to the section index](README.md).
