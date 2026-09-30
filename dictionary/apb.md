# AMBA APB dictionary

[Dictionary index](README.md) | [Subject notes](../Protocols/04%20AMBA/02%20APB/README.md)

## Core terms

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
