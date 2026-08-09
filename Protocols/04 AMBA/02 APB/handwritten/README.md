# APB Lecture and Handwritten Atlas

[Back to APB](../README.md) | [Back to AMBA](../../README.md)

This atlas follows each lecture waveform with its explanation and then the
corresponding original notebook or iPad page. The authority for corrections is
Arm's
[AMBA APB Protocol Specification, ARM IHI 0024E](../../../../_internal/Protocols/04%20AMBA/02%20APB/sources/ARM-IHI-0024E-AMBA-APB-Protocol-Specification.pdf).

## How to reason about an APB page

APB is easiest to understand as one retained request moving through protocol
states. The address, direction, and write information form a request packet.
SETUP presents that packet; ACCESS asks the selected peripheral to finish it.
If the peripheral is not ready, the same packet remains in ACCESS. There is no
AHB-style overlap in which a second address belongs to a different transfer.

For every waveform, answer these four questions:

| Question | APB answer |
|---|---|
| Which peripheral is involved? | The requester asserts that peripheral's `PSELx`. |
| Which phase is active? | `PENABLE=0` with `PSELx=1` means SETUP; `PENABLE=1` means ACCESS. |
| Is the access complete? | Only an ACCESS edge with `PREADY=1` completes it. |
| What must be retained while waiting? | Address, direction, select, enable, write payload, and applicable controls. |

All APB signals are interpreted at rising `PCLK` edges. `PREADY` is not a
free-standing valid signal; it has completion meaning only for the selected
transfer in ACCESS. This phase context is what turns a signal list into a
protocol
([Arm IHI 0024E, §§2.1, 3.1, and 4.1](../../../../_internal/Protocols/04%20AMBA/02%20APB/sources/ARM-IHI-0024E-AMBA-APB-Protocol-Specification.pdf)).

## Source-page map

| Notebook page | Main idea | Related capture |
|---:|---|---|
| 19 | APB overview and AHB-to-APB bridge | Bridge role |
| 20 | Core APB interface signals | Transfer phases |
| 21 | SETUP/ACCESS and write transfer | Write, no wait |
| 22 | Wait states and stability | Write, with waits |
| 23 | Read timing and `PSLVERR` | Read wait/error |
| 24 | Write wait states and controller FSM | State diagram |

The separate iPad APB page revisits the waited-write case after the notebook
sequence.

## 1. Why APB exists

### Lecture frame: a bridge reaches simple peripherals

![Lecture frame showing the APB bridge role](../../../../_internal/Protocols/04%20AMBA/02%20APB/images/lecture/apb-bridge-role.png)

The frame places APB behind a system-bus bridge. High-performance traffic can
remain on AHB or another AMBA system bus, while the bridge converts a selected
register access into APB's simpler SETUP/ACCESS sequence. The peripheral sees
only the APB transaction; it does not need to understand the pipelined AHB
transaction that caused it.

The bridge also absorbs the latency difference. If the APB completer holds
`PREADY=0`, the bridge keeps APB stable and delays completion on its upstream
interface.

Follow a single write through the bridge. The upstream bus first delivers an
address, direction, and payload. The bridge stores that information, decodes
which `PSELx` to assert, presents one SETUP cycle, and then enters ACCESS. If
the peripheral keeps `PREADY=0`, the bridge holds the request and delays the
upstream response. In the simple non-posted bridge shown, `PREADY=1` completes
APB and the bridge then reports the result upstream.

The storage step is essential. APB takes at least two cycles and is not
pipelined, so the bridge cannot rely on the upstream address remaining present
for the entire APB transfer. It acts as both a timing converter and a request
buffer. For a read it additionally captures `PRDATA`; for an error it maps
`PSLVERR` into the upstream protocol's response
([Arm IHI 0024E, §§1.1 and 3.4.3](../../../../_internal/Protocols/04%20AMBA/02%20APB/sources/ARM-IHI-0024E-AMBA-APB-Protocol-Specification.pdf)).

### Original notebook page 19: overview and bridge

![Original handwritten APB overview and bridge page](../../../../_internal/Protocols/04%20AMBA/02%20APB/handwritten/images/01-apb-overview-and-bridge.jpg)

The page correctly describes APB as low-bandwidth, low-complexity peripheral
communication and draws an AHB/APB bridge. The term “low power” is best
understood as an architectural goal enabled by a small, non-pipelined
interface—not as a promise that every APB implementation automatically
consumes little power.

The UART example is appropriate. A processor may read a UART status register
through the bridge; APB transports the register access, while the UART's serial
behavior remains internal to the peripheral.

The page's “simple interface” statement has a precise protocol meaning. APB
does not pipeline addresses, encode bursts, arbitrate between transfer types,
or provide separate handshakes for read and write data. Every access follows
one SETUP and one-or-more ACCESS cycles. That regularity reduces the state and
interface logic a register peripheral must implement
([Arm IHI 0024E, §1.1](../../../../_internal/Protocols/04%20AMBA/02%20APB/sources/ARM-IHI-0024E-AMBA-APB-Protocol-Specification.pdf)).

APB is optimized for programmable control/status registers. For a UART status
read, `PADDR` chooses the status register and `PWRITE=0` chooses read. During
ACCESS, the UART places that register value on `PRDATA` and asserts `PREADY`
when it can be sampled. For a transmit-data write, `PWRITE=1` and `PWDATA`
carry the new value; the UART accepts it only on the final ACCESS edge.

“Low bandwidth” is therefore an architectural fit, not a statement that APB
cannot move useful data. A control register is accessed occasionally, so the
extra SETUP cycle costs little compared with the area and verification savings
of a predictable interface. The serial bit timing of the UART is unrelated to
the APB transfer; APB only accesses the UART's memory-mapped registers.

## 2. The phase contract

### Original notebook page 20: signals as one transaction

![Original handwritten APB interface signals](../../../../_internal/Protocols/04%20AMBA/02%20APB/handwritten/images/02-apb-interface-signals.jpg)

Read the listed signals in the order of an access. The requester first asserts
the target's `PSEL`, drives `PADDR`, selects read/write with `PWRITE`, and drives
`PWDATA` for a write. In the next cycle it asserts `PENABLE`. The completer uses
`PREADY` to say when ACCESS can finish, supplies `PRDATA` for a read, and may
assert `PSLVERR` for an error.

`PENABLE` is not a separator that switches the bus from “address” to “data.”
Address, direction, select, and write data are already valid in SETUP and stay
valid through ACCESS completion. `PENABLE` identifies that the transfer has
moved from SETUP into ACCESS
([Arm IHI 0024E, Chapter 3](../../../../_internal/Protocols/04%20AMBA/02%20APB/sources/ARM-IHI-0024E-AMBA-APB-Protocol-Specification.pdf)).

The page's signal names become clearer when grouped by ownership and purpose:

| Owner | Signal group | Meaning for this page |
|---|---|---|
| Requester/bridge | `PADDR`, `PWRITE`, `PSELx`, `PENABLE` | Which register, read or write, which peripheral, and current phase |
| Requester/bridge | `PWDATA`, optional `PSTRB` | Write payload and valid byte lanes |
| Completer/peripheral | `PREADY` | Whether the current ACCESS can finish |
| Completer/peripheral | `PRDATA` | Read result, required by the final read ACCESS edge |
| Completer/peripheral | optional `PSLVERR` | Error result, meaningful only at final completion |

`PADDR` is a byte address. The protocol permits an unaligned value to appear,
but its result is UNPREDICTABLE, so a requester should generate addresses
aligned for the intended register/data access. `PWDATA` and `PRDATA` are
separate physical buses, but read and write transfers cannot occur
concurrently because they share one `PSEL`/`PENABLE`/`PREADY` transfer state
([Arm IHI 0024E, §§2.1.1-2.1.2](../../../../_internal/Protocols/04%20AMBA/02%20APB/sources/ARM-IHI-0024E-AMBA-APB-Protocol-Specification.pdf)).

Read the phase values as a state table rather than independent enables:

| State | `PSELx` | `PENABLE` | Can `PREADY` complete a transfer? |
|---|---:|---:|---|
| IDLE | `0` | `0` | No |
| SETUP | `1` | `0` | No; the mandatory first cycle is being presented |
| ACCESS | `1` | `1` | Yes, if `PREADY=1` at the rising edge |

### Lecture frame: write with no wait state

![Lecture waveform for an APB write without wait states](../../../../_internal/Protocols/04%20AMBA/02%20APB/images/lecture/apb-write-no-wait.png)

At the first rising edge, the requester enters SETUP: `PSEL=1`, `PENABLE=0`,
and address/write data are valid. At the next rising edge it enters ACCESS by
asserting `PENABLE`. Because `PREADY=1`, that first ACCESS cycle is also the
final cycle. The completer accepts the write at its ending edge.

The minimum access is therefore two cycles. `PREADY` being HIGH early does not
remove the mandatory SETUP phase.

Trace the waveform by intervals between rising edges:

| Interval | Requester outputs | Meaning at the ending edge |
|---|---|---|
| IDLE to SETUP | Assert `PSEL`, drive address, `PWRITE=1`, and write data; keep `PENABLE=0` | Request packet is presented in SETUP |
| SETUP to ACCESS | Keep the packet unchanged and assert `PENABLE=1` | Peripheral is now in ACCESS |
| First ACCESS | `PREADY=1` | Write is accepted and the transfer completes |
| Following interval | Deassert `PENABLE`; deassert `PSEL` or present the next SETUP | Bus returns to IDLE or starts another access |

The data is not accepted merely when it becomes visible in SETUP. SETUP gives
the peripheral a full cycle to decode the address and direction. ACCESS is the
phase in which readiness is sampled. This is why a permanently ready
peripheral can tie `PREADY` HIGH yet still takes the mandatory two-cycle
sequence
([Arm IHI 0024E, §3.1.1](../../../../_internal/Protocols/04%20AMBA/02%20APB/sources/ARM-IHI-0024E-AMBA-APB-Protocol-Specification.pdf)).

### Original notebook page 21: SETUP then ACCESS

![Original handwritten APB transfer phases](../../../../_internal/Protocols/04%20AMBA/02%20APB/handwritten/images/03-apb-transfer-phases.jpg)

The page's phase split is correct. `PSEL=1, PENABLE=0` identifies SETUP, and
`PSEL=1, PENABLE=1` identifies ACCESS. The write data is not newly introduced
only in ACCESS; it must be valid from SETUP and remain stable until the write
completes.

For back-to-back transfers, the controller leaves ACCESS and enters SETUP for
the next access. It may keep `PSEL` HIGH if the same peripheral remains
selected, but it must deassert `PENABLE` for that intervening SETUP cycle.

The phrase “address phase and data phase” in handwritten APB notes can be
misleading if it suggests AHB-style overlap. APB SETUP and ACCESS belong to the
same request, and the address plus write data remain visible in both. The phase
change is indicated by `PENABLE`; the payload does not move onto a different
handshake channel.

For two back-to-back writes to the same UART, the sequence is:

```text
SETUP(A) -> ACCESS(A, done) -> SETUP(B) -> ACCESS(B, done)
```

`PSEL` can remain HIGH across the boundary because the UART remains selected,
but `PENABLE` goes LOW for `SETUP(B)`, and B's address/data replace A only after
A has completed. For a different peripheral, the requester also changes which
`PSELx` is asserted during the new SETUP
([Arm IHI 0024E, §§3.1.1 and 4.1](../../../../_internal/Protocols/04%20AMBA/02%20APB/sources/ARM-IHI-0024E-AMBA-APB-Protocol-Specification.pdf)).

## 3. Wait states mean “hold ACCESS”

### Lecture frame: write with wait states

![Lecture waveform for an APB write with wait states](../../../../_internal/Protocols/04%20AMBA/02%20APB/images/lecture/apb-write-wait-states.png)

This waveform starts exactly like the no-wait write. The difference occurs
after `PENABLE` rises: `PREADY=0` keeps the controller in ACCESS. `PSEL` and
`PENABLE` stay HIGH, while address, direction, write data, and applicable
control signals remain unchanged. The write completes at the ACCESS edge where
`PREADY` finally becomes HIGH.

Wait cycles do not create extra transfers and the controller does not return to
SETUP between them.

The LOW-ready cycles are repeated sampling opportunities for the same
unfinished access, not new writes. The peripheral must arrange its internal
write enable so the register update occurs once at completion, for example on
`PSEL && PENABLE && PREADY && PWRITE`. Updating on every cycle with
`PENABLE=1` would write the same register multiple times during a wait and can
break side-effect registers such as FIFO push ports.

`PREADY` can have any value outside ACCESS. Therefore a waveform that shows it
HIGH in IDLE or SETUP is not promising early completion. Only the combination
of selected ACCESS plus ready has protocol meaning
([Arm IHI 0024E, §3.1.2](../../../../_internal/Protocols/04%20AMBA/02%20APB/sources/ARM-IHI-0024E-AMBA-APB-Protocol-Specification.pdf)).

### Original notebook page 22: stability through waits

![Original handwritten APB wait-state page](../../../../_internal/Protocols/04%20AMBA/02%20APB/handwritten/images/04-apb-wait-states-and-stability.jpg)

The page correctly states that a LOW `PREADY` extends the data/access phase.
Make the stability rule precise: during all extended ACCESS cycles, the
requester holds `PADDR`, `PWRITE`, `PSEL`, `PENABLE`, `PWDATA`, and the other
request controls stable. This lets a slow peripheral take as many cycles as it
needs without seeing a changing request.

The completer is allowed to take zero or more wait cycles. “Zero wait” means
`PREADY` is HIGH in the first ACCESS cycle, not that the two-phase protocol has
been reduced to one cycle.

For the write shown on this page, the exact retained request is broader than
just address and data. Arm requires these requester outputs to remain unchanged
through an extended ACCESS: `PADDR`, `PWRITE`, `PSELx`, `PENABLE`, `PWDATA`,
and, when implemented, `PSTRB`, `PPROT`, `PAUSER`, and `PWUSER`. The peripheral
can therefore decode once and finish later without defending itself against a
moving request
([Arm IHI 0024E, §3.1.2](../../../../_internal/Protocols/04%20AMBA/02%20APB/sources/ARM-IHI-0024E-AMBA-APB-Protocol-Specification.pdf)).

The hardware mechanism is a request register in the bridge/controller. Capture
the local address, direction, payload, and attributes before or on entry to
SETUP. Drive APB from those registers until completion. A local producer must
not overwrite them while the APB controller is in ACCESS; expose a busy or
ready handshake on the local side to prevent that overwrite.

The number of wait cycles can be zero or greater. Functionally, the controller
does not need to predict the count: it remains in ACCESS while `PREADY=0` and
exits on the first rising edge with `PREADY=1`. A timeout, if a system chooses
to add one, is an external design policy and not part of this page's APB
handshake.

### iPad page: annotated waited write

![Annotated iPad page for an APB write wait state](../../../../_internal/Protocols/04%20AMBA/02%20APB/handwritten/images/ipad-01-apb-write-wait-state.jpg)

The iPad annotation says `PREADY=0` holds the data phase and the requester does
not sample/complete. That is the right operational model. Add one detail:
APB calls this the ACCESS phase, and both request and write data are held. The
write is accepted only at the final edge where `PSEL`, `PENABLE`, and `PREADY`
are all HIGH.

The annotation can be converted into one completion expression:

```verilog
write_complete = PSEL && PENABLE && PREADY && PWRITE;
```

While `PREADY=0`, `write_complete` is false even though all request information
is visible. The state remains ACCESS, the request registers retain the same
values, and the peripheral has not yet signaled acceptance. When `PREADY`
rises, completion occurs once and the next clock interval must be IDLE or a new
SETUP, never a continuation of the completed ACCESS.

The word “sample” should be assigned to the right side. The completer accepts
`PWDATA` on the final write edge; the requester samples `PREADY` and optional
`PSLVERR` on that edge. Both are observing the same completion event from
opposite sides of the interface
([Arm IHI 0024E, §§3.1.2 and 3.4](../../../../_internal/Protocols/04%20AMBA/02%20APB/sources/ARM-IHI-0024E-AMBA-APB-Protocol-Specification.pdf)).

## 4. Read timing

### Lecture frame: read with no wait state

![Lecture waveform for an APB read without wait states](../../../../_internal/Protocols/04%20AMBA/02%20APB/images/lecture/apb-read-no-wait.png)

A read uses the same phase sequence as a write, with `PWRITE=0`. The requester
drives the address in SETUP. The completer supplies `PRDATA` so that it is valid
by the ending edge of the final ACCESS cycle. The requester samples it only
when `PREADY=1` completes the transfer.

The read packet consists of `PADDR`, `PWRITE=0`, the selected `PSELx`, and any
request attributes. The requester holds that packet from SETUP through
completion. The peripheral decodes the address and drives the corresponding
register value onto `PRDATA`. A no-wait peripheral guarantees the value by the
end of the first ACCESS cycle
([Arm IHI 0024E, §3.3.1](../../../../_internal/Protocols/04%20AMBA/02%20APB/sources/ARM-IHI-0024E-AMBA-APB-Protocol-Specification.pdf)).

Unlike a write, the requester does not drive a payload to be consumed. It
captures `PRDATA` into a local result register only on the completion edge. A
combinational value seen in SETUP is not yet a completed read result.

### Lecture frame: read with wait states

![Lecture waveform for an APB read with wait states](../../../../_internal/Protocols/04%20AMBA/02%20APB/images/lecture/apb-read-wait-states.png)

The request side stays stable while `PREADY=0`. Unlike requester-owned address
and control, `PRDATA` is a completer output and can settle during the wait; it
must be valid at the final completion edge. A requester must not consume an
earlier provisional value.

For an extended read, the requester-owned signals `PADDR`, `PWRITE`, `PSEL`,
`PENABLE`, `PPROT`, and `PAUSER` remain unchanged. `PRDATA` is not in that hold
list because the completer owns it and may still be calculating or fetching the
result. It only has to be valid by the final ACCESS edge
([Arm IHI 0024E, §3.3.2](../../../../_internal/Protocols/04%20AMBA/02%20APB/sources/ARM-IHI-0024E-AMBA-APB-Protocol-Specification.pdf)).

This asymmetry is the reason “all bus signals must stay stable” is too broad.
The request must stay stable so its identity cannot change. The response may
settle until the completer declares it ready. Verification should check stable
request fields during waits and sample response fields only at completion.

### Original notebook page 23: read completion and error context

![Original handwritten APB read, wait, and error page](../../../../_internal/Protocols/04%20AMBA/02%20APB/handwritten/images/05-apb-read-wait-and-errors.jpg)

The page correctly separates read data from readiness. `PRDATA` provides the
value, while `PREADY` says when that value can be accepted. If the read is
extended, address and request controls are stable through every wait cycle.

The notes also introduce `PSLVERR`. It is not a general level that should be
sampled continuously. It is valid only in the final ACCESS cycle, alongside
`PSEL=1`, `PENABLE=1`, and `PREADY=1`. Outside that cycle the specification
recommends driving it LOW.

The read event on this page can be expressed as
`PSEL && PENABLE && PREADY && !PWRITE`. On that edge the requester captures
both `PRDATA` and the status of `PSLVERR`. If there were two preceding wait
cycles, they are still part of this one read; they do not produce two earlier
read-valid pulses.

If `PSLVERR=1`, the protocol says the returned read data can be invalid. The
requester therefore cannot assume the payload is usable merely because the
transfer completed. The specification notes that a requester might still use
the value, so a completer cannot rely on the error signal to hide sensitive or
unsafe data; robust system logic treats error status and data together
([Arm IHI 0024E, §§3.3 and 3.4](../../../../_internal/Protocols/04%20AMBA/02%20APB/sources/ARM-IHI-0024E-AMBA-APB-Protocol-Specification.pdf)).

This distinction is important: `PREADY=1` means the protocol operation is over,
while `PSLVERR=1` says it ended unsuccessfully. Completion and success are two
different properties of the same final edge.

## 5. Error timing

### Lecture frame: write error

![Lecture waveform for an APB write error](../../../../_internal/Protocols/04%20AMBA/02%20APB/images/lecture/apb-write-error.png)

The write follows normal SETUP and ACCESS timing. `PSLVERR` is asserted only
when the final ACCESS edge completes the write. A wait-state cycle cannot be a
completed error response because `PREADY=0` says the transfer has not finished.

An errored write still completes the APB transfer. The bridge/controller can
retire the request and report failure upstream, but software must not infer that
the target register definitely remained unchanged. Arm explicitly allows the
peripheral either to have changed state or not; that behavior is
peripheral-specific. Error means “the requested operation did not complete
normally,” not “the write was certainly rolled back”
([Arm IHI 0024E, §§3.4 and 3.4.1](../../../../_internal/Protocols/04%20AMBA/02%20APB/sources/ARM-IHI-0024E-AMBA-APB-Protocol-Specification.pdf)).

### Lecture frame: read error

![Lecture waveform for an APB read error](../../../../_internal/Protocols/04%20AMBA/02%20APB/images/lecture/apb-read-error.png)

The same timing rule applies to a read. Although a value may be visible on
`PRDATA`, the requester cannot assume data from an errored access is valid
payload. The error and completion handshake are interpreted together. The
protocol does not require the peripheral to drive zero on a read error.

This is the concise validity condition:

$$
\texttt{PSLVERR valid}\iff
\texttt{PSEL}\land\texttt{PENABLE}\land\texttt{PREADY}.
$$

`PSLVERR=0` at that edge means a normal completion; `PSLVERR=1` means an error
completion ([Arm IHI 0024E, §3.4](../../../../_internal/Protocols/04%20AMBA/02%20APB/sources/ARM-IHI-0024E-AMBA-APB-Protocol-Specification.pdf)).

For a bridge, error translation preserves the result across protocols. An APB
`PSLVERR` maps to AHB `HRESP` for either read or write; an AXI bridge maps it to
the appropriate read or write response. The phase timing changes, but the fact
that the peripheral reported failure must not be lost
([Arm IHI 0024E, §3.4.3](../../../../_internal/Protocols/04%20AMBA/02%20APB/sources/ARM-IHI-0024E-AMBA-APB-Protocol-Specification.pdf)).

## 6. Controller state machine

### Lecture frame: IDLE, SETUP, and ACCESS

![Lecture state diagram for APB operation](../../../../_internal/Protocols/04%20AMBA/02%20APB/images/lecture/apb-operating-states.png)

The state diagram is a direct encoding of the protocol:

- **IDLE:** no transfer is active; `PSEL=0`.
- **SETUP:** one mandatory cycle; `PSEL=1`, `PENABLE=0`.
- **ACCESS:** `PSEL=1`, `PENABLE=1`; remain here while `PREADY=0`.

When ACCESS completes, go to IDLE if no request is pending or SETUP if another
request is pending. Never transition directly from one ACCESS transfer into the
ACCESS phase of the next transfer.

The outputs follow directly from state plus the saved request:

| State | Output behavior | Exit condition |
|---|---|---|
| IDLE | No `PSELx`; `PENABLE=0` | A new local request is captured |
| SETUP | Selected `PSELx=1`; `PENABLE=0`; saved request is driven | Always go to ACCESS on the next rising edge |
| ACCESS | Keep `PSELx=1`; set `PENABLE=1`; keep request stable | Stay if `PREADY=0`; leave if `PREADY=1` |

SETUP is not optional and cannot loop. ACCESS is the only state that can loop,
because only the peripheral knows how many wait cycles it needs. This state
structure is the official behavior, not merely one possible lecture coding
style ([Arm IHI 0024E, §4.1](../../../../_internal/Protocols/04%20AMBA/02%20APB/sources/ARM-IHI-0024E-AMBA-APB-Protocol-Specification.pdf)).

### Original notebook page 24: waited write and FSM draft

![Original handwritten APB write wait-state and FSM page](../../../../_internal/Protocols/04%20AMBA/02%20APB/handwritten/images/06-apb-write-wait-and-fsm.jpg)

The upper timing notes correctly hold `PENABLE` HIGH while `PREADY` is LOW.
The lower circles are the beginning of the three-state controller. The clean
transition conditions are:

```text
IDLE   --request--> SETUP
SETUP  ----------> ACCESS
ACCESS --!PREADY-> ACCESS
ACCESS --PREADY and next request--> SETUP
ACCESS --PREADY and no request----> IDLE
```

Outputs should come from the protocol state and registered request, not from an
unqualified combinational request that might change during a wait. Registering
the request before SETUP makes the required ACCESS stability straightforward.

The handwritten FSM should therefore be paired with a request register. In
IDLE, capture the local address, direction, write data, and target select. In
SETUP and ACCESS, drive APB from that saved packet. While ACCESS waits, the FSM
and packet both hold. On completion, capture `PRDATA` for a read and
`PSLVERR` for status before deciding whether the next state is IDLE or SETUP.

For a pending second request, “ACCESS to SETUP” means the current transfer
finishes at the edge and the following interval presents the next request with
`PENABLE=0`. It does not mean `PENABLE` remains HIGH and the next access starts
without setup. The controller may keep the same `PSELx` asserted for the same
peripheral, but all request fields for the next access take effect only as that
new SETUP packet.

A minimal RTL write-enable set is:

```text
capture_request = state == IDLE && local_request
complete        = state == ACCESS && PREADY
capture_read    = complete && !PWRITE
capture_error   = complete && PSLVERR
```

These enables connect the page's circles to observable protocol events and
prevent counters or result registers from updating repeatedly during waits
([Arm IHI 0024E, §4.1](../../../../_internal/Protocols/04%20AMBA/02%20APB/sources/ARM-IHI-0024E-AMBA-APB-Protocol-Specification.pdf)).

## AHB versus APB after reading both notebooks

| Question | AHB | APB |
|---|---|---|
| Can phases overlap? | Yes. Next address can overlap current data. | No. SETUP then ACCESS for each transfer. |
| Completion signal | `HREADY` completes the current data phase. | `PREADY` completes only an ACCESS phase. |
| Wait behavior | Holds the current data phase and normally the pipelined next address. | Holds the one request in ACCESS. |
| Burst description | `HTRANS`, `HBURST`, and `HSIZE`. | No burst protocol in core APB. |
| Error response | `HRESP`. | Optional `PSLVERR`, valid only at final ACCESS. |
| Request identity during a wait | Older data phase plus normally held next address phase | One saved request remains in ACCESS |
| Back-to-back traffic | Pipeline can complete one beat and accept the next address on one edge | Every next access still receives a SETUP interval |
| Meaning of ready | Advances the pipelined bus and completes the older data phase | Completes only the selected ACCESS transfer |

## Corrections worth memorizing

- SETUP is always exactly one cycle; ACCESS is one or more cycles.
- `PENABLE` indicates ACCESS. It does not replace address with data.
- The requester holds address, control, and write data stable during waits.
- `PREADY` matters for completion only during ACCESS.
- `PSLVERR` is meaningful only on the final ACCESS cycle.
- Back-to-back transfers still require a SETUP cycle between ACCESS cycles.

## Active-recall pass

1. Draw a no-wait write and mark the exact accepting edge.
2. Extend it by two wait cycles without changing any requester-owned signal.
3. Explain why `PREADY=1` in SETUP does not complete a transfer.
4. Show the transition after a completed ACCESS when another request is ready.
5. Explain why `PRDATA` can settle during a wait but `PADDR` cannot change.

## Lecture source register

| Topic | Lecture |
|---|---|
| APB purpose and interface | [APB lecture 1](https://www.youtube.com/watch?v=MIjXS7ap0Hk&list=PLqPfWwayuBvPpjwnJsJ7qSQAXh7NQFMzO) |
| Read/write transfers and waits | [APB lecture 2](https://www.youtube.com/watch?v=MThzJkZeVDI&list=PLqPfWwayuBvPpjwnJsJ7qSQAXh7NQFMzO) |
| `PSLVERR` | [APB lecture 3](https://www.youtube.com/watch?v=q3jmUDlo94I&list=PLqPfWwayuBvPpjwnJsJ7qSQAXh7NQFMzO) |
| State machine and RTL | [APB lecture 4](https://www.youtube.com/watch?v=WFYG1ST5pko&list=PLqPfWwayuBvPpjwnJsJ7qSQAXh7NQFMzO&index=4) |
