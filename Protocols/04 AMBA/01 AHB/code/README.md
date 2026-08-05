# AHB-Lite Manager Code Guide

[Back to AHB](../README.md) | [FSM explanation](FSM.md)

## File structure

```text
code/
|-- README.md
|-- FSM.md
|-- rtl/
|   `-- ahb_lite_manager.v
`-- tb/
    `-- ahb_lite_manager_tb.v
```

## What the RTL implements

`ahb_lite_manager.v` is a compact Verilog-2001 teaching design with:

- a 32-bit address bus and 32-bit data bus;
- fixed 32-bit word transfers (`HSIZE=3'b010`);
- SINGLE, INCR4, and WRAP4 commands;
- both reads and writes;
- correct NONSEQ/SEQ generation;
- one address phase overlapped with the preceding data phase;
- complete holding behavior when `HREADY=0`;
- deterministic bus values instead of functional `X` assignments; and
- one command in flight at a time.

## Local request interface

The local request interface is deliberately smaller than a production DMA or
processor interface. It exists so the testbench can ask for one AHB operation
without mixing test intent into the bus protocol.

| Signal | Direction | Purpose |
|---|---|---|
| `req_valid` | input | Command fields are ready to be accepted |
| `req_ready` | output | Manager can accept a command in this clock cycle |
| `req_write` | input | `1` for write, `0` for read |
| `req_burst[1:0]` | input | `00` SINGLE, `01` INCR4, `10` WRAP4; `11` is rejected |
| `req_addr[31:0]` | input | Starting byte address |
| `req_wdata[127:0]` | input | Up to four packed write words; beat 0 occupies `[31:0]` |
| `rsp_rdata[127:0]` | output | Completed read words in the same beat order |
| `done` | output | One-cycle completion pulse |
| `error` | output | One-cycle invalid-request or bus-error pulse |

The request is accepted on a rising edge with `req_valid && req_ready`. The RTL
captures every request field, so the caller does not need to hold them after
that edge.

## AHB signal ownership

| Signal | Driver | Use in this design |
|---|---|---|
| `HADDR` | manager | Current byte address |
| `HTRANS` | manager | IDLE, first-beat NONSEQ, or later-beat SEQ |
| `HWRITE` | manager | Transfer direction captured from `req_write` |
| `HSIZE` | manager | Constant word size, `3'b010` |
| `HBURST` | manager | SINGLE `000`, WRAP4 `010`, or INCR4 `011` |
| `HPROT` | manager | Constant ordinary privileged data access attributes |
| `HMASTLOCK` | manager | Constant LOW; locked sequences are outside this version |
| `HWDATA` | manager | Write word for the current data phase |
| `HRDATA` | subordinate | Read word for the current data phase |
| `HREADY` | subordinate path | HIGH completes/advances; LOW extends and freezes |
| `HRESP` | subordinate | LOW for OKAY, HIGH for ERROR in AHB-Lite |

## Why a testbench is included

The testbench is not part of the synthesizable manager. It supplies the clock,
reset, commands, and a small subordinate memory so the manager has something to
communicate with. It also proves behavior rather than asking the learner to
judge a waveform by eye.

The checks cover:

- SINGLE write;
- INCR4 write and read;
- WRAP4 write and read from a nonzero offset;
- the exact wrapped memory locations;
- inserted `HREADY` wait states;
- bus stability across extended cycles; and
- rejection of an unaligned word request.

## Run it

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

The generated `tmp/ahb_lite_manager.vcd` is temporary waveform output and is
not part of the chapter source.

## Standard-practice choices made here

- Clocked storage uses nonblocking assignments.
- Request fields are captured once instead of read asynchronously throughout a transfer.
- Counters advance only when the bus handshake completes.
- Legal idle constants are driven instead of `X` values.
- Protocol encodings have named local parameters.
- Wrap arithmetic is based on the 16-byte WRAP4 word boundary.
- The testbench checks values automatically and still creates a VCD for visual study.
- RTL and verification code are kept in separate folders.

## Deliberate limits

This is not a drop-in commercial AHB5 manager. The reduced feature set is
listed in the [chapter README](../README.md#what-is-intentionally-not-in-this-first-version).
Extend it only after the current pipeline and wait-state behavior can be traced
without guessing.
