# AHB Lecture and Handwritten Atlas

[Back to AHB](../README.md) | [Back to AMBA](../../README.md)

This atlas follows the order requested for revision: first inspect the lecture
frame, then explain what happens on the bus, then read the corresponding
original handwritten page and correct or deepen it. The notebook scans and the
later iPad annotations are kept separate because they show two different stages
of the same learning process.

The protocol authority used throughout is Arm's
[AMBA AHB Protocol Specification, ARM IHI 0033C](../sources/ARM-IHI-0033C-AMBA-AHB-Protocol-Specification.pdf).
The playlist is used for its teaching sequence and waveform examples, not as a
replacement for the specification.

## How to read every waveform

Do not read an AHB waveform one vertical line at a time. At each rising edge,
ask two questions:

1. Which transfer is in its **address phase**?
2. Which earlier transfer is in its **data phase**, and does `HREADY` complete
   that phase?

This matters because AHB is pipelined. Address/control for transfer $N+1$ can
appear while data for transfer $N$ is being completed. A LOW `HREADY` extends
the current data phase and also prevents the next address phase from advancing.
That one rule explains most of the timing diagrams in these notes
([Arm IHI 0033C, §§3.1 and 3.7](../sources/ARM-IHI-0033C-AMBA-AHB-Protocol-Specification.pdf)).

## Source-page map

| Notebook page | Main idea | Related iPad page |
|---:|---|---:|
| 1 | AMBA and AHB introduction | - |
| 2 | SoC hierarchy and AHB-to-APB bridge | - |
| 3 | Manager, subordinate, and interconnect | - |
| 4 | Manager-side interface signals | - |
| 5 | `HTRANS` encodings and a single transfer | 3 |
| 6 | Address and data phases | 2 |
| 7 | Read transfer without waits | - |
| 8 | Write transfer, `HREADY`, and `HRESP` | 1 |
| 9 | Transfer types and `HSIZE` | 3 |
| 10 | Burst/size controls and packet addresses | 4-8 |
| 11 | Burst addresses and boundaries | 4-6 |
| 12 | `HBURST` encodings and readiness | 6 |
| 13 | Waited transfers and BUSY | 1, 10 |
| 14 | INCR, BUSY, and IDLE behavior | 7, 9, 10 |
| 15 | First manager FSM sketch | - |
| 16 | SINGLE-transfer implementation exercise | - |
| 17 | Manager module ports | - |
| 18 | Internal registers/data-phase draft | - |

## 1. Bus purpose, components, and ownership

### Lecture frame: the manager starts the transfer

![Lecture frame showing the AHB manager role](../images/lecture/ahb-manager-role.png)

The frame places the manager on the initiating side of the bus. A manager does
more than place an address: it drives the address-phase control that describes
the transfer. The selected subordinate later finishes that transfer by driving
read data or accepting write data and returning completion/response signals.
An interconnect can decode the address and route those signals, but it does not
change the basic manager-to-subordinate contract.

### Original notebook page 1: AMBA and AHB introduction

![Original handwritten AHB introduction](images/01-amba-ahb-introduction.jpg)

The page correctly treats AMBA as an Arm bus architecture used to connect
reusable IP inside a system-on-chip. The important refinement is that **AMBA is
a protocol family**, while AHB is one member of that family. AHB is intended
for higher-bandwidth communication and supports pipelined transfers and
bursts. APB is a different member optimized for simple peripherals.

The note that a protocol defines communication is the right starting point. In
hardware, that means every endpoint agrees on signal ownership, what each
encoding means, and at which clock edge information is accepted. Two blocks
with matching signal widths are not interoperable unless they obey the same
timing rules.

### Original notebook page 2: SoC hierarchy and bridge

![Original handwritten SoC and bridge page](images/02-soc-bridge-and-transactions.jpg)

The drawing shows a useful architecture: higher-performance initiators and
memory live on AHB, while a bridge converts selected accesses into APB
transactions for lower-bandwidth peripherals such as UARTs. This is a
**protocol conversion**, not merely a wire connection. The bridge accepts an
AHB transfer, decodes and buffers its information, performs the APB SETUP and
ACCESS phases, and eventually completes the AHB side.

The bridge may therefore hold AHB with `HREADY=0` while the APB peripheral is
still completing its access. This relationship is the practical reason to
study AHB and APB together while keeping their timing diagrams separate.

### Original notebook page 3: manager, subordinate, and interconnect

![Original handwritten manager and subordinate page](images/03-manager-subordinate-and-interconnect.jpg)

The page's request/response picture is conceptually correct. The manager
initiates; the subordinate responds. On AHB-Lite there is one manager, so the
learning design does not need arbitration between competing managers. In a
larger AHB system, address decoding and response multiplexing can sit in the
interconnect.

Use the current terms **manager** and **subordinate**. The older master/slave
terms visible in the notes and videos refer to the same protocol roles. A
manager does not decide that a transfer completed merely because it issued a
request: completion occurs only on a rising edge at which the current data
phase sees `HREADY=1`.

### Original notebook page 4: interface direction in context

![Original handwritten manager interface signals](images/04-manager-interface-signals.jpg)

This page is most useful when read as signal ownership around one transaction.
During the address phase, the manager drives `HADDR`, `HTRANS`, `HWRITE`,
`HSIZE`, `HBURST`, and protection/control information. For a write, it drives
`HWDATA` in the following data phase. The subordinate path returns `HRDATA`,
`HREADY`, and `HRESP`.

Two corrections prevent common RTL mistakes:

- `HRESP` is a subordinate response received by the manager, not a manager
  output.
- `HREADY` qualifies the **current data phase**. The address/control visible at
  the same time normally describes the next pipelined transfer.

Clock and reset are infrastructure signals; they do not belong to only one
transaction. `HSEL` is normally produced by address decoding for a subordinate
and is not a manager's completion indication.

## 2. Basic transfer phases

### Lecture frame: read without wait states

![Lecture waveform for an AHB read without wait states](../images/lecture/ahb-read-no-wait.png)

For read transfer A, the manager presents address/control in one cycle. In the
next cycle the selected subordinate returns A's `HRDATA`. Because `HREADY`
remains HIGH, the read completes on that next rising edge. Notice that another
address can already be present while A's data is returning; the data belongs to
A, not to the address currently visible.

### Original notebook page 5: `HTRANS` makes a transfer valid

![Original handwritten HTRANS and single-transfer page](images/05-htrans-encodings-and-single-transfer.jpg)

The page records the four `HTRANS` values. Interpret them in the waveform, not
as an isolated list:

- `IDLE (00)` means no data transfer is required for that address phase.
- `BUSY (01)` lets a manager delay the next beat of a burst without terminating
  the burst.
- `NONSEQ (10)` starts a transfer unrelated to the preceding transfer, so it is
  used for a SINGLE or the first beat of a burst.
- `SEQ (11)` continues the current burst.

Only encodings with `HTRANS[1]=1` describe valid transfers. `HTRANS` belongs to
the address phase and is accepted only when `HREADY` permits that phase to
advance ([Arm IHI 0033C, §3.2](../sources/ARM-IHI-0033C-AMBA-AHB-Protocol-Specification.pdf)).

### Original notebook page 6: one transfer, two phases

![Original handwritten address and data phases](images/06-address-and-data-phases.jpg)

The page correctly separates address/control from data. The deeper point is
that the phases can overlap with neighboring transfers:

```text
Cycle             C1               C2               C3
Address bus       A                B                C
Data bus          -                data(A)          data(B)
```

For a write, the manager must keep A's write data valid through A's entire data
phase. For a read, the subordinate must provide A's read data by the edge that
completes A. `HREADY=0` stretches C2; it does not create a new transfer.

### Original notebook page 7: read transfer without a wait

![Original handwritten read-transfer waveform](images/07-read-transfer-no-wait.jpg)

The page's read waveform should be traced from the rising edge where address A
and `HWRITE=0` are accepted. A's `HRDATA` is sampled one cycle later while
`HREADY=1`. The manager must never sample read data in the address phase simply
because an address is visible there.

If an error response were returned, the response would belong to the same data
phase as `HRDATA`. A no-wait example is therefore the minimum-latency case, not
a different kind of read.

### Lecture frame: write without wait states

![Lecture waveform for an AHB write without wait states](../images/lecture/ahb-write-no-wait.png)

The waveform shows address A first and `HWDATA(A)` in the following cycle. This
one-cycle displacement is essential: write data belongs to the data phase and
must not be paired with whichever later address happens to share the wires at
that moment.

### Original notebook page 8: write completion and response

![Original handwritten HREADY and HRESP page](images/08-write-transfer-hready-and-hresp.jpg)

The notes associate `HREADY` with wait insertion and `HRESP` with success or
error. In the AHB-Lite response encoding used here, `HRESP=0` is OKAY and
`HRESP=1` is ERROR. Read the two together at completion: a manager consumes
the response for the current data phase when `HREADY=1`.

For a write, the subordinate accepts `HWDATA` only when that write's data phase
completes. If `HREADY=0`, the manager must keep the data stable; incrementing a
counter or replacing `HWDATA` each clock would corrupt the transaction.

## 3. Pipelining and multiple transfers

### Lecture frame: address/data overlap

![Lecture waveform for pipelined multiple AHB transfers](../images/lecture/ahb-pipelined-multiple-transfers.png)

The frame demonstrates the throughput benefit of AHB. After the pipeline is
filled, one transfer can complete per clock even though each individual
transfer has two phases. At a given cycle, label the address and data rows with
different transfer letters before interpreting any data value.

### iPad page 2: annotated multiple-transfer waveform

![Annotated iPad page for multiple transfers](images/ipad-02-multiple-transfer-annotations.jpg)

The colored A, B, C, and D annotations correctly show that an address appears
one cycle before its associated data. The page also captures the practical
reason for pipelining: address decoding for the next access overlaps the data
movement of the current access.

Do not say that AHB has several outstanding transactions in this simple sense.
The pipeline overlaps phases, but transfer ordering remains defined and the
current `HREADY` governs advancement.

### Lecture frame: all four transfer types in time

![Lecture waveform showing AHB transfer types](../images/lecture/ahb-htrans-transfer-types.png)

Here `NONSEQ` begins useful work, `SEQ` continues a burst, `BUSY` creates a gap
without abandoning that burst, and `IDLE` means no useful transfer is
requested. A BUSY address/control phase is ignored by the subordinate, but the
data phase occurring simultaneously may still belong to the previous valid
beat and must still complete correctly.

### Original notebook page 9: transfer type and size belong to a beat

![Original handwritten HTRANS and HSIZE page](images/09-htrans-types-and-address-sequence.jpg)

The page combines `HTRANS` with the `HSIZE` encoding. `HSIZE` says how many
bytes the current beat transfers: byte, halfword, word, and so on. For the
32-bit word examples, `HSIZE=3'b010`, so successive incrementing addresses are
four bytes apart.

The next address step is therefore not always `+1` and not always `+4`; it is

$$
S=2^{\texttt{HSIZE}}\text{ bytes}.
$$

The transfer address must be aligned to that size. A word transfer needs
`HADDR[1:0]=2'b00` ([Arm IHI 0033C, §3.4](../sources/ARM-IHI-0033C-AMBA-AHB-Protocol-Specification.pdf)).

### iPad page 3: SINGLE versus INCR4

![Annotated iPad page for HTRANS and INCR4](images/ipad-03-htrans-and-incr4.jpg)

The upper example uses a single `NONSEQ` transfer. The lower example starts an
INCR4 burst with `NONSEQ` and follows with three `SEQ` beats. That is why a
manager cannot drive `SEQ` as the first beat: the subordinate needs `NONSEQ` to
recognize a new address sequence.

The handwritten address sequence `0x38, 0x3C, 0x40, 0x44` is correct for four
word beats. `HBURST` identifies the burst form; `HSIZE` supplies the step.

## 4. Burst length, size, and wrapping

### Lecture frame: an INCR4 word burst

![Lecture waveform for an INCR4 word burst](../images/lecture/ahb-incr4-word-timing.png)

This frame should be read beat by beat. `HBURST=INCR4` fixes four beats,
`HSIZE=word` fixes four bytes per beat, and `HTRANS` changes from NONSEQ to SEQ.
`HBURST` and `HSIZE` remain constant through the burst; only the address and
beat-related data advance on accepted transfers.

### Original notebook page 10: controls determine the packet addresses

![Original handwritten burst and size controls](images/10-hsize-and-packet-addresses.jpg)

The page brings `HSIZE`, `HBURST`, and `HTRANS` together. This is the correct
way to calculate addresses. For a fixed-length burst:

$$
\text{payload bytes}=N_{\text{beats}}\times 2^{\texttt{HSIZE}}.
$$

That product is also the wrap-region size for a wrapping burst. It is **not**
the address step: the step remains one beat, $2^{\texttt{HSIZE}}$ bytes.

### Original notebook page 11: boundary grows with size and beat count

![Original handwritten burst boundary examples](images/11-burst-address-boundary.jpg)

The examples compare bursts using different transfer sizes. They are useful
because the same number of beats can cover different byte ranges. Four byte
beats cover four bytes, four halfword beats cover eight bytes, and four word
beats cover sixteen bytes.

There are two alignment requirements to keep separate:

1. Every transfer address is aligned to the transfer size.
2. A wrapping burst wraps inside a region aligned to the complete wrap size.

The start address may be any size-aligned address inside that wrap region; it
does not have to be the lowest address in the region.

### Original notebook page 12: `HBURST` and the completion gate

![Original handwritten HBURST and HREADY page](images/12-hburst-encodings-and-hready.jpg)

The fixed burst encodings distinguish SINGLE, INCR, WRAP4/8/16, and
INCR4/8/16. These encodings set the expected sequence, but they do not override
`HREADY`. A beat counter advances only when a valid beat completes. If a
four-beat burst sees two wait cycles, it is still a four-beat burst; the wait
cycles are extensions, not extra beats.

The specification also requires incrementing bursts not to cross a 1-KiB
address boundary. That system-level rule is separate from a WRAP4 word burst's
16-byte wrap region ([Arm IHI 0033C, §3.6](../sources/ARM-IHI-0033C-AMBA-AHB-Protocol-Specification.pdf)).

### Lecture frame: mixed transfers in an undefined INCR sequence

![Lecture waveform for undefined INCR behavior](../images/lecture/ahb-undefined-incr-mixed-transfers.png)

An undefined-length INCR burst has no fixed beat count encoded in `HBURST`.
That makes its termination rules different from a fixed INCR4. The waveform
can insert BUSY and later end the sequence with IDLE or begin unrelated work
with NONSEQ. It must still keep one `HSIZE` value throughout the burst.

### iPad page 4: WRAP4 word boundary

![Annotated iPad page for WRAP4 boundary](images/ipad-04-wrap4-boundary.jpg)

The page identifies the correct product for a four-beat word burst:

$$
B_{\text{wrap}}=4\text{ beats}\times4\text{ bytes}=16\text{ bytes}.
$$

The note calling addresses such as `0x01`, `0x02`, and `0x03` unaligned for a
word transfer is correct. A starting address such as `0x04` is word-aligned,
even though it is not the base of the 16-byte wrap region. Alignment to the
beat size and membership in the wrap region are different tests.

### iPad page 5: wrapping from a non-base start address

![Annotated iPad page for wrap address examples](images/ipad-05-wrap-address-examples.jpg)

For a WRAP4 halfword burst, each beat is two bytes and the wrap region is eight
bytes. Starting at `0x04` produces `0x04, 0x06, 0x00, 0x02` inside the aligned
`0x00-0x07` region. Starting at `0x0A` uses the aligned `0x08-0x0F` region and
produces `0x0A, 0x0C, 0x0E, 0x08`.

The general calculation is:

$$
A_{k+1}=A_{\text{base}}+
\left((A_k-A_{\text{base}}+S)\bmod B_{\text{wrap}}\right),
$$

where $S$ is bytes per beat and $A_{\text{base}}$ is the start of the aligned
wrap region.

### iPad page 6: WRAP4 and WRAP8 use different regions

![Annotated iPad page comparing wrap boundaries](images/ipad-06-wrap4-boundary-examples.jpg)

The WRAP4 word example uses a 16-byte region. A WRAP8 word burst uses a
32-byte region because $8\times4=32$ bytes. This is why RTL must derive the
mask or modulo boundary from both `HBURST` and `HSIZE`; a hard-coded four-bit
mask works only for the WRAP4-word case.

### iPad page 7: undefined-length INCR

![Annotated iPad page for undefined INCR](images/ipad-07-undefined-incr.jpg)

The page's key idea is that the subordinate does not know the final beat count
of an undefined INCR burst from `HBURST`. It observes transfer types. Continued
`SEQ` beats remain part of the burst; an accepted IDLE or NONSEQ ends that
sequence. BUSY may create a temporary gap without itself moving data.

### iPad page 8: transfer size is stable within a burst

![Annotated iPad page for mixed transfer sizes](images/ipad-08-mixed-size-transfer.jpg)

The notes correctly flag that beat size cannot be changed halfway through a
burst. The manager chooses `HSIZE` in the first NONSEQ address phase and keeps
it for the remaining SEQ beats. A new size requires a new transfer sequence,
normally beginning with NONSEQ.

## 5. Wait states, IDLE, and BUSY

### Lecture frame: read with two wait states

![Lecture waveform for an AHB read with two wait states](../images/lecture/ahb-read-two-wait-states.png)

The read's data phase lasts until the final HIGH `HREADY`. During the LOW
cycles, the subordinate has not completed the transfer and the manager must
not sample `HRDATA` as final. Address/control for the pipelined next transfer
also remains held.

### Lecture frame: write with one wait state

![Lecture waveform for an AHB write with one wait state](../images/lecture/ahb-write-one-wait-state.png)

For a waited write, both the address/control for the next transfer and the
current write's `HWDATA` remain stable. The held address and held write data can
belong to different transfers because of the pipeline; annotate transfer names
before checking stability.

### iPad page 1: writing through a wait state

![Annotated iPad page for a write wait state](images/ipad-01-write-wait-state-annotations.jpg)

The page correctly emphasizes that a manager cannot change phase while
`HREADY=0`. More precisely, it holds the current data-phase information and the
next address-phase information. When `HREADY` returns HIGH, the current data
phase completes and the pipelined address may advance together on that edge.

The write-data annotation is valuable: data A remains on `HWDATA` across the
wait. Data B cannot replace it until A's data phase has completed.

### Original notebook page 13: waits do not change burst length

![Original handwritten waited-transfer and BUSY page](images/13-waited-transfer-and-busy.jpg)

The page says to wait until `HREADY` becomes HIGH. Convert that sentence into
an RTL enable:

```verilog
if (HREADY) begin
    // complete the current data phase and advance accepted state
end
```

A LOW cycle is not a beat and must not increment the address or beat counter.
BUSY is also not a data beat, but it has a different purpose: BUSY preserves a
burst context when the manager is temporarily unable to issue its next beat.

### Lecture frame: IDLE during a waited transfer

![Lecture waveform for IDLE during an AHB wait](../images/lecture/ahb-idle-during-wait.png)

This is a subtle specification case. While the extended address phase remains
IDLE, the manager may change its address because no real transfer is requested.
It may also change `HTRANS` once from IDLE to NONSEQ; after doing so, it must
hold that transfer type and address until `HREADY=1`. Information for the valid
data phase underneath it must still remain correct. This exception must not be
generalized to an already-valid NONSEQ or SEQ address phase.

### Original notebook page 14: synchronization through transfer types

![Original handwritten INCR, BUSY, and IDLE page](images/14-incr-busy-and-idle.jpg)

The page links transfer types to manager/subordinate synchronization. Refine
the rule by considering the current extended address phase:

- Valid NONSEQ or SEQ address/control must remain stable while `HREADY=0`.
- While `HTRANS=IDLE`, the address can change. The manager may change IDLE to
  NONSEQ once, after which transfer type and address must remain fixed until
  `HREADY=1`.
- BUSY behavior depends on the burst. For a fixed-length burst, an extended
  BUSY must be followed by SEQ when the bus advances. For undefined INCR, the
  manager may change from BUSY to another transfer type while waiting.

These are the exceptions illustrated in Arm's wait-state examples
([Arm IHI 0033C, §3.7](../sources/ARM-IHI-0033C-AMBA-AHB-Protocol-Specification.pdf)).

### iPad page 9: response and IDLE are separate ideas

![Annotated iPad page for subordinate response and IDLE](images/ipad-09-idle-during-wait.jpg)

The top of the page correctly assigns `HRESP` to the subordinate. The bottom
shows why IDLE may change during waits. Keep the two lanes separate: `HRESP`
describes the valid transfer in its data phase, while an IDLE `HTRANS` may be
visible for a later address phase that requests no transfer.

An ERROR response belongs to the transfer completing in the data phase. It is
not an error on the IDLE address merely because both values appear in the same
clock column.

### iPad page 10: BUSY during a wait

![Annotated iPad page for BUSY during a wait](images/ipad-10-busy-during-wait.jpg)

This page captures a case that is easy to memorize incorrectly. BUSY says the
burst is still conceptually active but no data beat is requested for that
address phase. If BUSY is extended by `HREADY=0`, fixed-length bursts preserve
the promise to continue with SEQ. Undefined INCR is allowed more freedom to
change the transfer type before the wait ends.

## 6. From protocol timing to an RTL manager

### Original notebook page 15: first FSM sketch

![Original handwritten manager FSM](images/15-manager-fsm.jpg)

The sketch separates idle/start, address, and data/wait ideas. That is a useful
reasoning model, but a literal one-state-per-drawing implementation can hide
the AHB pipeline. Address phase $N+1$ and data phase $N$ coexist, so the RTL
usually needs registers that separately remember the accepted data-phase
transfer and the next address-phase command.

The cleaned comparison is in the
[FSM and lecture correction](../code/FSM.md). The decisive transition is not
simply “one clock passed”; it is “the current data phase completed with
`HREADY=1`.”

### Original notebook page 16: SINGLE-transfer exercise

![Original handwritten SINGLE-transfer exercise](images/16-single-transfer-setup-exercise.jpg)

The page lists an example command and expected control values. A word SINGLE
should use `HBURST=3'b000`, `HSIZE=3'b010`, and `HTRANS=NONSEQ` while its
address phase is valid. IDLE is driven after the one address phase unless a new
unrelated command begins.

The implementation must still retain the command's direction and write data
for the data phase. Clearing the command as soon as its address is issued loses
the information required if the subordinate inserts a wait.

### Original notebook page 17: module ports

![Original handwritten AHB manager module ports](images/17-manager-module-ports.jpg)

The handwritten Verilog outline is an interface draft. Categorize ports by
ownership before coding:

- command inputs come from local logic;
- AHB address/control and `HWDATA` are manager outputs;
- `HRDATA`, `HREADY`, and `HRESP` are manager inputs;
- completion/result outputs report the accepted outcome back to local logic.

Avoid driving protocol outputs to `X` in ordinary functional RTL. Unknowns can
hide bugs in simulation and do not represent a usable bus value in hardware.
Drive an explicit legal idle value instead.

### Original notebook page 18: data-phase registers

![Original handwritten manager register draft](images/18-manager-registers.jpg)

This page begins the essential register split. The RTL needs remembered state
for any transfer whose data phase is not yet complete: direction, write data,
possibly local response bookkeeping, and burst position. `burst_count` must
advance only for accepted data beats, not on every clock and not for BUSY/IDLE.

Address progression must be derived from `HSIZE` and `HBURST`. For the current
learning RTL the supported set is deliberately smaller—SINGLE, INCR4, and
WRAP4 word transfers—so the legality checks and counters can be explicit. See
the [code guide](../code/README.md) for the implemented version.

## Corrections worth memorizing

- `HREADY` completes the current **data phase** and gates pipeline advancement.
- `HWDATA` belongs to the previous accepted write address, not necessarily the
  address currently visible.
- Wait cycles are not beats. Increment address and counters only on accepted
  valid beats.
- `HSIZE` sets bytes per beat; `HBURST` sets burst form/length. A wrap boundary
  is their product.
- BUSY preserves a burst but transfers no data; IDLE requests no transfer.
- AHB's 1-KiB crossing rule is different from a wrapping burst's local wrap
  boundary.
- Current terminology is manager/subordinate; older lecture labels describe
  the same roles.

## Active-recall pass

1. In a cycle showing address B and write data A, which transfer does
   `HREADY` complete?
2. Why can an AHB pipeline complete one transfer per cycle without having the
   address and data of the same transfer in one cycle?
3. What freezes when `HREADY=0`, and exactly what may change while the next
   address phase is IDLE?
4. Generate WRAP4 halfword addresses from `0x0A` without looking back.
5. Explain why a beat counter enabled directly by the clock is incorrect.
6. Compare BUSY in a fixed-length burst with BUSY in undefined INCR.

## Lecture source register

| Topic | Lecture |
|---|---|
| Introduction and bus roles | [AHB lecture 1](https://www.youtube.com/watch?v=dxKE1wHvHCg&list=PLqPfWwayuBvNX_IQPBHGJn8YFkvI86lr9) |
| Read/write without waits | [AHB lecture 2](https://www.youtube.com/watch?v=3SFTy4on9sc&list=PLqPfWwayuBvNX_IQPBHGJn8YFkvI86lr9) |
| Transfers with wait states | [AHB lecture 3](https://www.youtube.com/watch?v=-EbEzAacqoQ&list=PLqPfWwayuBvNX_IQPBHGJn8YFkvI86lr9) |
| Multiple pipelined transfers | [AHB lecture 4](https://www.youtube.com/watch?v=M4CxmSdoSzA&list=PLqPfWwayuBvNX_IQPBHGJn8YFkvI86lr9) |
| `HTRANS` and bursts | [AHB lecture 5](https://www.youtube.com/watch?v=v2EcFDnWIrw&list=PLqPfWwayuBvNX_IQPBHGJn8YFkvI86lr9) |
| Wrapping bursts | [AHB lectures 6-7](https://www.youtube.com/watch?v=1or91qL6bds&list=PLqPfWwayuBvNX_IQPBHGJn8YFkvI86lr9) |
| Transfer types during waits | [AHB lecture 8](https://www.youtube.com/watch?v=39QRExXRBSs&list=PLqPfWwayuBvNX_IQPBHGJn8YFkvI86lr9) |
| Manager FSM and RTL | [AHB lectures 9-12](https://www.youtube.com/watch?v=DmYdSlO2MiE&list=PLqPfWwayuBvNX_IQPBHGJn8YFkvI86lr9) |
