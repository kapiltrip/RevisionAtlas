# I2C dictionary

[Dictionary index](README.md) | [Subject notes](../Protocols/01%20I2C/README.md)

## Core terms

The terms below follow the bus definitions and transaction rules in the [NXP I2C-bus specification, UM10204](https://www.nxp.com/docs/en/user-guide/UM10204.pdf).

| Term | Meaning |
|---|---|
| **I2C — Inter-Integrated Circuit** | A synchronous, addressed, shared serial bus whose two bus signals are serial data (`SDA`) and serial clock (`SCL`). “Two-wire” counts these signals, not power and ground. |
| **SDA / SCL** | `SDA` carries address, direction, data, and ACK/NACK levels. `SCL` supplies the bit timing. Both normally use open-drain/open-collector behavior with pull-ups. |
| **Controller / target** | A controller initiates a transfer, generates START, normally supplies SCL, addresses a target, and ends or redirects the transfer. A target participates when addressed. These replace the older “master/slave” terms in current NXP wording. |
| **Open-drain** | An output that can actively pull LOW or release the line but does not actively drive HIGH. |
| **Pull-up resistor** | The external path that charges a released SDA or SCL line toward HIGH. Together with bus capacitance it determines the rising-edge time and LOW-state current trade-off. |
| **START / repeated START / STOP** | START is SDA HIGH-to-LOW while SCL is HIGH; STOP is SDA LOW-to-HIGH while SCL is HIGH. A repeated START begins another transfer phase without first releasing the bus through STOP. |
| **Address phase** | The initial byte sequence that selects a target and states transfer direction; ordinary 7-bit addressing sends seven address bits followed by the `R/W` bit. |
| **ACK / NACK** | During the ninth clock, the byte receiver pulls SDA LOW for ACK or leaves it released for NACK. NACK can mean rejection, no receiver, or normal termination of the final byte in a controller read; it is not a checksum. |
| **Arbitration** | A controller that tries to send released HIGH but observes dominant LOW loses ownership and stops driving. This works because every participant observes the actual wired bus. |
| **Clock stretching** | A target delays progress by holding SCL LOW after the controller releases it. The controller must wait for the physical line to rise. |
