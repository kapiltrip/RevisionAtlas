# UART dictionary

[Dictionary index](README.md) | [Subject notes](../Protocols/03%20UART/README.md)

## Core terms

Framing and receiver timing references: [Microchip frame formats](https://onlinedocs.microchip.com/oxy/GUID-C431CD9B-65A0-4015-871C-58A444612066-en-US-3/GUID-F84E04E8-3235-4E21-89A9-D1911E9B91DD.html) and [Microchip clock recovery](https://onlinedocs.microchip.com/oxy/GUID-84570A8E-125A-4027-9491-9B22A292E347-en-US-5/GUID-34FF3967-6C5B-4AF9-94C0-97078652CF5C.html).

| Term | Meaning |
|---|---|
| **UART — Universal Asynchronous Receiver/Transmitter** | A hardware block that serializes parallel transmit data and reconstructs parallel receive data using asynchronous character framing. |
| **Asynchronous** | No continuous clock travels with TX data. The receiver detects the START transition, then uses its own configured timing to sample later bit centers. |
| **TX / RX** | TX is the serial output of one endpoint and connects to the other endpoint’s RX input. Independent TX and RX paths permit full-duplex operation. |
| **Idle / START / STOP** | Ordinary non-inverted UART idles HIGH. A LOW START bit creates frame alignment; one or more HIGH STOP bits provide the required end/idle interval. |
| **Data bits** | The payload bits between START and optional parity/STOP fields; ordinary UART commonly transmits the least-significant data bit first. |
| **Parity** | An optional extra bit derived from the data bits. It detects an odd number of inverted bits within the covered character but not an even number, and it does not correct an error. |
| **Baud rate** | Symbol intervals per second ([Keysight, Bits Versus Symbols](https://helpfiles.keysight.com/scopes/FlexDCA-PG/Content/Topics/Quick-Start/theory_bits_vs_symbols.htm)). For ordinary binary NRZ UART, one symbol carries one bit, so baud and line bit rate have the same numerical value. |
| **Bit time** | Duration of one UART bit cell, $`T_{bit}=1/B`$ for baud rate $B$. |
| **Baud tick / clock enable** | A one-system-clock-cycle event used by RTL counters/FSMs to advance bit timing. It is not necessarily a new clock signal. |
| **Oversampling** | Running receive timing at several ticks per bit so START can be qualified and samples can be placed near bit centers. Microchip documents normal-mode reception with 16 timing clocks and majority samples near the middle. |
| **Framing error** | A received STOP-bit position that is not HIGH when sampled, indicating that the reconstructed character boundary is invalid. |
| **FSM — finite-state machine** | A finite set of stored states plus transition/output rules; in UART it sequences `IDLE`, `START`, `DATA`, optional `PARITY`, and `STOP`. |
| **Nonblocking assignment (`<=`)** | A Verilog/SystemVerilog procedural assignment that evaluates its right-hand side when the statement executes but schedules the left-hand-side update for the nonblocking-assignment update region. In clocked RTL, this lets multiple registers sample the same pre-edge state rather than acquiring source-order dependencies. |
