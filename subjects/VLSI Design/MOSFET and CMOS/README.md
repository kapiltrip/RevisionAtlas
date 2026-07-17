# MOSFET and CMOS

This is the first subject iteration: a deep reading of Kapil's five handwritten MOS notebooks, arranged so every page can become an active-revision unit.

> "Each page should be ... read first of all in a deep manner."
>
> "If I have ask some questions or if I am mention any two to do list then you need to acknowledge that as well for me."
>
> "After the page explanation is there ... if it needs more clarity, if it needs more improvement, you can mention that."

The ellipses preserve the intent of the voice-typed brief while removing filler between the quoted clauses.

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

## Question and TODO register

This table is an index of clearly visible questions, doubts, or unfinished prompts in the handwriting. The detailed answer lives on the linked page.

| Module/page | Handwritten issue recognized | Resolution |
|---|---|---|
| [MOS 1, page 7](01%20MOS%20Capacitor%20Fundamentals/README.md#page-07) | How can a p-type surface move from accumulation toward inversion? | Separate majority-hole repulsion, depletion, and thermally supplied minority-electron attraction. |
| [MOS 1, page 10](01%20MOS%20Capacitor%20Fundamentals/README.md#page-10) | Why is the Fermi level drawn flat? Does that imply current? | A single flat equilibrium Fermi level means constant electrochemical potential and therefore zero net current. |
| [MOS 2, page 2](02%20Non-Ideal%20MOS%20and%20MOSFET%20Regions/README.md#page-02) | Must the metal/gate be changed to obtain flat band? | No; an external flat-band voltage can cancel work-function and fixed-charge offsets. Gate material is a design lever, not the only remedy. |
| [MOS 2, page 18](02%20Non-Ideal%20MOS%20and%20MOSFET%20Regions/README.md#page-18) | Why is the channel-body junction more reverse biased near the drain? | Channel potential rises toward the drain while the body stays fixed, increasing local reverse bias and widening depletion. |
| [MOS 3, page 7](03%20MOSFET%20Models%20and%20CMOS%20Inverter/README.md#page-07) | Where does additional drain voltage appear after pinch-off? | Across the growing drain-side pinch-off region; it shortens the effective channel rather than reflecting backward. |
| [MOS 3, page 19](03%20MOSFET%20Models%20and%20CMOS%20Inverter/README.md#page-19) | Why can a saturated MOSFET amplify? | Gate voltage controls current through $g_m$, and the load converts that current change into a larger output-voltage change. |
| [MOS 3, page 21](03%20MOSFET%20Models%20and%20CMOS%20Inverter/README.md#page-21) | What does $V_{in}=V_{out}$ mean? | It is the special VTC crossing used to define inverter switching threshold, not an equality valid across the entire curve. |
| [MOS 3, page 22](03%20MOSFET%20Models%20and%20CMOS%20Inverter/README.md#page-22) | Why assume $k_n=k_p$, and what makes one device strong? | Equal effective strength is a sizing choice; mobility and $W/L$ set strength, so pMOS is usually wider. |
| [MOS 3, page 24](03%20MOSFET%20Models%20and%20CMOS%20Inverter/README.md#page-24) | Can one inverter device be in linear region? | Yes. Most VTC sections have one linear and the other saturated; both-saturation is only the central transition condition. |
| [MOS 4, pages 14-16](04%20CMOS%20Switching%20Delay%20Power%20and%20Noise/README.md#page-14) | Which transistor passes which logic level strongly, and how is the threshold loss removed? | nMOS passes strong 0/weak 1, pMOS passes strong 1/weak 0; a transmission gate combines them. |
| [MOS 4, page 18](04%20CMOS%20Switching%20Delay%20Power%20and%20Noise/README.md#page-18) | How much supply energy is used to charge $C_L$? | The supply delivers $C_LV_{DD}^2$; half is stored and half dissipated during charging. |
| [MOS 4, page 22](04%20CMOS%20Switching%20Delay%20Power%20and%20Noise/README.md#page-22) | Why define $V_{IL}$ and $V_{IH}$ at gain $-1$? | They separate noise-attenuating regions from the high-gain transition region. |
| [MOS 5, page 13](05%20CMOS%20Sizing%20and%20NAND%20Timing/README.md#page-13) | “Select the correct statement,” but options are absent from the photo. | The page records the correct noise-margin and delay relations needed to identify the option when supplied. |

## Verification stance

Handwritten notes are treated as the source to understand, not as automatically correct. Important physics and circuit claims are checked against the references in the root README. A note may be labeled:

- **Correct:** sound as written.
- **Clarify:** essentially correct but easy to misread because a sign, region, or assumption is implicit.
- **Corrected:** the revision text replaces a technically inaccurate statement and explains why.

This first iteration aims for complete page coverage and dependable understanding. Later iterations can add spaced-repetition status, exam questions, formula sheets, and mixed-topic tests without changing this source-preserving foundation.
