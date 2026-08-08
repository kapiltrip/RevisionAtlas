# 02 — AMBA APB

[Back to AMBA](../README.md) | [Back to Protocols](../../README.md)

APB is AMBA's simple, synchronous peripheral interface. A transfer is not
pipelined: one request spends exactly one cycle in **SETUP**, then one or more
cycles in **ACCESS**. This predictable structure fits memory-mapped control and
status registers in UARTs, timers, GPIO, interrupt controllers, and similar
peripherals.

## Open this chapter

- [APB notes](../notes/APB.md) — every APB source
  page, waveform, correction, bridge explanation, and recall prompt.
- [Arm IHI 0024E specification](sources/ARM-IHI-0024E-AMBA-APB-Protocol-Specification.pdf)
  — APB3, APB4, and APB5 authority.

## The phase contract

```text
IDLE -> SETUP -> ACCESS
                  |
          PREADY=0: remain ACCESS
          PREADY=1: finish, then IDLE or next SETUP
```

- **SETUP:** `PSELx=1`, `PENABLE=0`. It always lasts one clock cycle.
- **ACCESS:** `PSELx=1`, `PENABLE=1`. It lasts until an ending rising edge with
  `PREADY=1`.
- **Back-to-back:** the next transfer still receives its own SETUP interval.
  There is never ACCESS → ACCESS for two different transfers.

The minimum access therefore takes two clock cycles. `PREADY=1` during IDLE or
SETUP does not complete anything.

## Signal ownership

The **requester** drives:

- `PADDR`, `PWRITE`, and one decoded `PSELx`;
- `PENABLE` to identify ACCESS;
- `PWDATA` for writes;
- optional `PSTRB`, `PPROT`, and request/data user attributes.

The **completer** drives:

- `PREADY` to finish or extend ACCESS;
- `PRDATA` for a read;
- optional `PSLVERR` and response user attributes.

Clock and reset are `PCLK` and active-LOW `PRESETn`.

## Completion events

Define:

$$
\text{apb\_complete}
= \texttt{PSEL}\land\texttt{PENABLE}\land\texttt{PREADY}
$$

Then:

$$
\text{write\_accept}
= \text{apb\_complete}\land\texttt{PWRITE}
$$

$$
\text{read\_accept}
= \text{apb\_complete}\land\lnot\texttt{PWRITE}
$$

`PWDATA` is consumed only on `write_accept`. `PRDATA` is sampled only on
`read_accept`. `PSLVERR` is meaningful only on the same final completion edge.
Completion and success are separate: `PREADY=1` ends the transfer, while
`PSLVERR=1` says it ended with an error.

## Wait-state stability

During ACCESS with `PREADY=0`, the requester retains the same transaction:

- `PADDR`, `PWRITE`, `PSELx`, and `PENABLE`;
- `PWDATA` and `PSTRB` for a write;
- `PPROT` and applicable request/write user attributes.

The completer owns `PRDATA` and can let it settle during a waited read; it must
be valid at the final read-completion edge. Saying “every APB signal must
remain stable” is therefore too broad—request fields hold, while response
fields become valid according to completion rules.

## Back-to-back accesses

After a completed ACCESS:

- no next request → deassert `PSELx` and return to IDLE;
- next request to the same peripheral → `PSELx` may stay HIGH, but
  `PENABLE` must go LOW for the new SETUP;
- next request to a different peripheral → change the one-hot selection in
  the new SETUP and keep `PENABLE=0`.

Address, direction, and data for the next transfer must not replace the current
request before its completion edge.

## APB version ladder

- **APB2:** base two-phase interface without `PREADY` or `PSLVERR`; completion
  is fixed after ACCESS begins.
- **APB3:** adds wait states through `PREADY` and error reporting through
  `PSLVERR`.
- **APB4:** adds optional `PSTRB` for byte-lane writes and `PPROT` for
  protection attributes.
- **APB5:** adds optional wake-up, user signaling, interface parity/check
  signals, and later optional RME support.

The SETUP/ACCESS model remains the foundation across these versions. For an
initial RTL project, APB3 signals are enough to learn variable latency and
errors; add APB4 byte strobes when register writes need per-byte enables.

## Why a bridge needs storage

An AHB-to-APB or AXI-to-APB bridge is a protocol converter:

1. accept and save the upstream address, direction, attributes, and write data;
2. decode the APB peripheral and drive one SETUP cycle;
3. drive ACCESS and hold the saved request while `PREADY=0`;
4. capture `PRDATA` or `PSLVERR` at completion; and
5. generate the appropriate upstream completion or error response.

APB takes at least two cycles and has no burst pipeline. The bridge therefore
cannot simply connect same-purpose wires or assume the upstream request remains
visible.

## RTL and verification invariants

- SETUP lasts exactly one cycle and always transitions to ACCESS.
- ACCESS alone may repeat.
- request fields do not change from SETUP through completion.
- completion pulses once, even after many wait cycles.
- `PRDATA` is captured only for a completed read.
- `PSLVERR` is sampled only with `PSEL && PENABLE && PREADY`.
- two back-to-back accesses always contain a SETUP interval.
- `PSTRB` must be zero on reads and remain stable through a waited write when
  APB4 strobes are implemented.

Useful assertions include:

```systemverilog
// ACCESS cannot appear without a selected peripheral.
PENABLE |-> PSEL;

// A waited ACCESS retains the request.
PSEL && PENABLE && !PREADY |=> $stable({
    PADDR, PWRITE, PSEL, PENABLE, PWDATA, PSTRB, PPROT
});
```

Adapt optional signals to the implemented APB version.

## Recall checkpoint

1. Why can APB never complete in SETUP?
2. Which signals identify SETUP and ACCESS?
3. What holds during a waited write, and why is `PRDATA` different?
4. When is `PSLVERR` meaningful?
5. What waveform separates two back-to-back accesses?
6. What did APB3 and APB4 add?
7. Why must an AHB-to-APB bridge buffer request context?
