# AMBA AXI dictionary

[Dictionary index](README.md) | [Subject notes](../Protocols/04%20AMBA/03%20AXI/README.md)

## Core terms

| Term | Precise meaning | Hardware meaning |
|---|---|---|
| **AMBA** | Arm's Advanced Microcontroller Bus Architecture family of on-chip interface standards. | Independently designed IP blocks can exchange information through a shared electrical and timing contract. |
| **AXI** | Advanced eXtensible Interface, the AMBA family used for high-performance memory-mapped and streaming communication. | AXI separates information into channels so each channel can use its own flow-control handshake. |
| **AXI-Stream** | A standard point-to-point interface for exchanging an ordered stream of bytes between a Transmitter and Receiver. | It carries payload and packet metadata without an address phase on every transfer. |
| **Transmitter / source** | The endpoint that drives `TVALID`, `TDATA`, and associated sideband information. | It owns the offered beat and must keep it stable while stalled. Older material often calls it the master. |
| **Receiver / destination** | The endpoint that drives `TREADY` and accepts a transfer. | It creates back-pressure by lowering `TREADY`. Older material often calls it the slave. |
| **Transfer / beat** | One payload-and-sideband item accepted on one rising edge where `TVALID` and `TREADY` are both HIGH. | A beat counter, pointer, or state machine advances once for that edge and not merely once per clock. |
| **Packet** | A related group of transfers whose final transfer is identified by `TLAST` when packet boundaries are used. | `TLAST` belongs to the same held beat as `TDATA`; it cannot disappear during a stall. |
| **Back-pressure** | The Receiver's ability to postpone acceptance by driving `TREADY` LOW. | The Transmitter freezes the complete offered beat until acceptance becomes possible. |

These definitions follow the terminology and transfer model in
[Arm IHI 0051B](../_internal/Protocols/04%20AMBA/03%20AXI/sources/ARM-IHI-0051B-AMBA-AXI-Stream-Protocol-Specification.pdf).
