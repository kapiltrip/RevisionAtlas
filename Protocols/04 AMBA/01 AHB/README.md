# 01 - AMBA AHB

[Back to AMBA](../README.md) | [Back to Protocols](../../README.md)

This chapter builds a trustworthy AHB foundation from the protocol itself,
then uses the ALL ABOUT VLSI lecture series only as a teaching reference. The
current code is deliberately small: a 32-bit AHB-Lite manager that performs
SINGLE, INCR4, and WRAP4 word transfers, including read/write data and wait
states.

## Chapter map

| Part | Purpose |
|---|---|
| [FSM and lecture correction](code/FSM.md) | The lecturer's drawn FSM, a clean replacement diagram, and why the RTL uses fewer states |
| [Code guide](code/README.md) | File structure, every local interface variable, burst encodings, and simulation command |
| [Manager RTL](code/rtl/ahb_lite_manager.v) | Corrected synthesizable Verilog for the intentionally limited manager |
| [Self-checking testbench](code/tb/ahb_lite_manager_tb.v) | Memory subordinate, wait-state insertion, read/write checks, and PASS/FAIL output |
| [Lecture and handwritten atlas](handwritten/README.md) | Lecture frames followed by every original page, explanation, corrections, and iPad annotations |
| [Official Arm specification](sources/ARM-IHI-0033C-AMBA-AHB-Protocol-Specification.pdf) | Local non-confidential ARM IHI 0033C source of truth |

## Core terms

The definitions and rules below are checked against Arm's
[AMBA AHB Protocol Specification, ARM IHI 0033C](https://documentation-service.arm.com/static/6141bf0d674a052ae36ca811).

| Term | Precise meaning | Hardware meaning |
|---|---|---|
| **AMBA** | Advanced Microcontroller Bus Architecture, Arm's family of on-chip interface and interconnect protocols. | It supplies common contracts so independently designed IP blocks can connect without inventing a private bus. |
| **AHB** | Advanced High-performance Bus, an AMBA protocol with separate address and data phases and support for single and burst transfers. | Address/control for transfer $N+1$ can overlap the data phase of transfer $N$, improving throughput. |
| **AHB-Lite** | The single-manager subset of AHB. | Removing multi-manager arbitration keeps this learning design focused on transfer timing rather than bus ownership. |
| **Manager** | The interface component that initiates a transfer and drives address/control plus write data. Older material often calls it a master. | In this chapter the manager drives `HADDR`, `HTRANS`, `HWRITE`, `HSIZE`, `HBURST`, and `HWDATA`. |
| **Subordinate** | The addressed component that completes a transfer and supplies readiness, response, and read data. Older material often calls it a slave. | The testbench memory drives `HREADY`, `HRESP`, and `HRDATA`. |
| **Address phase** | One cycle in which the manager presents the address and control for a transfer. | A subordinate samples it only on a rising edge where `HREADY` is HIGH. |
| **Data phase** | One or more cycles in which write data is accepted or read data is returned. | `HREADY=0` lengthens this phase; the associated bus information must remain valid during the wait. |
| **`HTRANS`** | Two-bit transfer type: IDLE, BUSY, NONSEQ, or SEQ. | The first real beat uses NONSEQ; later beats of the same burst use SEQ. `HTRANS[1]=1` identifies a valid transfer. |
| **`HREADY`** | Completion/extension handshake from the selected subordinate path. | HIGH completes the current data phase and permits the next address phase to advance; LOW inserts a wait state and freezes the transfer. |
| **Burst** | A related sequence of transfers whose type and length are encoded by `HBURST`. | INCR4 walks through four increasing addresses; WRAP4 still increments but wraps inside a four-beat boundary. |

## The central timing idea

Every AHB transfer has one address phase and a later data phase. They belong to
the same transfer even though another transfer's address can be visible during
that data phase.

```text
Clock cycle        1              2              3              4
Address phase    beat 0         beat 1         beat 2         beat 3
Data phase         -            beat 0         beat 1         beat 2
Next cycle                                                        beat 3 data
```

If `HREADY` becomes LOW during a data phase, both that transfer and the
pipelined next address are held. The manager must not increment an address,
advance its beat counter, change `HTRANS`, or replace write data merely because
a clock edge occurred. It advances only on a completion edge where `HREADY` is
HIGH.

## Transfer and burst encodings used by the RTL

| Operation | `HTRANS` first/later | `HBURST` | `HSIZE` | Beats |
|---|---|---:|---:|---:|
| SINGLE word | NONSEQ / none | `3'b000` | `3'b010` | 1 |
| INCR4 words | NONSEQ / SEQ | `3'b011` | `3'b010` | 4 |
| WRAP4 words | NONSEQ / SEQ | `3'b010` | `3'b010` | 4 |

`HSIZE=3'b010` means a 32-bit word. The manager rejects an address whose low
two bits are not `00`, because a word transfer must be word-aligned.

For WRAP4 words, the boundary size is:

$$
4\text{ beats}\times 4\text{ bytes per beat}=16\text{ bytes}
$$

Therefore a burst beginning at `0x3C` uses:

```text
0x3C -> 0x30 -> 0x34 -> 0x38
```

The upper address bits select the 16-byte region and the low four bits wrap
modulo 16. This is why masking only with a hard-coded value from one example is
not a general implementation method; the boundary comes from burst length and
transfer size.

## What is intentionally not in this first version

- No multiple managers or arbitration.
- No undefined-length INCR burst, INCR8/16, or WRAP8/16.
- No byte, halfword, or wider transfer sizes.
- No multiple outstanding commands.
- No AHB5 security, exclusive transfer, parity, or extended memory attributes.

These are omitted to keep the first implementation readable, not because AHB
lacks them.

## Source register

| Source | How it is used |
|---|---|
| [Arm IHI 0033C - AMBA AHB Protocol Specification](sources/ARM-IHI-0033C-AMBA-AHB-Protocol-Specification.pdf) | Authority for signal meanings, pipelining, transfer sizes, `HTRANS`, `HREADY`, and burst boundaries |
| [AMBA AHB Protocol Batch 2 playlist](https://www.youtube.com/playlist?list=PLqPfWwayuBvNX_IQPBHGJn8YFkvI86lr9) | Topic order and beginner-oriented examples only |
| [Lecture 9 - AHB master FSM](https://www.youtube.com/watch?v=DmYdSlO2MiE) | Captured state-diagram reference and comparison point |
| [Lecture 10 - incremental-burst RTL](https://www.youtube.com/watch?v=uzEg7ziaSaE) | Variables and intended operation used as inspiration; code not copied |
| [Lecture 11 - INCR4 manager/subordinate/testbench](https://www.youtube.com/watch?v=4jPAmDrMqfY) | Verification scope used as inspiration; testbench rebuilt as self-checking |
| [Lecture 12 - wrap implementation](https://www.youtube.com/watch?v=3LSP1SvmoyA) | Wrap-boundary teaching example, corrected and generalized using the specification |
| [Original handwritten source PDFs](../Handwritten%20data/) | Preserved source scans; rendered derivatives are discussed in page order in the handwritten atlas |

## How to revise this chapter

1. Draw two adjacent clock cycles and place transfer 0's data phase under
   transfer 1's address phase.
2. Freeze the drawing for one cycle and explain exactly what `HREADY=0` holds.
3. Write the four addresses for INCR4 and WRAP4 from the same starting address.
4. Explain why NONSEQ starts a burst and SEQ continues it.
5. Read [the FSM correction](code/FSM.md), then trace the RTL counters with the
   testbench's WRAP4 example.

## Completion checkpoint

- Why is AHB pipelined even though each transfer still has an address and data phase?
- Which transfer does `HWDATA` belong to when a different address is visible?
- What state, address, control, and data must hold while `HREADY` is LOW?
- Why does WRAP4 of 32-bit words use a 16-byte boundary?
- What is wrong with driving protocol outputs to `X` in ordinary functional RTL?

## Next additions

- Revisit the [lecture and handwritten atlas](handwritten/README.md) alongside
  the corresponding playlist video when revising a timing diagram.
- Replace a lecture capture only if a clearer frame carries more timing
  information; preserve the handwritten source scans unchanged.
- Extend the manager only when a new learning goal requires another burst or size.
