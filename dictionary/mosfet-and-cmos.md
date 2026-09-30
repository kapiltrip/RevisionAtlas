# MOSFET and CMOS dictionary

[Dictionary index](README.md) | [Subject notes](../MOSFET%20and%20CMOS/README.md)

## Topic index

| Topic | Definitions |
|---|---:|
| [Core terms](#core-terms) | 23 |
| [MOS capacitor fundamentals](#mos-capacitor-fundamentals) | 12 |
| [Non-ideal MOS and MOSFET regions](#non-ideal-mos-and-mosfet-regions) | 12 |
| [MOSFET models and CMOS inverter](#mosfet-models-and-cmos-inverter) | 12 |
| [CMOS switching, delay, power, and noise](#cmos-switching-delay-power-and-noise) | 12 |
| [CMOS sizing and NAND timing](#cmos-sizing-and-nand-timing) | 12 |

## Core terms

[Notes for this topic](../MOSFET%20and%20CMOS/README.md)

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

## MOS capacitor fundamentals

[Notes for this topic](../MOSFET%20and%20CMOS/01%20MOS%20Capacitor%20Fundamentals/README.md)

These meanings follow the electrostatic sequence in [MIT 6.012, MOS Capacitors I](https://ocw.mit.edu/courses/6-012-microelectronic-devices-and-circuits-fall-2009/resources/mit6_012f09_lec09/).

| Term | Meaning |
|---|---|
| **MOS capacitor** | A conductor–oxide–semiconductor stack in which gate bias controls semiconductor surface charge through the oxide electric field. It is a capacitor structure, not a forward DC current path through ideal oxide. |
| **Vacuum level (`E_vac`)** | Energy of a free electron just outside the material, used as a common energy reference. |
| **Fermi level (`E_F`)** | Equilibrium electrochemical-potential reference governing carrier occupancy. A spatially flat equilibrium Fermi level indicates no net current even when bands bend. |
| **Work function (`qΦ`)** | Energy from the Fermi level to vacuum. Metal and semiconductor work functions can differ before contact. |
| **Electron affinity (`qχ`)** | Energy from the semiconductor conduction-band edge to vacuum. Unlike work function, it does not end at the doping-dependent Fermi level. |
| **Band bending** | Spatial change of conduction- and valence-band energies near the surface caused by electrostatic potential variation. It is the energy-diagram view of surface electric field and charge. |
| **Flat band** | Condition in which the semiconductor bands are spatially flat, so the ideal semiconductor has no surface band bending or space-charge field. |
| **Accumulation** | Surface condition in which majority-carrier concentration exceeds its neutral-bulk value. For a p-type substrate, negative gate bias attracts holes toward the oxide interface. |
| **Depletion** | Surface region in which mobile majority carriers are repelled, leaving exposed ionized dopants and a finite space-charge width. |
| **Inversion** | Surface condition in which minority carriers become sufficiently numerous that the surface conductivity type is opposite to the bulk. |
| **Surface potential (`ψ_s`)** | Electrostatic potential of the semiconductor surface relative to the neutral bulk; it quantifies band bending and classifies the surface regime. |
| **Depletion width (`x_d`)** | Depth of the space-charge region under the depletion approximation. It grows as more majority carriers are removed until strong inversion limits further first-order growth. |

## Non-ideal MOS and MOSFET regions

[Notes for this topic](../MOSFET%20and%20CMOS/02%20Non-Ideal%20MOS%20and%20MOSFET%20Regions/README.md)

The MOS-capacitor and MOSFET-region meanings are cross-checked against the [MIT 6.012 MOSFET lecture sequence](https://ocw.mit.edu/courses/6-012-microelectronic-devices-and-circuits-fall-2009/pages/lecture-notes/).

| Term | Meaning |
|---|---|
| **Non-ideal MOS** | A MOS structure that includes work-function difference, oxide/interface charge, finite leakage, traps, or other effects omitted from the ideal electrostatic model. “Non-ideal” means the zero-bias bands and measured voltages can shift; it does not mean the device is defective. |
| **Oxide charge / interface charge** | Fixed, trapped, or bias-responsive charge in the oxide or at the Si–SiO₂ interface that changes the gate voltage required for a given surface condition. |
| **Flat-band voltage (`V_FB`)** | Applied gate voltage needed to cancel work-function and charge offsets so the semiconductor bands become flat. |
| **Threshold voltage (`V_T`)** | Gate voltage associated with the chosen strong-inversion/channel criterion under stated body/drain bias. Oxide charge, doping, work function, and body bias can shift it. |
| **Oxide capacitance (`C_ox`)** | Gate-oxide capacitance, with areal value `C'_ox=ε_ox/t_ox`. A thinner oxide gives larger capacitance and stronger charge control for the same gate voltage. |
| **Depletion capacitance (`C_dep`)** | Incremental capacitance associated with changing depletion charge/width in the semiconductor. In depletion it appears in series with oxide capacitance. |
| **C–V characteristic** | Measured small-signal capacitance versus DC gate bias. Its shape reveals accumulation, depletion, inversion response, frequency effects, and non-ideal charge shifts. |
| **Enhancement-mode MOSFET** | Device that needs gate bias beyond threshold to create a strong conducting channel; it is normally off at zero gate bias in the basic model. |
| **Depletion-mode MOSFET** | Device with a conducting channel at zero gate bias that requires opposite-polarity gate bias to deplete/turn it off. |
| **Channel** | Gate-controlled inversion layer connecting source-side and drain-side regions so carriers can conduct laterally. |
| **Triode / linear region** | Strong-inversion region in which the channel exists from source to drain and current depends strongly on both gate overdrive and drain voltage. |
| **Pinch-off / saturation** | Drain-end channel charge approaches zero when local channel voltage consumes the overdrive; additional drain voltage appears mainly across the drain-side pinch-off region, giving first-order current saturation. |

## MOSFET models and CMOS inverter

[Notes for this topic](../MOSFET%20and%20CMOS/03%20MOSFET%20Models%20and%20CMOS%20Inverter/README.md)

The small-signal definitions follow [MIT 6.012’s MOSFET equivalent-circuit lecture](https://ocw.mit.edu/courses/6-012-microelectronic-devices-and-circuits-fall-2005/1b51ad9a9d359aed058fa62378062eb5_lecture11annotat.pdf); inverter definitions follow the [MIT 6.012 CMOS inverter lecture](https://ocw.mit.edu/courses/6-012-microelectronic-devices-and-circuits-fall-2005/resources/lec14/).

| Term | Meaning |
|---|---|
| **Transfer characteristic** | Relationship between an output quantity and swept input while other bias conditions are specified; for a MOSFET this commonly means `I_D` versus `V_GS`. |
| **On-resistance** | Effective drain–source resistance in a conducting region at a specified bias. It is bias-dependent, not one universal constant for the transistor. |
| **Transconductance (`g_m`)** | Local slope `∂I_D/∂V_GS` at the bias point. It converts a small gate-voltage change into a drain-current change and is measured in siemens. |
| **Output conductance (`g_o`) / resistance (`r_o`)** | Local saturation slope `g_o=∂I_D/∂V_DS`; `r_o=1/g_o`. Nonzero slope makes a practical current source finite rather than ideal. |
| **Channel-length modulation (`λ`)** | Effective channel shortening as drain voltage grows after pinch-off, modeled as a rising saturation current and finite `r_o`. |
| **Early voltage (`V_A`)** | Extrapolated voltage parameter used to express output-slope strength; in a simple model `r_o≈V_A/I_D` and `λ≈1/V_A` under the adopted convention. |
| **Small-signal model** | Linear incremental circuit valid near a DC bias point, using elements such as `g_m v_gs`, `r_o`, body transconductance, and capacitances. It does not replace the large-signal region equations for arbitrary swings. |
| **Intrinsic / parasitic capacitance** | Capacitance from channel charge is intrinsic to device operation; overlap, junction, fringe, and interconnect capacitances add parasitic loading. |
| **CMOS inverter** | Complementary pMOS pull-up and nMOS pull-down gate whose output is driven toward the opposite logic rail of the input. |
| **VTC — voltage transfer characteristic** | DC curve of `V_out` versus `V_in`, obtained by satisfying pull-up and pull-down current balance in each valid region pair. |
| **Switching threshold (`V_M`)** | VTC point where `V_in=V_out`. It summarizes strength balance but is not the only input threshold and is not valid across the whole curve. |
| **Device strength (`β`)** | Long-channel current-factor shorthand containing mobility, oxide capacitance, and `W/L`. Equal `β_n` and `β_p` is a sizing condition, not a natural material equality. |

## CMOS switching, delay, power, and noise

[Notes for this topic](../MOSFET%20and%20CMOS/04%20CMOS%20Switching%20Delay%20Power%20and%20Noise/README.md)

Delay, noise, and power definitions follow the [MIT 6.012 CMOS inverter lecture](https://ocw.mit.edu/courses/6-012-microelectronic-devices-and-circuits-fall-2005/resources/lec14/), [MIT 6.004 CMOS notes](https://ocw.mit.edu/courses/6-004-computation-structures-spring-2017/pages/c3/c3s1/), and [MIT 6.004 design-trade-off notes](https://ocw.mit.edu/courses/6-004-computation-structures-spring-2017/pages/c8/c8s1/).

| Term | Meaning |
|---|---|
| **Load capacitance (`C_L`)** | Total capacitance driven at the output, including gate inputs, diffusion, wiring, and explicit load. Current must charge or discharge it for the logic voltage to move. |
| **Rise / fall time** | Duration of the output’s own LOW-to-HIGH or HIGH-to-LOW transition between specified voltage percentages. It is different from input-to-output propagation delay. |
| **`t_PLH` / `t_PHL`** | Propagation delay for output LOW-to-HIGH or HIGH-to-LOW, measured between defined input/output crossing points. |
| **Average propagation delay (`t_p`)** | Common summary `t_p=(t_PLH+t_PHL)/2`; it hides edge asymmetry and therefore cannot replace checking both directions. |
| **Equivalent resistance / RC model** | First-order replacement of the conducting transistor network by a bias-averaged resistance charging/discharging `C_L`. It gives physical delay intuition but is not an exact large-signal MOS solution. |
| **Pass transistor** | MOSFET used as a controlled connection rather than a restoring logic gate. A lone nMOS passes strong LOW/weak HIGH; a lone pMOS passes strong HIGH/weak LOW. |
| **Transmission gate** | Parallel complementary nMOS/pMOS pass switch with complementary enables, giving bidirectional near-full-swing transfer. |
| **Dynamic switching energy / power** | Energy drawn while capacitance is switched; one ideal 0→1 charge draws `C_L V_DD²` from the supply, and repeated activity gives average power proportional to `α C_L V_DD² f`. |
| **Short-circuit power** | Transition-time power caused by simultaneous pull-up and pull-down conduction when the input passes through the inverter transition region. |
| **Leakage power** | Power from nonzero off-state/junction/gate currents even without intended switching. |
| **`V_IL`, `V_IH`, `V_OL`, `V_OH`** | Guaranteed/defined input and output voltage boundaries used to classify valid LOW/HIGH levels. They are not all equal to the inverter switching threshold. |
| **Noise margin (`NML`, `NMH`)** | `NML=V_IL−V_OL` and `NMH=V_OH−V_IH`; the allowable unwanted voltage before one valid output can become an invalid input. |

## CMOS sizing and NAND timing

[Notes for this topic](../MOSFET%20and%20CMOS/05%20CMOS%20Sizing%20and%20NAND%20Timing/README.md)

The sizing and delay trade-offs are cross-checked against the [MIT 6.012 CMOS inverter lecture](https://ocw.mit.edu/courses/6-012-microelectronic-devices-and-circuits-fall-2005/resources/lec14/) and [MIT 6.004 design trade-offs](https://ocw.mit.edu/courses/6-004-computation-structures-spring-2017/pages/c8/c8s1/).

| Term | Meaning |
|---|---|
| **Transistor sizing (`W/L`)** | Selection of channel width and length to control current drive, resistance, capacitance, and area. Increasing width usually improves drive but also increases input and diffusion capacitance. |
| **Pull-up / pull-down network** | pMOS network that connects an output toward `V_DD` and nMOS network that connects it toward ground for complementary CMOS logic. |
| **Drive-strength ratio** | Relative current capability of pull-up and pull-down networks, often summarized with `β_p/β_n` or an inverse resistance ratio. It sets VTC balance and edge asymmetry. |
| **Series stack** | Two or more conducting transistors in series. The stack has greater effective resistance and internal capacitance than one equal-sized device, so NAND pull-down devices are commonly widened. |
| **Equivalent inverter sizing** | Choosing gate-device widths so a selected pull-up/down path has resistance comparable to a reference inverter. It is a path-based approximation, not proof that every transition becomes identical. |
| **Fan-in** | Number of logic inputs combined by a gate. More inputs can deepen series stacks and add diffusion/internal-node capacitance. |
| **Fan-out / electrical load** | Amount of downstream input capacitance and wiring driven by an output. Logical connection count matters only through the actual capacitance and timing environment. |
| **Worst-case transition** | Input transition and initial internal-node condition producing the largest relevant propagation delay. NAND inputs can have different delays because internal charge depends on which device switches. |
| **Average-current delay method** | Approximation `t≈C_L ΔV/I_avg` using an estimated current over the output swing. Its accuracy depends on selecting the correct region trajectory and current average. |
| **Power–delay trade-off** | Sizing or voltage changes that improve delay can increase capacitance, switching energy, leakage, or area. Optimization must evaluate both cause and cost. |
| **PDP — power-delay product** | Product of average power and propagation delay, with dimensions of energy, used as one combined trade-off metric. It does not reveal area or separate leakage/dynamic mechanisms. |
| **Noise-versus-speed trade-off** | Moving strength ratio can shift switching threshold/noise margins while also changing rise/fall delay. A faster edge in one direction can worsen balance or the opposite edge. |
