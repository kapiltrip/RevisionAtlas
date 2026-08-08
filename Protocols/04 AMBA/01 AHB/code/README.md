# AHB-Lite Manager Code Guide

[Back to AHB](../README.md) | [FSM correction](FSM.md)

This code is a teaching implementation of the two-lane AHB pipeline. The
state machine says whether one local command is active; separate registers say
which beat occupies the address phase and which older beat occupies the data
phase.

## Files

- [ahb_lite_manager.v](rtl/ahb_lite_manager.v) — synthesizable Verilog-2001
  manager.
- [ahb_lite_manager_tb.v](tb/ahb_lite_manager_tb.v) — self-checking memory
  subordinate and test sequence.
- [FSM.md](FSM.md) — lecture FSM versus the corrected pipelined model.

## Supported contract

- 32-bit address and data buses;
- fixed 32-bit words, `HSIZE=3'b010`;
- SINGLE, INCR4, and WRAP4;
- reads and writes;
- one local command at a time;
- NONSEQ for the first beat and SEQ for later fixed-burst beats;
- normal wait-state holding when `HREADY=0`; and
- deterministic idle values instead of functional `X` assignments.

## Local command interface

The caller offers a command with `req_valid`. `req_ready` is HIGH only while
the manager is idle. A command is captured on:

$$
\text{req\_accept}=\texttt{req\_valid}\land\texttt{req\_ready}
$$

Captured fields are `req_write`, the small `req_burst` encoding, starting
`req_addr`, and four packed write words in `req_wdata`. The caller can change
those inputs after acceptance because the RTL stores them.

Directions below are relative to `ahb_lite_manager`:

| Signal | Direction | Width | Description |
|---|---|---:|---|
| `HCLK` | Input | 1 | AHB clock; protocol state is sampled on its rising edge. |
| `HRESETn` | Input | 1 | Active-LOW reset; asynchronously asserts in this implementation. |
| `req_valid` | Input | 1 | Offers one local command and its payload. |
| `req_ready` | Output | 1 | HIGH only when the module can accept a command. |
| `req_write` | Input | 1 | `1` selects a write; `0` selects a read. |
| `req_burst` | Input | 2 | Local SINGLE/INCR4/WRAP4 selection; it is not the AHB `HBURST` encoding. |
| `req_addr` | Input | 32 | Byte address of the first word beat; it must be word-aligned. |
| `req_wdata` | Input | 128 | Four packed 32-bit write beats, lowest beat first. |
| `done` | Output | 1 | One-cycle pulse when the command finishes or is rejected locally. |
| `error` | Output | 1 | One-cycle pulse for a rejected request or AHB ERROR response. |
| `rsp_rdata` | Output | 128 | Completed read beats packed in request order, lowest beat first. |

## AHB-Lite interface signals

Address/control outputs describe the offered address phase. `HWDATA` and the
three subordinate inputs describe the older data phase when the pipeline is
full.

| Signal | Direction | Width | Description |
|---|---|---:|---|
| `HADDR` | Output | 32 | Byte address for the current address phase. |
| `HBURST` | Output | 3 | Burst type: SINGLE, INCR4, or WRAP4 in this implementation. |
| `HMASTLOCK` | Output | 1 | Locked-sequence indicator; tied LOW here. |
| `HPROT` | Output | 4 | Protection attributes; fixed to privileged data, non-bufferable, non-cacheable. |
| `HSIZE` | Output | 3 | Bytes per beat encoding; fixed to `3'b010` for a 32-bit word. |
| `HTRANS` | Output | 2 | Transfer type: IDLE, NONSEQ, or SEQ in the supported paths. |
| `HWDATA` | Output | 32 | Write payload for the active data phase, one phase behind its address. |
| `HWRITE` | Output | 1 | Address-phase direction: `1` for write and `0` for read. |
| `HRDATA` | Input | 32 | Read payload returned for the active data phase. |
| `HREADY` | Input | 1 | Completes the current data phase and permits address/control to advance when HIGH. |
| `HRESP` | Input | 1 | Response for the active data phase: LOW for OKAY, HIGH for ERROR in AHB-Lite. |

`req_burst` is a local encoding, not `HBURST`:

- `2'b00` → SINGLE → `HBURST=3'b000`;
- `2'b01` → INCR4 → `HBURST=3'b011`;
- `2'b10` → WRAP4 → `HBURST=3'b010`;
- `2'b11` → rejected.

Completed read beats are packed into `rsp_rdata` in the same order. `done` is
a one-cycle pulse after final completion or local-request rejection. `error`
is a one-cycle pulse for rejection or an AHB ERROR response.

## Phase state

The important registers are:

- `state_q`: no command or one active command;
- `addr_index_q`: beat whose address/control is currently offered;
- `data_index_q`: older beat whose data phase is active;
- `data_valid_q`: an accepted address has created a data phase;
- `write_q`, `burst_q`, and `write_data_q`: command context that must survive
  later cycles and waits.

This separation permits the key legal condition:

```text
HADDR / HTRANS / controls -> beat N+1
HWDATA or HRDATA / HRESP  -> beat N
```

If one “current beat” register were used for both, either pipelining would be
lost or payload would be associated with the wrong address.

## Edge behavior

### 1. Capture

In IDLE, a valid aligned request is stored and beat 0 is presented as NONSEQ.
An unsupported burst or unaligned word address is rejected locally without
starting AHB.

### 2. Accept an address

In ACTIVE:

$$
\text{addr\_fire}=\texttt{HREADY}\land\texttt{HTRANS[1]}
$$

On `addr_fire`, the offered address becomes a real transfer and its index is
copied into `data_index_q`. If another burst beat remains, the next address is
generated and `HTRANS` becomes SEQ. Otherwise the address lane becomes IDLE,
but the accepted final beat still has a data phase to finish.

### 3. Retire data

If `data_valid_q && HREADY`, the older data phase completes. A read captures
`HRDATA`; an asserted `HRESP` reports error. The command finishes only after
the final outstanding data phase, which is one edge later than acceptance of
its final address.

### 4. Hold

When `HREADY=0` and `HRESP=0`, the sequential block changes none of the address,
control, index, or payload state. No counter advances and no result is sampled.

On the first ERROR cycle (`HRESP=1`, `HREADY=0`), the RTL is allowed to drive
`HTRANS=IDLE` to cancel the pipelined next access. It retires the failed data
phase on the final ERROR cycle where `HREADY=1`.

## Address generation

INCR4 adds four bytes per accepted beat.

For WRAP4 words:

$$
\text{boundary}=4\text{ beats}\times4\text{ bytes}=16\text{ bytes}
$$

The helper retains `current_address[31:4]` and increments the low nibble
modulo 16. Therefore `0x3C` advances to `0x30`, not `0x40`.

This helper is intentionally specialized. Supporting other sizes or burst
lengths requires deriving the step, wrap mask, and boundary from `HSIZE` and
`HBURST`.

## Fixed AHB outputs

- `HSIZE=3'b010`: 32-bit word.
- `HMASTLOCK=0`: no locked sequence.
- `HPROT=4'b0011`: privileged data access, non-bufferable, non-cacheable in
  this implementation.
- idle/data-invalid write output is zero rather than `X`.

These constants keep the learning scope deterministic. They do not describe
every legal AHB system.

## What the testbench proves

The subordinate model inserts one wait for selected addresses and stores
completed writes. The scoreboard checks:

- SINGLE write;
- INCR4 write and read;
- WRAP4 write and read from `0x3C`;
- exact wrapped memory locations;
- stability of bus outputs during normal waits; and
- local rejection of an unaligned word request.

It does not currently drive `HRESP=1`. Add a two-cycle ERROR stimulus before
calling the negative-response path fully verified.

## Run

From the repository root in PowerShell:

```powershell
iverilog -g2005-sv -Wall `
  -o tmp/ahb_lite_manager_tb.out `
  "Protocols/04 AMBA/01 AHB/code/rtl/ahb_lite_manager.v" `
  "Protocols/04 AMBA/01 AHB/code/tb/ahb_lite_manager_tb.v"

Push-Location tmp
vvp ahb_lite_manager_tb.out
Pop-Location
```

Expected result:

```text
PASS: SINGLE, INCR4, WRAP4, reads, writes, and wait states verified
```

The generated VCD is temporary waveform output.

## Deliberate limits

This is not a drop-in AHB5 IP block. The exact protocol and feature limits are
listed in the [AHB chapter README](../README.md#deliberate-implementation-limits).
Extend it only after the address/data overlap and wait behavior can be traced
edge by edge.
