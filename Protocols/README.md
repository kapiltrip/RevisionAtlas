# Protocols

This subject studies communication as an observable hardware contract: who
drives each signal, when a value is valid, which edge accepts it, how flow
control works, and how an error is reported. Matching wire names or widths is
not enough; both endpoints must implement the same timing rules.

## Open a protocol

- [I2C](01%20I2C/README.md) — pages 1-5: open-drain two-wire behavior,
  addressing, START/STOP, ACK/NACK, reads, writes, arbitration, and clock
  stretching.
- [SPI](02%20SPI/README.md) — pages 6-8: full-duplex shifting, chip-select
  topology, bit order, and the four CPOL/CPHA modes.
- [UART](03%20UART/README.md) — pages 9-16: asynchronous framing, baud
  generation, oversampling, transmitter/receiver RTL, and sampling error.
- [AMBA](04%20AMBA/README.md) — on-chip interconnect study:
  [AHB](04%20AMBA/01%20AHB/README.md),
  [APB](04%20AMBA/02%20APB/README.md), and
  [AXI](04%20AMBA/03%20AXI/README.md), including memory-mapped AXI4,
  AXI4-Lite, and AXI-Stream.

The untouched serial-protocol scan is
[protocols-handwritten-notes.pdf](sources/protocols-handwritten-notes.pdf).
AMBA specifications and source notes stay inside the AMBA branch.

## First-principles checklist

For any protocol, answer these questions before memorizing signals:

1. Who initiates the operation, and who can delay it?
2. Who drives every wire during idle, request, data, and response?
3. Which clock edge or signal transition accepts information?
4. What must remain stable while the receiver is not ready?
5. How are address, direction, payload, byte validity, completion, and error
   represented?
6. Can multiple operations overlap, and if so, how are their identities kept
   separate?
7. Which behavior is guaranteed by the protocol, and which is a device or
   implementation choice?

This sequence applies equally to a UART frame, an APB register access, an AHB
pipeline, and an AXI channel handshake.

## Serial links versus AMBA

I2C, SPI, and UART normally connect chips or board-level devices through
serial signaling. AMBA defines synchronous interfaces used mainly between IP
blocks inside an SoC. That changes the engineering questions:

- serial protocols emphasize framing, bit timing, electrical drive, and device
  selection;
- AMBA protocols emphasize pipelining, ready/valid flow control, address
  decoding, response routing, bursts, ordering, buffering, and timing closure.

Do not call AMBA one protocol. It is a family whose members deliberately use
different transfer models.

## AMBA study path

1. Start with **APB** to learn one retained request moving through SETUP and
   ACCESS.
2. Learn **AHB** to see why the address of transfer $N+1$ can overlap the data
   phase of transfer $N$.
3. Learn **AXI** to separate address, data, and response into independently
   flow-controlled channels.
4. Finally trace a bridge. The bridge must buffer request context and translate
   timing and responses; it is never just a wire rename.

## Revision method

For each waveform:

1. mark only the edges that accept data or complete a transfer;
2. label every visible value with the transaction or beat that owns it;
3. insert a wait or back-pressure interval and identify every signal that must
   hold;
4. trace the error path separately from the normal completion path; and
5. state one RTL enable and one verification property derived from the timing.

Use the global [revision plan](../REVISION_PLAN.md) for spaced review.

## Primary references

- [NXP UM10204 — I2C-bus specification and user manual](https://www.nxp.com/docs/en/user-guide/UM10204.pdf)
- [Microchip SPI transfer modes](https://onlinedocs.microchip.com/oxy/GUID-A299F4E7-F38C-4DF5-96C0-A87B9F519156-en-US-4/GUID-8A5B8750-B99E-4176-834E-E44E98F4A098.html)
- [Microchip USART frame principle](https://onlinedocs.microchip.com/oxy/GUID-A9964E93-D46C-42E6-98D2-4ED783ABB2CE-en-US-2/GUID-7BA3A2AA-EFBF-4C3A-BB96-17B8A413DE69.html)
- [Arm AMBA AHB Protocol Specification, IHI 0033C](04%20AMBA/01%20AHB/sources/ARM-IHI-0033C-AMBA-AHB-Protocol-Specification.pdf)
- [Arm AMBA APB Protocol Specification, IHI 0024E](04%20AMBA/02%20APB/sources/ARM-IHI-0024E-AMBA-APB-Protocol-Specification.pdf)
- [Arm AMBA AXI-Stream Protocol Specification, IHI 0051B](04%20AMBA/03%20AXI/sources/ARM-IHI-0051B-AMBA-AXI-Stream-Protocol-Specification.pdf)
- [Arm AMBA AXI and ACE Protocol Specification, IHI 0022H](https://developer.arm.com/-/media/Arm%20Developer%20Community/PDF/IHI0022H_amba_axi_protocol_spec.pdf)
