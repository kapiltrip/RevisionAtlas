# AMBA Notes

[Back to AMBA](../README.md)

This is the single home for source-derived AMBA material. Protocol chapters
stay short enough for revision; these notes preserve the detailed page-by-page
explanations, lesson captures, corrections, and recall prompts.

## Open a note set

- [AHB notes](AHB.md): bus roles, pipelined phases, waits, bursts, responses,
  manager RTL, and verification reasoning.
- [APB notes](APB.md): SETUP/ACCESS timing, waits, errors, back-to-back
  transfers, bridge behavior, and controller design.
- [AXI Day 01 notes](AXI%20Day%2001.md): AXI-Stream handshakes, source and
  sink RTL, stalls, integration, and round-robin arbitration.
- [AXI question notes](AXI%20Questions.md): focused answers linked to the
  relevant AXI lesson and protocol rule.

## Directory layout

```text
notes/
├── README.md
├── AHB.md
├── APB.md
├── AXI Day 01.md
├── AXI Questions.md
├── images/
│   ├── AHB/{pages,lecture}/
│   ├── APB/{pages,lecture}/
│   └── AXI/{Day 01,Day 02}/
└── sources/
```

`images/` holds page and lesson evidence referenced by the notes. `sources/`
holds the unchanged original PDFs. Official Arm specifications remain beside
their protocol chapters under `01 AHB/sources`, `02 APB/sources`, and
`03 AXI/sources`.

## Original source PDFs

- [24-page AHB/APB notebook](sources/ahb-apb-notebook-24-pages.pdf)
- [11-page AHB/APB iPad notes](sources/ahb-apb-ipad-notes-11-pages.pdf)
- [Three-page duplicate reference scan](sources/duplicate-reference-pages-3-pages.pdf)
