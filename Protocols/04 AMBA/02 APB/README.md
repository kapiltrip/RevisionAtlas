# 02 - AMBA APB

[Back to AMBA](../README.md) | [Back to Protocols](../../README.md)

APB, the Advanced Peripheral Bus, is the AMBA interface for simple,
low-bandwidth register accesses. Its transfer is deliberately not pipelined:
each access has one SETUP cycle followed by one or more ACCESS cycles. That
predictable timing makes APB suitable for peripheral registers, timers, UARTs,
GPIO, and control/status blocks.

## Chapter map

| Part | Purpose |
|---|---|
| [Lecture and handwritten atlas](handwritten/README.md) | Every lecture frame followed by the related original notebook page, explanation, and corrections |
| [Official Arm specification](../../../_internal/Protocols/04%20AMBA/02%20APB/sources/ARM-IHI-0024E-AMBA-APB-Protocol-Specification.pdf) | Local ARM IHI 0024E source of truth |

## Core terms in transaction order

The definitions below are checked against the
[AMBA APB Protocol Specification, ARM IHI 0024E](https://documentation-service.arm.com/static/63fe2c1356ea36189d4e79f3).

| Term | Meaning in one APB access | Hardware consequence |
|---|---|---|
| **Requester** | The interface component that starts an APB transfer. Older material calls it the master. | It drives address, direction, select, enable, and write data/control. |
| **Completer** | The selected peripheral interface. Older material calls it the slave. | It drives readiness, read data, and the optional error response. |
| **SETUP** | Exactly one cycle with `PSEL=1` and `PENABLE=0`. Address, direction, and write/control information become valid. | This cycle is mandatory, including between back-to-back accesses. |
| **ACCESS** | The following cycle(s), identified by `PSEL=1` and `PENABLE=1`. | The transfer completes only at an ACCESS rising edge with `PREADY=1`. |
| **Wait state** | An ACCESS cycle in which `PREADY=0`. | The requester holds address, direction, select, enable, and write/control information stable. |
| **`PSLVERR`** | Optional error indication from the completer. | It is meaningful only in the final ACCESS cycle, when `PSEL`, `PENABLE`, and `PREADY` are all HIGH. |

## The central timing rule

Every APB transfer follows this state sequence:

```text
IDLE -> SETUP -> ACCESS
                  |  |
          PREADY=0|  |PREADY=1
                  v  v
               ACCESS -> IDLE or next SETUP
```

The minimum transfer therefore takes two clock cycles. LOW `PREADY` does not
restart SETUP; it extends ACCESS. During that extension, the request remains
unchanged. After completion, a next transfer still receives its own SETUP
cycle, although `PSEL` may remain asserted when the next access targets the
same peripheral.

## Read and write at the completion edge

- For a write, the completer accepts `PWDATA` at the final ACCESS edge.
- For a read, the requester samples `PRDATA` at the final ACCESS edge.
- `PREADY` is only used to complete a transfer during ACCESS. Its value during
  IDLE or SETUP does not complete an access.
- If `PSLVERR=1` at that final edge, the access reports an error. Read data from
  an errored transfer must not be treated as valid application data.

APB has no AHB-style address/data overlap, `HTRANS`, or burst beat sequence.
An AHB-to-APB bridge can accept a system-bus transaction and generate one APB
access, but each side continues to obey its own protocol.

## Scope of these notes

The handwritten material focuses on the core APB transfer signals and the
IDLE/SETUP/ACCESS state machine. APB4 additions such as `PSTRB` and `PPROT`, and
newer optional user/parity signals in the current specification, are useful
extensions but are not required to understand the captured waveforms.

## Source register

| Source | Use |
|---|---|
| [Arm IHI 0024E - AMBA APB Protocol Specification](../../../_internal/Protocols/04%20AMBA/02%20APB/sources/ARM-IHI-0024E-AMBA-APB-Protocol-Specification.pdf) | Authority for phase timing, stability, readiness, error timing, and the state diagram |
| [APB playlist](https://www.youtube.com/playlist?list=PLqPfWwayuBvPpjwnJsJ7qSQAXh7NQFMzO) | Teaching order and captured waveform examples |
| [Original handwritten source PDFs](../Handwritten%20data/) | Preserved notebook and iPad source pages |

## Completion checkpoint

1. Why can APB never complete a transfer in the SETUP cycle?
2. What must remain stable when `PREADY=0`?
3. When is `PSLVERR` meaningful?
4. What phase must occur between two back-to-back accesses?
5. Why is `PENABLE` better understood as a phase indicator than as a
   data/address separator?
