# VLSI Design

VLSI design turns device and logic behavior into an implementable integrated circuit. The present scope deliberately connects three levels: MOS/CMOS physical behavior, FIFO RTL architecture, and clock-divider sequential logic.

## Major topic rooms

| Topic | Current evidence | Purpose | Prerequisite role |
|---|---:|---|---|
| [MOSFET and CMOS](MOSFET%20and%20CMOS/README.md) | 110 source pages | Device physics through CMOS timing, power, noise, and sizing | Explains what gates and storage cells physically cost and how they switch |
| [FIFO](FIFO/README.md) | Architecture guide + starter RTL | RAM → synchronous FIFO → verification/synthesis/timing → asynchronous FIFO → CDC verification | Applies storage, sequential state, boundary logic, and timing |
| [Frequency Dividers](Frequency%20Dividers/README.md) | 13 source pages | Divide-by-2/3/4/5, duty-cycle design, solved questions, and fractional dividers | Applies flip-flops, counters, FSMs, generated clocks, and waveform reasoning |

`MOSFET and CMOS`, `FIFO`, and `Frequency Dividers` are separate major topic rooms. The current material is foundational coverage, not a claim that the entire VLSI Design subject is complete. Later units can sit beside them in the same way.

## Core terms

| Term | Precise meaning | Physical / practical meaning |
|---|---|---|
| **VLSI design** | The engineering of integrated systems containing a very large number of devices, from logical description through physical implementation. The broader ASIC flow includes RTL, verification, synthesis, floorplanning, placement, routing, and signoff ([Synopsys ASIC design overview](https://www.synopsys.com/glossary/what-is-asic-design.html)). | A behavioral idea must ultimately become transistors, wires, clocks, power delivery, and manufacturable geometry. |
| **RTL — Register-Transfer Level** | A synchronous digital-design abstraction that describes registers, combinational transformations, and transfers of data between registers; it is commonly written in Verilog, SystemVerilog, or VHDL ([Synopsys RTL design overview](https://www.synopsys.com/glossary/what-is-register-transfer-level-design.html)). | RTL says what state exists and how it changes on clock events; it is not software executed line by line. |
| **Synthesis** | Automated transformation of an RTL design into an optimized gate- or device-level netlist under target technology and constraints ([AMD Vivado Synthesis UG901](https://docs.amd.com/r/en-US/ug901-vivado-synthesis)). | `always` blocks, expressions, arrays, and conditions become flip-flops, LUTs/gates, RAMs, muxes, and connections. |
| **Netlist** | A structural representation listing cells or primitives and the nets that connect their pins; it is the principal output of synthesis and input to implementation. UG901 describes synthesis as transforming RTL into a gate-level netlist ([AMD UG901](https://docs.amd.com/r/en-US/ug901-vivado-synthesis)). | A netlist describes *which hardware instances are connected*, not where they are physically placed. |
| **Functional verification** | Evidence that the design behavior matches its specification, commonly using simulation, assertions, formal methods, and coverage ([Synopsys ASIC design overview](https://www.synopsys.com/glossary/what-is-asic-design.html)). | Passing compilation or synthesis is not proof that ordering, boundary cases, or protocol behavior is correct. |
| **Implementation** | Mapping the synthesized structure into physical resources: floorplanning, placement, clock construction, and routing for an ASIC or FPGA. These steps follow synthesis in the documented ASIC flow ([Synopsys ASIC design overview](https://www.synopsys.com/glossary/what-is-asic-design.html)). | It determines real wire delay, congestion, clock skew, resource use, and whether timing can close. |
| **PPA — power, performance, and area** | The three coupled design objectives used to evaluate an implementation ([Synopsys ASIC design overview](https://www.synopsys.com/glossary/what-is-asic-design.html)). | Faster logic may require larger cells or more pipeline registers; lower power may reduce speed; smaller area may increase congestion. |
| **Timing closure** | The iterative process of constraining, analyzing, and changing a design until required timing checks pass in all intended views. Intel describes timing analysis as checking arrival times against required times ([Intel timing-analysis overview](https://www.intel.com/content/www/us/en/support/programmable/support-resources/design-guidance/quartus-support.html)). | Functionally correct RTL can still fail in hardware if data or clocks arrive outside legal windows. |
| **CDC — clock-domain crossing** | Transfer of information between logic driven by clocks without a guaranteed common sampling relationship. Intel’s timing documentation treats asynchronous clock groups and CDC paths as separate constraint/analysis concerns ([Intel Timing Analyzer guide](https://www.intel.com/content/www/us/en/docs/programmable/683243/24-1/timing-analysis-basic-concepts.html)). | The destination can sample near a transition; synchronizers, handshakes, or asynchronous FIFOs are architectural requirements, not simulation conveniences. |

## How to revise this subject

Use a three-level explanation:

1. **Physical level:** What voltage, charge, transistor path, or capacitance changes?
2. **RTL level:** What state, pointer, counter, or output changes on the active edge?
3. **Implementation level:** What hardware is inferred, what path is timed, and what PPA or CDC trade-off appears?

If an RTL result feels arbitrary, move down to the physical or storage mechanism. If a physically valid circuit still fails a design goal, move up to architecture, verification, synthesis, and timing. Use the complete repository [revision plan](../../REVISION_PLAN.md) for session timing and Day 1/3/7/14/30 reviews.

## Completion boundary

The present VLSI Design pillar is revision-ready only for the three topic rooms above. Verilog/RTL, digital design, verification, physical design, DFT, low power, computer architecture, and analog design should be added as separate governed subjects or topic rooms through the root [Future Plan](../../FUTURE_PLAN.md).
