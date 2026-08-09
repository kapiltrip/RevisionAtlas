# Repository Roadmap

[Guide index](README.md) | [Back to RevisionSolved](../README.md)

RevisionSolved grows by adding complete subject rooms, not by accumulating
disconnected notes.

## Governing structure

```text
RevisionSolved/
|-- README.md
|-- guides/
|   |-- README.md
|   |-- CONTENT_STANDARD.md
|   |-- REVISION_METHOD.md
|   |-- ROADMAP.md
|   `-- WORKFLOW_NOTES.md
|-- <Subject>/
|   |-- README.md
|   `-- <Topic or Unit>/
|       |-- README.md
|       |-- sources/
|       |-- images/
|       `-- revision/
|           |-- quick-recall.md
|           |-- formula-sheet.md
|           |-- questions.md
|           |-- pitfalls.md
|           `-- tests/
|-- tracking/
|   `-- README.md
`-- templates/
    `-- subject-template.md
```

Source scans remain untouched. Corrections and cited explanations live beside
the evidence. Compressed notes are derived into `revision/`; they do not replace
the full explanation.

## Subject admission gate

A new subject enters the root index only after it has:

- a subject README using the repository template;
- a defined boundary and prerequisite path;
- a cited dictionary of core terms;
- at least one complete topic unit;
- active-recall questions and a completion checkpoint;
- an entry in the tracking dashboard;
- working local links and no missing source files.

This gate prevents a folder name from being mistaken for revision-ready
coverage.

## Growth sequence

1. **Definition and citation layer — current:** make every present subject
   explainable and interview-ready.
2. **Retrieval layer:** derive quick-recall sheets, formula sheets, pitfalls,
   and question banks from the deep notes.
3. **Scheduling layer:** maintain the review queue and a dated revision log so
   due work is explicit.
4. **Integration layer:** add mixed tests, a concept map, and a prerequisite map
   so chapters stop behaving like isolated facts.
5. **Expansion layer:** add new subjects only through the admission gate.
6. **Maintenance layer:** periodically audit sources, local links, and
   version-sensitive guidance.

## Candidate subject order

The likely order follows prerequisite value for VLSI design and interviews:

1. Digital Design Fundamentals
2. Verilog and RTL Design
3. SystemVerilog and Design Verification
4. Computer Architecture
5. Physical Design
6. Design for Testability
7. Low-Power VLSI
8. Analog IC Design

Each addition begins with one trustworthy topic room, one source set, complete
definitions, and one retrieval test. Expand only after that unit passes the
admission gate.

## Maintenance cycle

After every substantial addition:

1. update the root and subject indexes;
2. add new terms with inline authoritative citations;
3. add cross-subject prerequisite links;
4. run local Markdown, link, image, and heading checks;
5. update coverage and the next action;
6. commit one focused change set when the user requests publication.

After a major tool or specification release, recheck external documentation
links and version-sensitive guidance. Fundamental equations should not be
rewritten merely because a web page moved; update the citation target while
preserving the verified explanation.
