# How to Revise a Subject

This is the repository-wide revision method. It separates **understanding**, **retrieval**, and **scheduling** so revision does not become passive rereading.

## Before the first session

Open the subject README and answer four questions:

1. What is the subject trying to verify, predict, control, or implement?
2. Which earlier concepts are prerequisites?
3. What are its 10–20 core terms?
4. What evidence will show that revision worked: an explanation, derivation, waveform, code result, or solved problem?

If a core term cannot be defined, use the subject’s term dictionary before opening individual pages.

## One 45–60 minute subject session

| Block | Time | Closed-book action | Output |
|---|---:|---|---|
| Map | 5 min | State the topic sequence and causal chain | One spoken subject map |
| Terms | 10 min | Define core terms and distinguish confusing pairs | Mark each term `R`, `H`, or `M` |
| Deep retrieval | 20 min | Explain selected pages, equations, or circuits without notes | Missing links identified |
| Application | 10–15 min | Solve one numerical, waveform, design, or debugging question | One checked result |
| Compression | 5 min | Give a 30-second interview answer and one “when–because” sentence | Quick-recall answer |
| Queue | 2 min | Schedule weak items | Next review date |

`R` means recalled correctly and causally, `H` means hesitant or incomplete, and `M` means missed or materially wrong.

## The page retrieval loop

1. **Recognize — 20 seconds:** Name the physical situation or design problem shown.
2. **Retrieve — 60 seconds:** Explain the diagram, assumptions, governing relation, and conclusion without reading.
3. **Repair — 2 minutes:** Read the explanation and locate the missing link.
4. **Test — 30 seconds:** Answer the active-recall prompt closed-book.
5. **Compress — 15 seconds:** Say: “When ___ changes, ___ changes because ___.”

For a numerical page, also hide the final result and reproduce the sign, units, equation choice, and order of magnitude.

## Spaced review ladder

| Pass | Due | Main test | Move-on standard |
|---|---|---|---|
| 0 | Same day | Build the map and learn definitions | Every core term has a meaningful explanation |
| 1 | Day 1 | Recover the causal logic | At least 80% of prompts answered without notes |
| 2 | Day 3 | Recover equations, conditions, and signal ownership | Correct symbols, regions, edges, and signs |
| 3 | Day 7 | Mix nearby topics | Explain similarities, differences, and prerequisites |
| 4 | Day 14 | Interview/exam-speed recall | Core answer in 30–60 seconds; page answer in 60–90 seconds |
| 5 | Day 30 | Retention check | Revisit only remaining `H` and `M` items |

Queue rules:

- `M`: review tomorrow and solve a second example.
- `H`: review after three days and answer one contrast question.
- `R`: review after seven days, then move to Day 14/30.
- A second `M` is a signal to repair the prerequisite, not to reread the same paragraph repeatedly.

## Subject-specific retrieval tests

| Subject | Best closed-book test |
|---|---|
| MOSFET and CMOS | Draw the charge/band/circuit state, name the operating region, and explain the physical cause before using an equation. |
| Static Timing Analysis | Draw launch and capture edges, write arrival and required time separately, choose min/max delays, then determine the slack sign. |
| Protocols | Draw one complete frame and state signal ownership, sampling edge, acknowledgment, and error/termination behavior. |
| FIFO | Trace accepted reads/writes, pointer movement, occupancy, flags, wrap-around, and—if asynchronous—the owning clock domain. |
| Frequency Dividers | Write the state sequence, mark output edges, count input periods per output period, and calculate duty cycle separately from division ratio. |

## Completion criteria for one subject

A subject is revised—not merely read—when you can:

- define its core terms without circular wording;
- answer at least three “why” questions;
- derive or justify its central equation or state transition;
- distinguish the most commonly confused pair of concepts;
- solve one unseen application question;
- give a short interview explanation;
- identify the next due review without deciding again from scratch.

Use [tracking/README.md](tracking/README.md) as the subject dashboard and queue format.
