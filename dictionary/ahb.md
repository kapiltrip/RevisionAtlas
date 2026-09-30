# AMBA AHB dictionary

[Dictionary index](README.md) | [Subject notes](../Protocols/04%20AMBA/01%20AHB/README.md)

## Topic index

| Topic | Definitions |
|---|---:|
| [Core terms](#core-terms) | 10 |
| [RTL variables](#rtl-variables) | 15 |

## Core terms

[Notes for this topic](../Protocols/04%20AMBA/01%20AHB/README.md)

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

## RTL variables

[Notes for this topic](../Protocols/04%20AMBA/01%20AHB/code/FSM.md)

| Name | Use |
|---|---|
| `req_valid` | Local controller says the command fields are valid |
| `req_ready` | Manager is idle and able to accept one command |
| `req_write` | HIGH for write, LOW for read |
| `req_burst` | Small local encoding for SINGLE, INCR4, or WRAP4 |
| `req_addr` | Starting byte address; must be word-aligned in this design |
| `req_wdata` | Four packed possible write beats, with beat 0 in bits `[31:0]` |
| `write_q` | Captured direction, stable for the entire command |
| `burst_q` | Captured burst kind used for `HBURST`, beat count, and next address |
| `write_data_q` | Captured write-data pack so the caller may change its inputs after handshake |
| `addr_index_q` | Current address-phase beat number |
| `data_index_q` | Current data-phase beat number |
| `data_valid_q` | There is an accepted address whose data phase is now outstanding |
| `rsp_rdata` | Packed completed read beats in the same ordering as `req_wdata` |
| `done` | One-clock pulse after the final data phase or local request rejection |
| `error` | One-clock pulse for an invalid local request or an AHB ERROR response |
