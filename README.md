# RevisionSolved

RevisionSolved is Kapil's source-preserving revision repository. The **Revision
Atlas** inside it connects every notebook page, course frame, technical
explanation, correction, recall question, and implementation exercise so a
subject can be revised without reconstructing the learning path each time.

The repository is for concepts that have already been studied once. Its job is
to turn that first exposure into accurate recall, causal understanding, and
usable hardware reasoning.

> Read the evidence first, explain it aloud, repair the missing reasoning, and
> then test recall without looking back.

## Start revising

- [MOSFET and CMOS](MOSFET%20and%20CMOS/README.md) contains five linked
  notebooks and 110 page discussions covering MOS electrostatics, MOSFET
  operation, CMOS switching, delay, power, noise, and sizing.
- [Static Timing Analysis](Static%20Timing%20Analysis/README.md) contains 25
  source-linked pages from storage elements through setup/hold equations,
  clock skew, slack, maximum frequency, and worked paths.
- [Protocols](Protocols/README.md) contains I2C, SPI, UART, and the AMBA branch.
  AMBA is separated into AHB, APB, and AXI so their transfer rules cannot be
  accidentally mixed.
- [Frequency Dividers](Frequency%20Dividers/README.md) contains 13 handwritten
  pages with state sequences, waveforms, duty-cycle reasoning, and integer or
  fractional divider circuits.
- [Frequency Divider RTL Practice](Programmable%20Frequency%20Divider/README.md)
  keeps the `/2` through `/5` RTL and self-checking simulations separate from
  the theory notebook.
- [FIFO](FIFO/README.md) develops the interface contract, storage model,
  pointers, flags, simultaneous operations, verification, and the path from a
  synchronous FIFO to an asynchronous CDC-safe design.

## Current AXI course boundary

The [AXI chapter](Protocols/04%20AMBA/03%20AXI/README.md) is organized by the
course's actual sections. Its video layer is complete through lesson **49,
Understanding Write data channel**:

- Section 1: 10/10 lessons;
- Section 2: 18/18 lessons;
- Section 3: 16/16 lessons;
- Section 4: 5/10 lessons, stopped deliberately before lesson 50.

Every saved course frame is followed by the relevant mechanism, protocol rule,
implementation consequence, correction, or verification check. The new
captures through lesson 49 are true 1535 x 686 full-screen video frames.

## How the repository is organized

```text
RevisionSolved/
|-- README.md
|-- guides/                              # standards, method, roadmap, work log
|-- tracking/                            # current coverage and review queue
|-- templates/                           # structure for a new subject
|-- FIFO/
|-- Frequency Dividers/
|-- Programmable Frequency Divider/
|-- MOSFET and CMOS/
|-- Protocols/
`-- Static Timing Analysis/
```

Each mature learning branch follows the same local pattern:

- `README.md` is the entry point and deep explanation layer;
- `sources/` preserves the original PDF, specification, or notebook;
- `images/` keeps readable page renders or course frames beside the notes;
- `src/` and `sim/` are used only when the topic has RTL and verification;
- subfolders represent real chapters or course sections, not arbitrary batches
  of files.

Subject folders stay at the root on purpose. Moving them under another wrapper
would add navigation depth, break many local links, and risk absolute paths in
the Vivado project without improving revision.

## What a deep explanation must contain

A note is not complete because it repeats a slide or expands an acronym. For
the concept visible on a page or frame, the explanation should establish:

1. the precise meaning and the plain meaning;
2. the physical event, state change, sampled edge, path, or inferred hardware;
3. why the mechanism is used and what fails if its rule is violated;
4. assumptions, signal ownership, units, signs, and boundary conditions;
5. the nearest confusing alternative and the exact distinction;
6. an authoritative source when the claim is protocol- or tool-defined;
7. one recall, waveform, derivation, or verification test that proves the idea
   was understood.

The full writing rule is in the [content standard](guides/CONTENT_STANDARD.md).

## One revision cycle

1. **Recognize:** look only at the source page or screenshot and name the
   problem it is solving.
2. **Retrieve:** explain the diagram, assumptions, governing relation, and
   conclusion without reading the notes.
3. **Repair:** read the discussion and identify the missing causal link—not
   merely a forgotten sentence.
4. **Test:** answer the active-recall prompt, solve the numerical, or trace the
   waveform closed-book.
5. **Compress:** finish with `When _____ changes, _____ changes because _____.`

Mark the result `R` for recalled, `H` for hesitant, or `M` for missed. The
[revision method](guides/REVISION_METHOD.md) defines the full 45–60 minute
session and Day 1/3/7/14/30 review ladder.

## Repository guides

- [Guide index](guides/README.md) explains which management document to use.
- [Content standard](guides/CONTENT_STANDARD.md) defines the depth, equation,
  diagram, and citation requirements.
- [Revision method](guides/REVISION_METHOD.md) defines closed-book sessions and
  spaced retrieval.
- [Coverage and review queue](tracking/README.md) records what is ready and what
  should be reviewed next.
- [Roadmap](guides/ROADMAP.md) controls future subject growth.
- [Workflow notes](guides/WORKFLOW_NOTES.md) preserve solved setup problems and
  reliable local workflows.
- [Subject template](templates/subject-template.md) is the starting point for a
  new complete subject room.

## Repository rule

Original sources remain unchanged. Corrections and deep explanations stay next
to their evidence. Quick-recall material may later compress those explanations,
but it must never replace them. Navigation uses prose and short lists unless a
table materially improves a signal mapping, timing trace, comparison, or exact
state relationship.
