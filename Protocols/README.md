# Protocols

This subject covers hardware communication protocols. The existing 16-page handwritten scan is preserved once and separated into I2C, SPI, and UART rooms. The AMBA branch adds on-chip interconnect study and code without mixing its pipelined bus rules into the serial-protocol notes.

## Core terms

| Term | Precise meaning | Physical / practical meaning |
|---|---|---|
| **Communication protocol** | An agreed set of electrical, timing, framing, addressing, and response rules that lets endpoints assign the same meaning to signal activity. The NXP I2C specification, for example, defines bus signals, transfer conditions, byte formats, acknowledgment, and arbitration rather than merely naming two wires ([NXP UM10204](https://www.nxp.com/docs/en/user-guide/UM10204.pdf)). | A wire carries voltage; the protocol says when that voltage is data, clock, address, acknowledgment, idle, or an error/termination condition. |
| **Serial communication** | Transfer in which a word is represented as an ordered sequence of bits over time rather than one simultaneous conductor per bit. | It reduces pin count but requires framing, bit ordering, and timing recovery or an accompanying clock. |
| **Synchronous serial communication** | Communication in which sampling is referenced to an explicitly transferred or otherwise shared clock. I2C supplies SCL and SPI supplies SCK ([NXP UM10204](https://www.nxp.com/docs/en/user-guide/UM10204.pdf), [Microchip SPI modes](https://onlinedocs.microchip.com/oxy/GUID-A299F4E7-F38C-4DF5-96C0-A87B9F519156-en-US-4/GUID-8A5B8750-B99E-4176-834E-E44E98F4A098.html)). | The receiver knows which clock edge defines a valid data sample. |
| **Asynchronous serial communication** | Communication without a continuously transferred sampling clock; endpoints agree on nominal symbol timing and recover alignment from framing transitions. A UART receiver begins from the START transition and samples within later bit cells ([Microchip UART reception](https://onlinedocs.microchip.com/oxy/GUID-F2693295-804D-4E36-8BA5-0105C1751EA5-en-US-3/GUID-2966F8A6-816E-45CF-87A6-FB4C876E377D.html)). | “Asynchronous” does not mean untimed. Both endpoints still require sufficiently close baud rates. |
| **Frame** | A defined sequence that packages payload with timing or control fields such as START, address, parity, acknowledgment, or STOP. Microchip’s common UART `8N1` example contains one START bit, eight data bits, no parity, and one STOP bit ([Microchip USART guide](https://onlinedocs.microchip.com/oxy/GUID-78D70ED6-D060-4984-8F25-B119A2A89ABB-en-US-3/GUID-BA123D56-04C4-40CB-93D5-644DF3FD9C1D.html)). | Framing lets the receiver locate data boundaries and detect some invalid conditions. |
| **Simplex / half duplex / full duplex** | Simplex carries useful data in one direction; half duplex supports both directions at different times; full duplex supports simultaneous opposite-direction transfer. Microchip documents asynchronous USART with separate RX and TX as full duplex and one-wire operation as half duplex ([Microchip USART guide](https://onlinedocs.microchip.com/oxy/GUID-78D70ED6-D060-4984-8F25-B119A2A89ABB-en-US-3/GUID-BA123D56-04C4-40CB-93D5-644DF3FD9C1D.html)). | Count independent data paths and whether they can be active simultaneously; do not infer duplex only from the protocol name. |
| **Bit rate** | Number of bits transmitted per second ([Keysight, “Bits Versus Symbols”](https://helpfiles.keysight.com/scopes/FlexDCA-PG/Content/Topics/Quick-Start/theory_bits_vs_symbols.htm)). | It counts transmitted bits; useful payload throughput can be lower after framing, coding, or protocol overhead. |
| **Baud rate** | Number of signaling symbols transmitted per second ([Keysight, “Bits Versus Symbols”](https://helpfiles.keysight.com/scopes/FlexDCA-PG/Content/Topics/Quick-Start/theory_bits_vs_symbols.htm)). | Baud equals bit rate only when each symbol represents one bit, as in ordinary binary NRZ UART; the definitions are not universally interchangeable. |
| **Electrical layer versus protocol layer** | Electrical rules define voltage, current drive, polarity, and physical signaling; protocol rules define timing and meaning. | UART framing can be transported through TTL/CMOS GPIO, RS-232, or RS-485 transceivers, but those electrical interfaces are not alternate names for UART. |

## Ordered path

| Topic room | Source pages | Main coverage |
|---|---:|---|
| [I2C](01%20I2C/README.md) | 1-5 | Two-wire electrical behavior, addressing, START/STOP, ACK/NACK, reads, writes, and clock stretching |
| [SPI](02%20SPI/README.md) | 6-8 | Four-wire full-duplex transfers, shift-register model, chip select, and the four CPOL/CPHA modes |
| [UART](03%20UART/README.md) | 9-16 | Asynchronous framing, baud generation, oversampling, and transmitter/receiver RTL architecture |
| [AMBA](04%20AMBA/README.md) | New sources | AMBA family map; current AHB-Lite timing, FSM correction, RTL, and verification |

The untouched serial-protocol scan is available as [protocols-handwritten-notes.pdf](sources/protocols-handwritten-notes.pdf). AHB has its own official specification and later handwritten-note intake inside the [AMBA branch](04%20AMBA/README.md).

## How to use these notes

Each source page is rendered inline before its discussion. Read the page first, explain its diagram aloud, and only then open the explanation. Every page then provides:

- **Technical discussion:** a formal, page-specific explanation of each visible signal, diagram, equation, or timing relationship in the same order as the source page.
- **Technical corrections and qualifications:** verified corrections, implementation constraints, and precise limits needed before applying the handwritten statement to hardware.
- **Active recall:** a closed-book prompt aimed at the causal logic rather than the wording.

The discussion remains within the subject matter visible or directly implied on its source page. Additional facts are included only when they correct, quantify, or technically deepen that material, and important protocol claims are checked against the manufacturer references below.

## How to revise protocols

For every transaction, draw the complete waveform and answer in order:

1. Who initiates the transfer?
2. Who drives each wire in every field?
3. Which edge or transition defines sampling?
4. Where are address, direction, payload, acknowledgment, and termination represented?
5. What detects rejection or corruption—and what does not?
6. Which statement is universal to the protocol and which is device-specific?

Then compare one nearby protocol without saying only “faster” or “fewer wires.” Compare clocking, electrical drive, selection/addressing, duplex behavior, framing, acknowledgment, and implementation cost. Use the global [revision plan](../REVISION_PLAN.md) for the spaced schedule.

## Question and correction register

| Page | Issue recognized | Resolution |
|---|---|---|
| [I2C page 1](01%20I2C/README.md#page-01) | Are baud rate and bit rate always the same, and is I2C a single-wire bus? | They coincide only for one bit per symbol; ordinary I2C uses two shared signal lines, SDA and SCL. |
| [I2C page 3](01%20I2C/README.md#page-03) | Do ACK/NACK provide general error detection, and is 5 MHz an ordinary I2C speed? | ACK/NACK reports byte acceptance, not a checksum; 5 Mbit/s belongs to the special unidirectional Ultra Fast-mode. |
| [I2C page 5](01%20I2C/README.md#page-05) | Who sends ACK during a read? | The controller-receiver ACKs each wanted byte and NACKs the final byte before STOP or a repeated START. |
| [SPI page 6](02%20SPI/README.md#page-06) | Is SPI always faster than 10 Mbit/s and always exactly four wires? | Neither is guaranteed; rate and wiring depend on the devices and topology. |
| [SPI page 8](02%20SPI/README.md#page-08) | What do CPOL and CPHA really select? | CPOL selects idle clock level; CPHA selects whether the first or second edge is the sampling edge. |
| [UART page 10](03%20UART/README.md#page-10) | How many 50 MHz clock cycles form one 9600-baud bit? | $50\,000\,000/9600=5208.333\ldots$, so an integer-only divider is approximate. |
| [UART page 11](03%20UART/README.md#page-11) | Does 16x oversampling mean 325 clocks per sample at 50 MHz and 9600 baud? | The ideal value is $325.5208\ldots$ clocks; a practical generator must accept error or use fractional timing. |
| [UART page 16](03%20UART/README.md#page-16) | Why does `sample <= sample + 1'b1` appear to lag inside the same sequential block? | A nonblocking assignment updates after the block, so comparisons in that edge see the old counter value. |

## Verification references

The page discussions were checked against primary manufacturer documentation:

- [NXP UM10204 - I2C-bus specification and user manual](https://www.nxp.com/docs/en/user-guide/UM10204.pdf)
- [Microchip SPI transfer modes](https://onlinedocs.microchip.com/oxy/GUID-A299F4E7-F38C-4DF5-96C0-A87B9F519156-en-US-4/GUID-8A5B8750-B99E-4176-834E-E44E98F4A098.html)
- [Microchip USART frame principle](https://onlinedocs.microchip.com/oxy/GUID-A9964E93-D46C-42E6-98D2-4ED783ABB2CE-en-US-2/GUID-7BA3A2AA-EFBF-4C3A-BB96-17B8A413DE69.html)
- [Microchip USART clock recovery](https://onlinedocs.microchip.com/oxy/GUID-84570A8E-125A-4027-9491-9B22A292E347-en-US-5/GUID-34FF3967-6C5B-4AF9-94C0-97078652CF5C.html)
- [AMD Zynq UART baud-rate generator](https://docs.amd.com/r/en-US/ug585-zynq-7000-SoC-TRM/Baud-Rate-Generator)
- [TI MSPM0 UART oversampling and majority voting](https://software-dl.ti.com/msp430/esd/MSPM0-SDK/latest/docs/english/driverlib/mspm0l11xx_l13xx_api_guide/html/group___u_a_r_t.html)
