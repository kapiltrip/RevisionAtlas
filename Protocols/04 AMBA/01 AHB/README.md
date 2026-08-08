# 01 — AMBA AHB

[Back to AMBA](../README.md) | [Back to Protocols](../../README.md)

AHB is a synchronous AMBA interface with separate address and data phases.
Its defining performance mechanism is **phase overlap**: while transfer $N$ is
in its data phase, transfer $N+1$ can already present address and control.

The implementation in this chapter is intentionally narrower than the
protocol: one 32-bit AHB-Lite manager supporting SINGLE, INCR4, and WRAP4 word
transfers, reads and writes, wait states, and one command at a time.

## Open this chapter

- [AHB notes](../notes/AHB.md) — every source page,
  waveform explanation, corrections, and active recall.
- [FSM correction](code/FSM.md) — why a literal address-state/data-state FSM
  can serialize a pipelined bus.
- [Code guide](code/README.md) — local command interface, phase registers,
  invariants, and simulation.
- [Manager RTL](code/rtl/ahb_lite_manager.v) — synthesizable Verilog-2001.
- [Self-checking testbench](code/tb/ahb_lite_manager_tb.v) — subordinate
  memory, waits, stability checks, and data scoreboarding.
- [Arm IHI 0033C specification](sources/ARM-IHI-0033C-AMBA-AHB-Protocol-Specification.pdf)
  — protocol authority.

## Roles and signal ownership

The **manager** initiates a transfer. It drives `HADDR`, `HTRANS`, `HWRITE`,
`HSIZE`, `HBURST`, protection attributes, and write data.

The **subordinate** completes a selected transfer. Its response path supplies
`HRDATA`, `HREADYOUT`, and `HRESP`.

The **interconnect** decodes `HADDR` into `HSELx` during the address phase and
later multiplexes the selected subordinate's response into manager-facing
`HRDATA`, `HREADY`, and `HRESP`. Because the bus is pipelined, the response
selection must remember the older transfer; decoding the new visible address
again can route the wrong response.

AHB-Lite removes multiple-manager arbitration. It does not remove decoding,
response multiplexing, pipelining, wait states, bursts, or errors.

## The two-lane timing model

Always trace two lanes:

```text
Cycle interval        1           2           3           4
Address/control       A           B           C         IDLE
Data/result           -           A           B           C
```

At the edge ending cycle 2, transfer A can complete while address B is
accepted. The address and data visible in one cycle usually belong to
different transfers.

For a manager, define:

$$
\text{address\_accept}
= \texttt{HREADY} \land \texttt{HTRANS[1]}
$$

`HTRANS[1]=1` covers NONSEQ and SEQ. A subordinate additionally qualifies its
address acceptance with its own `HSELx`.

Once an accepted address creates a data phase:

$$
\text{data\_complete}
= \text{data\_phase\_valid} \land \texttt{HREADY}
$$

These are related pipeline events, not a request/ack pair on one channel.
`HREADY` describes the current data phase while also gating whether the
address pipeline may advance.

## What a wait state means

`HREADY=0` extends the current data phase. In ordinary valid-transfer cases:

- the current data-phase context remains outstanding;
- write data for that transfer must not be replaced;
- the next valid address/control packet must remain valid until accepted;
- beat counters and burst address state do not advance; and
- read data and response are not consumed as a completed result.

The specification has controlled exceptions for IDLE, BUSY, and the first
cycle of an ERROR response. The educational RTL chooses a conservative hold
policy during normal waits and changes `HTRANS` to IDLE only when canceling the
pipelined next transfer for ERROR.

## `HTRANS` is transfer validity plus sequence meaning

- `IDLE (00)`: no data transfer is required.
- `BUSY (01)`: a manager inserts time inside a burst but does not create a
  data beat.
- `NONSEQ (10)`: first beat of a burst or a transfer unrelated to the previous
  one.
- `SEQ (11)`: later beat whose address follows the active burst rules.

Only NONSEQ and SEQ create real transfers. A counter enabled on every clock, or
on BUSY, produces the wrong beat count.

## Size, burst, and address generation

`HSIZE` encodes bytes per beat:

$$
\text{bytes per beat}=2^{\texttt{HSIZE}}
$$

`HBURST` selects SINGLE, undefined INCR, or fixed INCR/WRAP lengths. For a
wrapping burst:

$$
\text{wrap region bytes}
= \text{beats}\times\text{bytes per beat}
$$

The current RTL fixes `HSIZE=3'b010`, so each beat is four bytes. WRAP4
therefore wraps within a 16-byte region. Starting at `0x3C`:

```text
0x3C -> 0x30 -> 0x34 -> 0x38
```

The low four address bits wrap modulo 16 while the upper bits retain the
selected region. This boundary is different from AHB's system-level rule that
an incrementing burst must not cross a 1-KiB address boundary.

Address alignment follows transfer size. The learning manager rejects a word
request when `req_addr[1:0] != 2'b00`.

## Responses and ERROR timing

`HREADY=1` with an OKAY response completes a normal data phase. AHB's ERROR
response occupies two cycles because the next address has already entered the
pipeline:

1. first ERROR cycle: `HRESP=ERROR`, `HREADY=0`; the manager is given time to
   cancel the next transfer by driving IDLE;
2. final ERROR cycle: `HRESP=ERROR`, `HREADY=1`; the failed data phase
   completes with an error.

An error is still a completion event. Local logic must retire the failed
operation once, record failure, and avoid treating read data as successful
payload.

## AHB versus AHB-Lite

AHB supports systems with multiple managers through interconnect arbitration
and routing. AHB-Lite is the single-manager subset and is the right first
implementation for learning the transfer pipeline. “Lite” does not mean
single transfer only; bursts and wait states remain valid.

AHB is also different from AXI. It has one shared address/data pipeline and no
AXI-style transaction IDs or five independent channel handshakes.

## RTL and verification invariants

A manager or monitor should make these properties explicit:

- after accepting a local command, capture every field needed after that edge;
- advance address and beat state only for accepted NONSEQ/SEQ phases;
- hold the outstanding data-phase identity until `HREADY=1`;
- associate `HWDATA` with the older accepted write address;
- sample `HRDATA` and `HRESP` only at the data completion edge;
- keep normal bus outputs stable through an `HREADY=0` wait;
- treat BUSY and IDLE as non-beats;
- check fixed-burst length, alignment, wrap address sequence, and the 1-KiB
  rule; and
- verify both cycles of ERROR, not only the final `HREADY=1` cycle.

The included testbench covers SINGLE, INCR4, WRAP4, reads, writes, inserted
wait states, bus stability, and unaligned-request rejection. Injecting a
two-cycle ERROR response is the most important remaining negative test.

## Deliberate implementation limits

- one manager and one command in flight;
- 32-bit word transfers only;
- SINGLE, INCR4, and WRAP4 only;
- no undefined INCR, INCR8/16, WRAP8/16, byte, or halfword support;
- no exclusive, atomic, parity, user, security, or extended memory attributes.

These are implementation limits, not protocol limits.

## Recall checkpoint

1. Why can `HADDR=B` and `HWDATA=A` be correct in the same cycle?
2. Which event creates a real data phase?
3. Which event completes that data phase?
4. Why does a normal wait freeze both data context and the next valid address?
5. Why is an AHB ERROR response two cycles?
6. Derive the WRAP4 word boundary without memorizing 16.
7. What remains in AHB-Lite after arbitration is removed?
