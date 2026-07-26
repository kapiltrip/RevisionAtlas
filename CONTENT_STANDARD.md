# Revision Atlas Content Standard

This file defines what “explained” means in Revision Atlas. A note is not complete merely because a formula, acronym, or diagram has been copied. The reader should be able to answer:

1. What does the term mean?
2. Why is it called that?
3. What is happening physically or in hardware?
4. Why is the concept used?
5. What is it commonly confused with?
6. Which trustworthy source supports the explanation?

## The term rule

Define a term when it is:

- a subject-defining idea, such as **static timing analysis**, **threshold voltage**, or **clock-domain crossing**;
- an acronym, such as **STA**, **FIFO**, **UART**, **CPOL**, or **RTL**;
- a symbol whose meaning or sign convention affects an equation;
- a tool or implementation word whose hardware meaning is not obvious, such as **inference**, **netlist**, or **generated clock**;
- easy to confuse with a nearby term, such as **baud rate versus bit rate**, **setup time versus hold time**, or **clock enable versus divided clock**.

Common English does not need a dictionary definition. A term already defined in the nearest parent README may be linked instead of copied, but a page must not rely on an unexplained acronym.

## Required explanation pattern

Use the smallest version of this pattern that fully explains the idea:

### `<Term> — <one-line meaning>`

- **Definition:** One technically precise sentence. Add an inline citation to a primary or authoritative source.
- **Plain meaning:** Restate it without relying on the term itself.
- **Physical / hardware meaning:** State what charge, voltage, state, edge, path, memory element, or implemented circuit is actually changing.
- **Why it matters:** Connect it to function, verification, power, performance, area, timing, or reliability.
- **Do not confuse it with:** Name the nearest misleading alternative.
- **Interview form:** A short answer that can be spoken accurately in 20–40 seconds when the term is interview-relevant.

Not every term needs six bullets. A compact table row is enough when the distinctions are simple. A difficult or disputed term should use the full card.

## “Why” questions are mandatory

Definitions must not stop at expansion of an acronym. For example:

- “STA means Static Timing Analysis” is incomplete.
- A complete explanation states what STA checks, why it is called static, why vector-based simulation cannot replace its path coverage, what STA cannot prove, and cites the timing-tool documentation.

Every topic review should actively search for questions of these forms:

- Why is it named this way?
- Why is this architecture used?
- Why is the alternative insufficient?
- Why does the equation use a maximum, minimum, addition, or subtraction?
- What physical event creates the result?
- Under what condition would the statement stop being true?

## Equation and diagram standard

For every important equation:

- define every symbol and unit;
- state the sign convention;
- state assumptions and operating region;
- explain the equation in words;
- check limiting or boundary cases;
- separate a device parameter from a path or system result.

For every important diagram:

- identify signal or current direction;
- identify who owns or drives each signal;
- state what changes at an edge or bias transition;
- distinguish logical abstraction from physical implementation;
- explain the conclusion the diagram is intended to prove.

## Citation standard

Use sources in this order:

1. standards and protocol specifications;
2. official tool, device, or IP documentation;
3. university course material and peer-reviewed papers;
4. established textbooks when an accessible authoritative edition is available.

Place the citation in the same paragraph or table row as the supported definition. A references list alone is not enough when the reader cannot tell which claim it supports.

Avoid using search-result snippets, unsourced blogs, forums, or generated summaries as authority. Handwritten notes are the source material being revised; they are not automatically the verification source.

## Required README layers

Every subject folder must have a `README.md` containing:

- subject purpose and boundary;
- topic map and prerequisite order;
- core-term dictionary with inline citations;
- source register;
- subject-specific revision method;
- completion criteria;
- next planned additions.

Every topic or unit README must contain:

- navigation back to its subject;
- local term key or link to the parent definitions;
- source-page or concept map;
- explanations and corrections;
- active-recall prompts;
- a short completion checkpoint.

Use [the subject template](templates/subject-template.md) when adding a new subject.

## Completion test

A subject is ready for revision only when all answers below are “yes”:

- Can a new learner expand and define every core acronym?
- Can the learner explain the physical or hardware meaning, not only repeat a sentence?
- Are “why this, not that?” distinctions answered?
- Are equations dimensionally and sign-convention clear?
- Are important claims cited next to their definitions?
- Can the subject be revised without opening an unrelated folder?
- Is there an active-recall test and a scheduled next review?
