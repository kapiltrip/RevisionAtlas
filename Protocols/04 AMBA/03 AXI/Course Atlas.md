# AXI Course Atlas - Complete Through Lesson 128

[Back to AXI](README.md) | [Lecture index](Lectures/README.md) | [Handwritten layer](Handwritten%20Notes.md) | [Instructor code](Code/README.md)

The **Communication series P3: AMBA AXI in Verilog** course is complete:
**128/128 lessons, 100%**. All nine instructor sections have their own lecture
file. The course contains 105 video lessons and 23 code-resource lessons.

## Study the sections in order

1. [Section 1 - Introduction to AXI](Lectures/Section%2001%20-%20Introduction%20to%20AXI.md)
   covers lessons 1-10: interface selection, the five memory-mapped channels,
   `VALID`/`READY`, teaching RTL, and handshake verification.
2. [Section 2 - AXI-Stream Interface Fundamentals](Lectures/Section%2002%20-%20AXI-Stream%20Interface%20Fundamentals.md)
   covers lessons 11-28: stream signals, byte qualifiers, stalls, Manager and
   Subordinate RTL, integration, and the Arm standards audit.
3. [Section 3 - AXI-Stream IPs](Lectures/Section%2003%20-%20AXI-Stream%20IPs.md)
   covers lessons 29-44: round-robin arbitration, packet-safe AXI-Stream
   arbitration, FIFOs, simultaneous push/pop, and waveforms.
4. [Section 4 - Getting Started with AXI4-Lite](Lectures/Section%2004%20-%20Getting%20Started%20with%20AXI4-Lite.md)
   covers lessons 45-54: transaction vocabulary, all five channels, response
   codes, and the exact AXI4-Lite signal boundary.
5. [Section 5 - Single Beat without Pipeline, Waveform Approach](Lectures/Section%2005%20-%20AXI4-Lite%20Single%20Beat%20without%20Pipeline%20-%20Waveform%20Approach.md)
   covers lessons 55-84: write-only and read-only AXI4-Lite endpoints,
   connection, verification, and AMD AXI Protocol Checker integration.
6. [Section 6 - Single Beat without Pipeline, FSM Approach](Lectures/Section%2006%20-%20AXI4-Lite%20Single%20Beat%20without%20Pipeline%20-%20FSM%20Approach.md)
   covers lessons 85-93: a combined read/write Manager organized as an FSM.
7. [Section 7 - AXI4-Lite GPIO](Lectures/Section%2007%20-%20AXI4-Lite%20GPIO%20Use%20Case.md)
   covers lessons 94-100: byte strobes, GPIO registers, input debouncing,
   read/write FSMs, and peripheral verification.
8. [Section 8 - AXI4 Full with Hardcoded Next Address](Lectures/Section%2008%20-%20AXI4%20Full%20-%20Hardcoded%20Next%20Address.md)
   covers lessons 101-112: full-AXI IDs, bursts, last markers, Manager and
   Subordinate control, and the declared fixed-address-step teaching profile.
9. [Section 9 - AXI4 Full with Burst-Based Address Generation](Lectures/Section%2009%20-%20AXI4%20Full%20-%20Burst-Based%20Address%20Generation.md)
   covers lessons 113-128: FIXED, INCR, and WRAP formulas, final endpoint
   implementations, connection, and burst verification.

## Capture archive

- [Day 01](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2001)
  contains the first course session and the handwritten round-robin page.
- [Day 02](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2002)
  contains the later AXI-Stream IP frames and lessons 45-49.
- [Day 03](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003)
  contains **123 original-source frames** for every video from lessons 50-128.

Day 03 images are untouched frames decoded from the highest-resolution lecture
streams. Every file is 1080 pixels high and 1920-2040 pixels wide, depending on
the source video. They were not cropped, zoomed, resized, or reconstructed, and
they contain no Namaste FPGA course sidebar. Two checkpoints are retained for
most videos; short agenda videos use one.

## Explanation standard

A frame is evidence, not a caption substitute. Its surrounding lesson notes
identify the visible control path and answer the questions that matter:

1. Which endpoint drives each signal?
2. Which rising-edge handshake accepts the item?
3. Which payload must remain stable during back-pressure?
4. Which register, counter, state, mux, or write-enable hardware is implied?
5. Which course assumption limits the teaching design?
6. Which AXI3, AXI4, AXI4-Lite, or AXI-Stream distinction prevents a naming
   mistake?
7. Which assertion, checker status, waveform event, or scoreboard comparison
   would prove the behavior?

The notes use prose, equations, and focused lists. Tables appear only when an
exact mapping—such as byte lane to strobe bit—benefits from one.

## Protocol authority and teaching-code policy

The frames establish the instructor's sequence and implementation. Protocol
claims are checked against the local
[Arm AXI-Stream specification](../../../_internal/Protocols/04%20AMBA/03%20AXI/sources/ARM-IHI-0051B-AMBA-AXI-Stream-Protocol-Specification.pdf)
and the official
[Arm AMBA AXI and ACE specification](https://developer.arm.com/-/media/Arm%20Developer%20Community/PDF/IHI0022H_amba_axi_protocol_spec.pdf).
Checker behavior is cross-checked against the
[AMD AXI Protocol Checker overview](https://docs.amd.com/r/en-US/pg101-axi-protocol-checker/Overview).

The [Code](Code/README.md) tree follows the instructor's module, signal, and
scenario naming. Comments inside each source state omitted, ignored, tied,
simplified, or assumed signals and their behavioral consequence. Those
comments clarify the exact teaching implementation; they do not replace it
with a different architecture.

## One trace rule for the whole course

For any AXI channel:

$$
fire=VALID\land READY
$$

Evaluate `fire` at the rising edge. `VALID=1` with `READY=0` is a stall. No
transfer occurs, and the complete channel payload remains stable until an
accepted edge.

## Completion audit

- Course UI verified at 100% with every section complete: 10/10, 18/18,
  16/16, 10/10, 30/30, 9/9, 7/7, 12/12, and 16/16.
- Lessons 50-128 contain no numbering gaps or duplicates.
- The remaining 79 lessons resolve to 64 videos and 15 code resources.
- Every remaining video has an original 1080p frame set.
- Every code resource is named in its matching section and mapped to the Code
  index.
