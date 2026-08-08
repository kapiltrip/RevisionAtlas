# MOSFET and CMOS

This subject is a deep reading of five MOS notebooks. Each page becomes an
active-revision unit with its source image, explanation, corrections, and a
closed-book recall question.

## Core term map

The device definitions are cross-checked against [MIT 6.012 MOS-capacitor material](https://ocw.mit.edu/courses/6-012-microelectronic-devices-and-circuits-fall-2009/resources/mit6_012f09_lec09/), the [MIT 6.012 lecture sequence for MOSFET models and CMOS](https://ocw.mit.edu/courses/6-012-microelectronic-devices-and-circuits-fall-2009/pages/lecture-notes/), and [MIT 6.004 CMOS logic notes](https://ocw.mit.edu/courses/6-004-computation-structures-spring-2017/pages/c3/c3s1/).

| Term | Precise meaning | Physical / design meaning |
|---|---|---|
| **MOS — metal–oxide–semiconductor** | A gate/conductor, insulating oxide, and semiconductor stack whose surface charge is controlled electrostatically. | Ideally the gate controls the surface through electric field without steady DC current through the oxide. |
| **MOS capacitor** | Two-terminal MOS structure used to study gate voltage, oxide field, semiconductor charge, and surface potential ([MIT MOS Capacitors I](https://ocw.mit.edu/courses/6-012-microelectronic-devices-and-circuits-fall-2009/resources/mit6_012f09_lec09/)). | It is the electrostatic core of the MOSFET before source and drain current are added. |
| **Work function** | Energy from a material’s Fermi level to the vacuum level. | A metal–semiconductor work-function difference shifts the voltage needed for flat band. |
| **Accumulation / depletion / inversion** | Surface regimes in which majority carriers increase, mobile majority carriers are repelled leaving ionized dopants, or minority carriers form a surface layer of opposite conductivity ([MIT MOS Capacitors I](https://ocw.mit.edu/courses/6-012-microelectronic-devices-and-circuits-fall-2009/resources/mit6_012f09_lec09/)). | These names describe *which charge exists at the semiconductor surface*, not three arbitrary curve regions. |
| **Surface potential (`\psi_s`)** | Electrostatic potential difference between the semiconductor surface and neutral bulk. | It measures band bending and controls depletion/inversion charge. |
| **Flat-band voltage (`V_FB`)** | Gate voltage that makes semiconductor bands flat, cancelling work-function and oxide/interface-charge offsets. | Flat band means no semiconductor band bending; it does not necessarily mean zero applied gate voltage. |
| **Threshold voltage (`V_T`)** | Gate-voltage reference at which strong inversion/channel formation is conventionally reached under stated body and drain conditions ([MIT MOS Capacitors I](https://ocw.mit.edu/courses/6-012-microelectronic-devices-and-circuits-fall-2009/resources/mit6_012f09_lec09/)). | It marks the transition to useful inversion conduction in the long-channel model; it is not a perfect physical on/off step. |
| **MOSFET** | Field-effect transistor in which gate-controlled surface charge forms or modulates a channel between source and drain. | Gate voltage controls channel current while the insulated gate ideally draws negligible DC current. |
| **Cutoff / triode / saturation** | Long-channel operating regions distinguished by inversion and channel voltage: no strong channel, channel along the full length, or drain-end pinch-off. MIT’s MOSFET lecture sequence develops these regions and current models ([MIT 6.012 lecture notes](https://ocw.mit.edu/courses/6-012-microelectronic-devices-and-circuits-fall-2009/pages/lecture-notes/)). | “Saturation” means current is first-order less dependent on drain voltage after pinch-off; it does not mean maximum possible current in every sense. |
| **Overdrive voltage (`V_OV`)** | Gate voltage beyond threshold, such as `V_GS − V_T` for nMOS under the chosen convention. | It sets inversion strength and the triode/saturation boundary in the square-law model. |
| **Transconductance (`g_m`)** | Small-signal change in drain current per change in gate-source voltage at a bias point, `g_m = ∂I_D/∂V_GS` ([MIT 6.012 MOSFET model lecture](https://ocw.mit.edu/courses/6-012-microelectronic-devices-and-circuits-fall-2005/1b51ad9a9d359aed058fa62378062eb5_lecture11annotat.pdf)). | It measures how effectively gate voltage controls current, which directly affects gain and speed. |
| **Channel-length modulation / output resistance (`r_o`)** | Drain-side pinch-off movement shortens effective channel as `V_DS` rises, giving nonzero saturation output conductance; `r_o=1/g_o` ([MIT 6.012 MOSFET model lecture](https://ocw.mit.edu/courses/6-012-microelectronic-devices-and-circuits-fall-2005/1b51ad9a9d359aed058fa62378062eb5_lecture11annotat.pdf)). | A saturated MOSFET is a finite-resistance current source, not an ideal one. |
| **Body effect** | Threshold change caused by source-to-body bias changing depletion charge. | The body is a fourth terminal; tying it incorrectly changes switching point, current, and delay. |
| **Parasitic capacitance** | Unintended/effective capacitance from gate overlap, channel charge, junctions, interconnect, and load. | Every transition must charge or discharge capacitance, creating delay and dynamic energy cost. |
| **CMOS — complementary MOS** | Logic style using complementary nMOS pull-down and pMOS pull-up networks so a valid steady state ideally has no direct supply-to-ground path ([MIT 6.004 CMOS notes](https://ocw.mit.edu/courses/6-004-computation-structures-spring-2017/pages/c3/c3s1/)). | One network establishes LOW and the complementary network establishes HIGH, giving rail-to-rail logic and low ideal static power. |
| **VTC — voltage transfer characteristic** | DC relation `V_out(V_in)` of a logic gate. | Its slope and transition location determine logic thresholds, gain, and noise immunity. |
| **Switching threshold (`V_M`)** | Special VTC crossing where `V_in=V_out`, often used to summarize inverter balance. | It is one point, not an equality that holds across the curve. Device strengths move it left or right. |
| **Noise margin** | Allowed DC noise between guaranteed output levels and required input thresholds: `NML=V_IL−V_OL`, `NMH=V_OH−V_IH` ([MIT 6.004 signaling notes](https://ocw.mit.edu/courses/6-004-computation-structures-spring-2017/pages/c2/c2s1/)). | It measures how much unwanted voltage can be added while the next gate still interprets the logic value correctly. |
| **Propagation delay** | Time between a defined input crossing and the corresponding output crossing; `t_p` is commonly the average of `t_PHL` and `t_PLH` ([MIT 6.012 CMOS inverter lecture](https://ocw.mit.edu/courses/6-012-microelectronic-devices-and-circuits-fall-2005/resources/lec14/)). | It is input-to-output response time, distinct from the output’s own rise or fall transition duration. |
| **Dynamic switching power** | Average power associated with repeated charging/discharging of capacitance, commonly `P ≈ α C_L V_DD^2 f` for activity factor `α` under the model ([MIT 6.004 design trade-offs](https://ocw.mit.edu/courses/6-004-computation-structures-spring-2017/pages/c8/c8s1/)). | It grows with switched capacitance, voltage squared, and switching rate. |
| **Leakage / short-circuit power** | Leakage is steady non-ideal current in nominally non-switching states; short-circuit power occurs during transitions when pull-up and pull-down conduct simultaneously. | “CMOS has zero static power” is an ideal first-order statement, not a modern physical guarantee. |
| **Drive strength / sizing (`W/L`)** | Ability of a device/network to source or sink current, influenced by mobility, oxide capacitance, overdrive, and transistor geometry. | Wider devices can reduce effective resistance but increase input/diffusion capacitance and area. |
| **Transmission gate** | Parallel nMOS and pMOS pass devices driven by complementary enables, forming a bidirectional CMOS switch. | nMOS supports a strong LOW and pMOS a strong HIGH, avoiding the first-order single-pass threshold loss. |

## Ordered path

1. [MOS Capacitor Fundamentals](01%20MOS%20Capacitor%20Fundamentals/README.md) - energy references and electrostatics.
2. [Non-Ideal MOS and MOSFET Regions](02%20Non-Ideal%20MOS%20and%20MOSFET%20Regions/README.md) - practical threshold shifts and channel operation.
3. [MOSFET Models and CMOS Inverter](03%20MOSFET%20Models%20and%20CMOS%20Inverter/README.md) - device models and complementary switching.
4. [CMOS Switching Delay, Power, and Noise](04%20CMOS%20Switching%20Delay%20Power%20and%20Noise/README.md) - circuit performance and valid logic levels.
5. [CMOS Sizing and NAND Timing](05%20CMOS%20Sizing%20and%20NAND%20Timing/README.md) - ratio choices and multi-transistor delay.

## What every page discussion contains

- The complete source-page image, inline and readable.
- **What this page is doing:** a conceptual explanation in the page's own order, including why each diagram or equation is used.
- **Question or TODO acknowledged:** included whenever the handwriting asks, doubts, or leaves an action unfinished; the answer is placed beside it.
- **Clarity / correction / improvement:** distinguishes a genuine correction from a notation clarification or a useful addition.
- **Active recall:** a closed-book question that tests the page's causal logic.

## Verification stance

Handwritten notes are treated as the source to understand, not as automatically correct. Important physics and circuit claims are checked against the references in the root README. A note may be labeled:

- **Correct:** sound as written.
- **Clarify:** essentially correct but easy to misread because a sign, region, or assumption is implicit.
- **Corrected:** the revision text replaces a technically inaccurate statement and explains why.

This first iteration aims for complete page coverage and dependable understanding. Later iterations can add spaced-repetition status, exam questions, formula sheets, and mixed-topic tests without changing this source-preserving foundation.

## How to revise MOSFET and CMOS

Use one causal chain instead of memorizing isolated equations:

`gate bias → electric field/band bending → surface charge → channel state → drain current → CMOS output current → load-capacitor charging → delay, power, and noise margin`

For each page, first state the physical charge or conducting path, then the valid operating region and assumptions, and only then the equation. Check signs and limiting cases. End by explaining one circuit consequence: gain, logic level, delay, power, area, or noise. Use the global [revision plan](../REVISION_PLAN.md) for session structure and spaced reviews.
