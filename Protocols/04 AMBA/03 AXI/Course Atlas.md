# AXI Course Atlas — Progress Through Lesson 49

[Back to AXI](README.md) | [Back to AMBA](../README.md) | [Handwritten layer](Handwritten%20Notes.md)

The course notes follow the instructor's top-level sections. Each section file
keeps its lesson order, full-screen evidence, explanation, code-resource notes,
protocol corrections, and recall checks together. Capture folders remain
day-wise so the learning session and source boundary stay recoverable.

## Current course boundary

- Course: **Communication series P3: AMBA AXI in Verilog**.
- Recorded progress at the checked boundary: **38.28%**.
- Complete: Sections 1–3 and the first 5 of 10 lessons in Section 4.
- Stop after: **49. Understanding Write data channel**.
- Excluded for now: **50. Understanding Write response channel** and every
  later lesson.

## Study the sections in order

1. [Section 1 — Introduction to AXI](Section%2001%20-%20Introduction%20to%20AXI.md)
   is complete, 10/10. It builds interface selection, the five memory-mapped
   channels, the acceptance edge, handshake RTL, and waveform verification.
2. [Section 2 — AXI-Stream Interface Fundamentals](Section%2002%20-%20AXI-Stream%20Interface%20Fundamentals.md)
   is complete, 18/18. It develops signals, byte qualifiers, waveforms,
   Transmitter/Receiver RTL, integration, and the Arm standards audit.
3. [Section 3 — Using AXI-Stream to Build IP](Section%2003%20-%20AXI-Stream%20IPs.md)
   is complete, 16/16. It derives the round-robin arbiter, packet-safe stream
   arbitration, FIFO storage, simultaneous operations, and verification.
4. [Section 4 — Getting Started with AXI4-Lite](Section%2004%20-%20Getting%20Started%20with%20AXI4-Lite.md)
   is complete through 5/10. It distinguishes transaction, burst, beat, and
   channel transfer; then covers write address, IDs, write data, and byte
   strobes through lesson 49.

## Capture storage

- [Day 01](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2001) contains lessons 1–33.
- [Day 02](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2002) contains lessons 34–49.

The Day 02 lesson frames are 1535 x 686 full-screen video captures. A section
may use several frames from one lesson when the diagram, RTL, and waveform each
carry different information; they share an explanation only when they form one
continuous reasoning sequence.

## Explanation standard for every frame

A screenshot is evidence, not an explanation. The surrounding discussion must
answer whichever of these questions the frame raises:

1. What does each visible signal, state, counter, or field mean?
2. Who drives it and on which sampled edge does it matter?
3. What event changes state or accepts data?
4. What must remain stable during a stall?
5. What hardware is inferred by the shown RTL?
6. Which lecture shortcut needs a specification-level correction?
7. Which assertion, trace, or scoreboard result would prove the behavior?

This keeps the atlas deep without repeating a generic paragraph under every
image.

## The trace rule used everywhere

For any AXI or AXI-Stream channel:

$$
\text{fire}=\text{VALID}\land\text{READY}
$$

Evaluate `fire` at the rising edge. `VALID=1` with `READY=0` is a stall, not a
transfer; the source must keep that channel's payload and control information
stable until an accepted edge.

## Authority and correction policy

The course frames establish the teaching sequence. Protocol claims are checked
against the local
[Arm AXI-Stream specification](../../../_internal/Protocols/04%20AMBA/03%20AXI/sources/ARM-IHI-0051B-AMBA-AXI-Stream-Protocol-Specification.pdf)
and the official
[AMBA AXI and ACE Protocol Specification](https://developer.arm.com/-/media/Arm%20Developer%20Community/PDF/IHI0022H_amba_axi_protocol_spec.pdf).
When a lecture diagram mixes AXI3, AXI4, and AXI4-Lite signals, the matching
section labels the difference instead of silently copying the port list.

## Updating from the next lesson

1. Confirm the newly completed lesson count in the live course.
2. Capture in a separate background window and stop at the exact checked item.
3. Save real full-screen video frames in the current day folder with meaningful
   names.
4. Add each frame immediately before its page-specific explanation.
5. Re-run image-dimension, link, heading, math, and Git-diff checks before any
   requested commit.
