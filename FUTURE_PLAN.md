# Future Plan

Revision Atlas should grow by adding complete subject rooms, not by accumulating disconnected notes.

## Governing structure

```text
RevisionAtlas/
|-- README.md
|-- CONTENT_STANDARD.md
|-- REVISION_PLAN.md
|-- FUTURE_PLAN.md
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
|-- connections/
|   |-- concept-map.md
|   `-- prerequisite-map.md
`-- templates/
    `-- subject-template.md
```

Source scans remain untouched. Corrections and cited explanations live beside the evidence. Compressed notes are derived into `revision/`; they do not replace the full explanation.

## Subject admission gate

A new subject is added to the root index only after it has:

- a subject README using the repository template;
- a defined boundary and prerequisite path;
- a cited dictionary of core terms;
- at least one complete topic unit;
- active-recall questions and a completion checkpoint;
- an entry in the tracking dashboard;
- working local links and no missing source files.

This gate prevents a folder name from being mistaken for revision-ready coverage.

## Growth sequence

| Phase | Addition | Result |
|---:|---|---|
| 1 — current | Definition and citation layer for every present subject | Terms become explainable and interview-ready |
| 2 | Quick recall, formula sheets, pitfalls, and question banks | Deep notes become fast to retrieve |
| 3 | Review queue and dated revision log | The repository decides what is due |
| 4 | Mixed tests, concept map, and prerequisite map | Topics stop behaving like isolated chapters |
| 5 | Add new subjects through the admission gate | Coverage grows without structural drift |
| 6 | Periodic source and link audit | Definitions remain traceable and technically current |

## Candidate subject order

The order below follows prerequisite value for VLSI design and interview preparation:

1. Digital Design Fundamentals
2. Verilog and RTL Design
3. SystemVerilog and Design Verification
4. Computer Architecture
5. Physical Design
6. Design for Testability
7. Low-Power VLSI
8. Analog IC Design

Each addition should begin small: one trustworthy topic room, complete definitions, one source set, and one retrieval test. Expand only after that first unit passes the admission gate.

## Maintenance cycle

After every substantial addition:

1. update the root and subject indexes;
2. add new terms with inline authoritative citations;
3. add cross-subject prerequisite links;
4. run local Markdown/link checks;
5. update the tracking status and next action;
6. record a focused Git commit describing the content change.

Quarterly or after a major tool/specification release, recheck external documentation links and any version-sensitive tool guidance. Fundamental equations should not be rewritten merely because a web page moved; update the citation target while preserving the verified explanation.
