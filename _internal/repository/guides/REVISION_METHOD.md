# How to Revise a Subject

[Guide index](README.md) | [Back to RevisionSolved](../../../README.md)

This is the repository-wide revision method. It separates **understanding**,
**retrieval**, **application**, and **scheduling** so revision does not collapse
into passive rereading.

## Before the first session

Open the subject README and answer four questions:

1. What is the subject trying to verify, predict, control, or implement?
2. Which earlier concepts are prerequisites?
3. What are its 10–20 core terms?
4. What evidence will show that revision worked: an explanation, derivation,
   waveform, code result, or solved problem?

If a core term cannot be defined, repair that term before opening individual
pages. Otherwise later equations and waveforms will feel familiar without
being retrievable.

## One 45–60 minute subject session

1. **Map — 5 minutes.** State the topic order and causal chain aloud. The
   output is one spoken subject map.
2. **Terms — 10 minutes.** Define the core terms and contrast confusing pairs.
   Mark each answer `R`, `H`, or `M`.
3. **Deep retrieval — 20 minutes.** Explain selected pages, equations,
   circuits, or waveforms without notes. Record the missing link behind every
   incomplete answer.
4. **Application — 10–15 minutes.** Solve one numerical, timing trace, RTL
   design, or debugging question and check the result.
5. **Compression — 5 minutes.** Give a 30-second interview answer and one
   `When _____ changes, _____ changes because _____.` sentence.
6. **Queue — 2 minutes.** Give every weak item a next review date before ending
   the session.

`R` means recalled correctly and causally. `H` means hesitant, incomplete, or
correct only after a hint. `M` means missed or materially wrong.

## The page retrieval loop

1. **Recognize — 20 seconds:** name the physical situation or design problem
   shown.
2. **Retrieve — 60 seconds:** explain the diagram, assumptions, governing
   relation, and conclusion without reading.
3. **Repair — 2 minutes:** read the explanation and locate the missing causal
   link.
4. **Test — 30 seconds:** answer the active-recall prompt closed-book.
5. **Compress — 15 seconds:** say
   `When _____ changes, _____ changes because _____.`

For a numerical page, also hide the final result and reproduce the sign, units,
equation choice, and order of magnitude.

## Spaced review ladder

- **Pass 0 — same day:** build the map and learn definitions. Move on when
  every core term has a meaningful explanation.
- **Pass 1 — Day 1:** recover the causal logic. Aim to answer at least 80% of
  prompts without notes.
- **Pass 2 — Day 3:** recover equations, conditions, signal ownership, regions,
  edges, and sign conventions.
- **Pass 3 — Day 7:** mix nearby topics and explain their similarities,
  differences, and prerequisites.
- **Pass 4 — Day 14:** reach interview or exam speed: 30–60 seconds for a core
  answer and 60–90 seconds for a page explanation.
- **Pass 5 — Day 30:** retest retention and revisit only the remaining `H` and
  `M` items.

Queue weak material by result:

- `M`: review tomorrow and solve a second example;
- `H`: review after three days and answer one contrast question;
- `R`: review after seven days, then move to Day 14 and Day 30;
- a second `M`: repair the prerequisite instead of rereading the same paragraph.

## Subject-specific closed-book tests

- **MOSFET and CMOS:** draw the charge, band, or circuit state; name the valid
  operating region; explain the physical cause; then use the equation.
- **Static Timing Analysis:** draw launch and capture edges, write arrival and
  required time separately, choose min/max delays, and determine the slack
  sign.
- **Protocols:** draw one complete transfer and state signal ownership,
  sampling edge, acknowledgment, response, and termination behavior.
- **FIFO:** trace accepted reads and writes, pointer movement, occupancy, flags,
  wraparound, and—if asynchronous—the clock domain that owns each state item.
- **Frequency Dividers:** write the state sequence, mark output edges, count
  input periods per output period, and calculate duty cycle separately from the
  division ratio.

## Completion criteria for one subject

A subject is revised—not merely read—when you can:

- define its core terms without circular wording;
- answer at least three “why” questions;
- derive or justify its central equation or state transition;
- distinguish the most commonly confused pair of concepts;
- solve one unseen application question;
- give a short interview explanation;
- identify the next due review without deciding again from scratch.

Use the [coverage and review queue](../tracking/README.md) to record the result.
