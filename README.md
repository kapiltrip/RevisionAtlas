# Revision Atlas

**Revision Atlas** maps every subject, topic, source page, explanation, doubt, and future revision path in one place.

This repository exists for one specific stage of learning: the concepts have already been learned, but they must become fast to recall, easy to connect, and difficult to forget.

> "Okay, so main task of this repository is to solve the problem that a called revision, right?"
>
> "Now, the basic problem is that I learned the concepts. Now, what I need is a pure revision tactic."
>
> "What we need is something that will help me revise."
>
> "For each page, screenshot each page, and then there will be perfect room in which first you are like explaining me each page on what it is written."
>
> "If I have ask some questions or if I am mention any two to do list then you need to acknowledge that as well for me."
>
> "You can use web search for that ... whatever I have written is correct."
>
> "This will be like a single resource where I will deal with revisions."
>
> "So that we can move forward with like the future plans regarding how the correct and optim as a structure will be look liking."

The wording above is preserved from Kapil's original description because it is the design brief for the repository.

## Repository controls

The root is the management layer for every subject:

| Open this | Use it for |
|---|---|
| [Current subjects](#start-here) | Navigate all current subjects and see their scope |
| [Content standard](CONTENT_STANDARD.md) | Define technical terms, answer “why” questions, and cite meanings consistently |
| [How to revise a subject](REVISION_PLAN.md) | Run retrieval sessions and schedule Day 1/3/7/14/30 reviews |
| [Subject dashboard](tracking/README.md) | See current coverage, next actions, and the `R/H/M` review queue |
| [Future plan](FUTURE_PLAN.md) | Grow the structure and add subjects without losing consistency |
| [Subject template](templates/subject-template.md) | Create a complete subject README with definitions, sources, and revision criteria |

The non-negotiable content rule is: **a core term is not complete until its precise meaning, plain meaning, physical or hardware meaning, nearest confusion, and authoritative source are clear.** The complete rule and its shorter formats are in the [content standard](CONTENT_STANDARD.md).

## Start here

Revision Atlas currently has six independent subjects:

| Subject | Current coverage | Revision entry point |
|---|---|---|
| [MOSFET and CMOS](MOSFET%20and%20CMOS/README.md) | Five source-linked revision notebooks covering 110 pages | Device physics, CMOS behavior, delay, power, noise, and sizing |
| [FIFO](FIFO/README.md) | Architecture guide and starter RTL | RAM, synchronous FIFO, verification, timing, asynchronous FIFO, and CDC reasoning |
| [Frequency Dividers](Frequency%20Dividers/README.md) | 13 source-linked notebook pages | Divider state sequences, waveforms, duty cycle, and fractional-divider circuits |
| [Frequency Divider RTL Practice](Programmable%20Frequency%20Divider/README.md) | Separate `/2` through `/5` RTL and self-checking simulations | One clear divider per file, selectable duty cycles, and a Vivado verification roadmap |
| [Protocols](Protocols/README.md) | I2C, SPI, UART, and AMBA/AHB | Signal ownership, framing, clocking, pipelined buses, and RTL timing |
| [Static Timing Analysis](Static%20Timing%20Analysis/README.md) | Storage elements through complete setup/hold path analysis | Definitions, timing equations, sign conventions, and worked paths |

The [Protocols subject](Protocols/README.md) contains 16 source-linked handwritten pages on I2C, SPI, and UART, plus an AMBA branch whose first AHB chapter includes the official Arm specification, FSM correction, and verified RTL.

The [Static Timing Analysis subject](Static%20Timing%20Analysis/README.md) adds 25 source-linked handwritten pages on transmission-gate storage, setup and hold analysis, arrival/required time, slack, clock skew, maximum frequency, and worked timing problems. Every visible red-marker doubt is answered beside its source page.

The five notebooks form one continuous MOS/VLSI sequence. Every source page is rendered directly inside its matching revision file, followed immediately by an explanation and an active-recall prompt.

| Revision file | Pages | Main coverage |
|---|---:|---|
| [MOS 1 - MOS Capacitor Fundamentals](MOSFET%20and%20CMOS/01%20MOS%20Capacitor%20Fundamentals/README.md) | 24 | Work function, energy bands, accumulation, depletion, inversion, surface potential, depletion width |
| [MOS 2 - Non-Ideal MOS and MOSFET Regions](MOSFET%20and%20CMOS/02%20Non-Ideal%20MOS%20and%20MOSFET%20Regions/README.md) | 24 | Oxide charge, flat-band and threshold voltage, C-V behavior, MOSFET regions |
| [MOS 3 - MOSFET Models and CMOS Inverter](MOSFET%20and%20CMOS/03%20MOSFET%20Models%20and%20CMOS%20Inverter/README.md) | 24 | Transfer curves, transconductance, channel-length modulation, capacitances, CMOS switching point |
| [MOS 4 - CMOS Switching Delay, Power, and Noise](MOSFET%20and%20CMOS/04%20CMOS%20Switching%20Delay%20Power%20and%20Noise/README.md) | 24 | Inverter regions, RC delay, pass transistors, power, noise margins, device ratios |
| [MOS 5 - CMOS Sizing and NAND Timing](MOSFET%20and%20CMOS/05%20CMOS%20Sizing%20and%20NAND%20Timing/README.md) | 14 | Strength ratio, transistor sizing, NAND delay, average-current timing, power-delay trade-off |

**Coverage:** 110 of 110 PDF pages have an inline page image and a matching explanation space. `mos1` page 6 is genuinely blank; it is kept so page numbering stays faithful to the source.

## The revision tactic

Use each page as a small retrieval cycle. Do not reread the entire notebook passively. For a complete subject session, including term recall, application, scheduling, and subject-specific tests, use [How to Revise a Subject](REVISION_PLAN.md).

1. **Recognize - 20 seconds.** Look only at the rendered page. Name the page's topic and the physical situation being analyzed.
2. **Retrieve - 60 seconds.** Without reading the explanation, say the diagram, assumptions, governing relation, and final conclusion aloud.
3. **Repair - 2 minutes.** Read **What this page is doing**. Compare it with what you recalled and identify the missing link, not merely the missing sentence.
4. **Test - 30 seconds.** Answer the **Active recall** question without looking back. If the answer is incomplete, mark the page for the next session.
5. **Compress - 15 seconds.** End with one sentence in the form: `When _____ changes, _____ changes because _____.`

For numerical pages, add one more step: cover the final value and reproduce the sign, units, and order of magnitude before checking the calculation.

## Review schedule

| Pass | When | Goal | Standard for moving on |
|---|---|---|---|
| 0 | Same day | Build the page map | You can state what every diagram is trying to prove |
| 1 | Next day | Recover the logic | At least 80% of active-recall prompts answered without notes |
| 2 | Day 3 | Recover equations | Correct region, sign convention, and governing equation |
| 3 | Day 7 | Mix topics | Explain links such as MOS capacitor -> threshold -> channel -> inverter |
| 4 | Day 14 | Exam-speed recall | About 60-90 seconds per page |
| 5 | Day 30 | Retention check | Revisit only pages that still produce hesitation or sign errors |

Use three marks in a notebook or tracker: `R` = recalled, `H` = hesitant, `M` = missed. Review all `M` pages tomorrow, `H` pages after three days, and `R` pages after one week. This keeps time concentrated on weak retrieval instead of familiar-looking pages.

## The conceptual spine

The pages are not five disconnected files. Revise them as one causal chain:

`gate voltage -> surface potential -> depletion/inversion charge -> threshold voltage -> channel current -> CMOS transfer curve -> load-capacitor charging -> delay, power, and noise margin`

If a later result feels arbitrary, walk left along this chain until the physical cause becomes clear.

## Current repository layout

```text
RevisionAtlas/                          # all-subject management root
|-- README.md                           # purpose, method, roadmap
|-- CONTENT_STANDARD.md                 # definition and citation rules
|-- REVISION_PLAN.md                    # subject revision method
|-- FUTURE_PLAN.md                      # growth and subject-admission plan
|-- .gitignore
|-- tracking/
|   `-- README.md                       # live coverage and review-queue format
|-- templates/
|   `-- subject-template.md             # required structure for new subjects
|-- FIFO/
|   |-- README.md                       # FIFO design and verification approach
|   |-- src/                            # FIFO design source
|   |-- sim/                            # FIFO testbench source
|   `-- vivado/                         # Vivado project
|-- Frequency Dividers/
|   |-- README.md                       # 13 page-linked explanations, corrections, and answers
|   |-- sources/                        # untouched 13-page frequency-divider notebook
|   `-- images/                         # readable page-01 through page-13 images
|-- Programmable Frequency Divider/
|   |-- README.md                       # standalone /2 through /5 coding plan and status
|   |-- src/                            # one RTL file per divide ratio
|   `-- sim/                            # one self-checking testbench per divide ratio
|-- MOSFET and CMOS/
|   |-- README.md                       # subject map + question/TODO register
|   |-- sources/
|   |   `-- mos1.pdf ... mos5.pdf
|   |-- 01 MOS Capacitor Fundamentals/  # README + 24 page images
|   |-- 02 Non-Ideal MOS and MOSFET Regions/
|   |-- 03 MOSFET Models and CMOS Inverter/
|   |-- 04 CMOS Switching Delay Power and Noise/
|   `-- 05 CMOS Sizing and NAND Timing/
|-- Protocols/
|   |-- README.md                       # serial protocols plus AMBA topic index
|   |-- sources/                        # untouched 16-page handwritten scan
|   |-- 01 I2C/                         # pages 1-5 + deep explanations
|   |-- 02 SPI/                         # pages 6-8 + deep explanations
|   |-- 03 UART/                        # pages 9-16 + deep explanations
|   `-- 04 AMBA/
|       `-- 01 AHB/                     # spec, FSM notes, RTL, TB, future handwritten pages
`-- Static Timing Analysis/
    |-- README.md                       # 25 page-linked STA explanations and answers
    |-- sources/                        # untouched 24-page scan + original page 25 photo
    `-- images/                         # readable page-01 through page-25 images
```

The two sideways scans in `mos2` (pages 17 and 18) are rotated only in the module's `images/` folder for readable revision. The original PDF is unchanged.

## Where Revision Atlas is going

The current structure is the **source-preserving explanation layer plus a cited term layer**. The [Future Plan](FUTURE_PLAN.md) is the controlling roadmap for reusable revision layers and new subjects.

```text
Revision Atlas/
|-- README.md
|-- <Subject>/                          # root-level subject -> topic -> unit knowledge tree
|   |-- README.md                       # subject coverage and navigation
|   `-- <Topic or Unit>/
|       |-- README.md                   # deep source-page explanations
|       |-- sources/                    # untouched PDFs, slides, notes
|       |-- images/                     # readable page/screenshot evidence
|       `-- revision/
|           |-- quick-recall.md         # compressed last-minute revision
|           |-- formula-sheet.md        # formulas, conditions, units
|           |-- questions.md            # doubts, answers, viva/exam prompts
|           |-- pitfalls.md             # mistakes and sign/concept traps
|           `-- tests/                  # mixed and spaced-recall tests
|-- tracking/
|   |-- dashboard.md                    # subject/topic revision status
|   |-- review-queue.md                 # due pages: missed, hesitant, recalled
|   `-- revision-log.md                 # dated review history
|-- connections/
|   |-- concept-map.md                  # links across subjects and topics
|   `-- prerequisite-map.md             # what must be recalled first
`-- templates/
    |-- subject-template.md
    |-- topic-template.md
    `-- page-discussion-template.md
```

### Planned iterations

| Iteration | Addition | Purpose |
|---:|---|---|
| 1 - complete | Source images, deep page explanations, corrections, questions | Build a trustworthy understanding layer |
| 2 - complete for current scope | Cited definitions, “why” standard, root controls, and subject dashboard | Make terminology explainable and growth consistent |
| 3 - next | Quick recall, formula sheet, pitfalls, and question bank | Turn understanding into fast retrieval |
| 4 | Mixed tests and cross-topic links | Prevent revision from becoming chapter-wise memorization |
| 5 | Reusable templates and more subjects | Grow Revision Atlas without structural drift |

The rule for future nodes is simple: **sources remain untouched; explanations stay beside evidence; compressed revision material is derived into a separate `revision/` layer; progress belongs in the global `tracking/` layer.**

## Reference checks

The explanations use the notebook sequence as the primary source and were cross-checked against:

- [MIT OpenCourseWare - MOS Capacitors I](https://ocw.mit.edu/courses/6-012-microelectronic-devices-and-circuits-fall-2009/resources/mit6_012f09_lec09/) for accumulation, depletion, inversion, flat-band voltage, and threshold voltage.
- [MIT OpenCourseWare - Computation Structures, MOSFETs and CMOS](https://ocw.mit.edu/courses/6-004-computation-structures-spring-2017/pages/c3/c3s1/) for MOSFET switching, CMOS operation, RC transitions, and noise margins.
- [MIT OpenCourseWare - MOSFET channel-length modulation recitation](https://ocw.mit.edu/courses/6-012-microelectronic-devices-and-circuits-spring-2009/resources/mit6_012s09_rec10/) for the finite saturation slope and output-resistance model.
- [MIT OpenCourseWare - CMOS inverter lecture](https://ocw.mit.edu/courses/6-012-microelectronic-devices-and-circuits-fall-2005/resources/lec14/) for noise margin, propagation delay, and dynamic power.
- [MIT OpenCourseWare - Design tradeoffs and CMOS dynamic power](https://ocw.mit.edu/courses/6-004-computation-structures-spring-2017/pages/c8/c8s1/) for capacitive switching energy and power-performance trade-offs.
- [NPTEL - CMOS inverter rise and fall times](https://archive.nptel.ac.in/content/storage2/courses/117101058/Slides/16.3.htm) for load-capacitor trajectories and propagation-delay regions.
- [NPTEL - CMOS inverter characteristics](https://archive.nptel.ac.in/content/storage2/courses/117101058/Slides/15.4.htm) for the inverter's operating regions and switching point.

These references are for resolving ambiguity and checking physical meaning. When symbols differ from the notebook, the revision pages keep the notebook's notation and explicitly call out the convention.
