# Protocols

This subject covers hardware communication protocols. The existing 16-page handwritten scan is preserved once and separated into I2C, SPI, and UART rooms. The AMBA branch adds AHB, APB, and AXI as separate on-chip interconnect chapters so their bus phases, channels, and handshake rules are not mixed into the serial-protocol notes or into one another.

<a id="core-terms"></a>

[Term dictionary](../dictionary/protocols.md#core-terms)

## Ordered path

1. [I2C](01%20I2C/README.md), source pages 1–5: two-wire electrical
   behavior, addressing, START/STOP, ACK/NACK, reads, writes, and clock
   stretching.
2. [SPI](02%20SPI/README.md), source pages 6–8: full-duplex shift-register
   movement, chip selection, and the four CPOL/CPHA modes.
3. [UART](03%20UART/README.md), source pages 9–16: asynchronous framing, baud
   generation, oversampling, and transmitter/receiver RTL architecture.
4. [AMBA](04%20AMBA/README.md), separate sources: AHB pipelining and RTL, APB
   setup/access timing, and the complete AXI section-organized course notes
   through lesson 128.

The untouched serial-protocol scan is available as
[protocols-handwritten-notes.pdf](../_internal/Protocols/sources/protocols-handwritten-notes.pdf).
Each AMBA chapter keeps its own authoritative specification and learning
evidence inside the [AMBA branch](04%20AMBA/README.md).

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

Then compare one nearby protocol without saying only “faster” or “fewer wires.” Compare clocking, electrical drive, selection/addressing, duplex behavior, framing, acknowledgment, and implementation cost. Use the global [revision method](../_internal/repository/guides/REVISION_METHOD.md) for the spaced schedule.

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
