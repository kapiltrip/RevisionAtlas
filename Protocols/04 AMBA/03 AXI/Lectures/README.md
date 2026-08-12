# AXI lecture notes

[Back to AXI](../README.md) | [Instructor code](../Code/README.md)

These nine files mirror the instructor's nine top-level sections. Every lesson
number appears once, in course order. All 105 video lessons keep meaningful
original-source frames beside their explanations. Downloadable lessons point
to the separately organized instructor code instead of introducing a different
implementation.

The same nine files also contain Kapil's handwritten pages. Within each matching
lesson, the order is the original lecture screenshot, the detailed lecture
explanation, the handwritten page, and then a page-specific explanation. No
separate combined chapter file is required.

## Section order

1. [Section 1 - Introduction to AXI](Section%2001%20-%20Introduction%20to%20AXI.md),
   lessons 1-10.
2. [Section 2 - AXI-Stream Interface Fundamentals](Section%2002%20-%20AXI-Stream%20Interface%20Fundamentals.md),
   lessons 11-28.
3. [Section 3 - Using AXI-Stream to Build IP](Section%2003%20-%20AXI-Stream%20IPs.md),
   lessons 29-44.
4. [Section 4 - Getting Started with AXI4-Lite](Section%2004%20-%20Getting%20Started%20with%20AXI4-Lite.md),
   lessons 45-54.
5. [Section 5 - AXI4-Lite Waveform Approach](Section%2005%20-%20AXI4-Lite%20Single%20Beat%20without%20Pipeline%20-%20Waveform%20Approach.md),
   lessons 55-84.
6. [Section 6 - AXI4-Lite FSM Approach](Section%2006%20-%20AXI4-Lite%20Single%20Beat%20without%20Pipeline%20-%20FSM%20Approach.md),
   lessons 85-93.
7. [Section 7 - AXI4-Lite GPIO](Section%2007%20-%20AXI4-Lite%20GPIO%20Use%20Case.md),
   lessons 94-100.
8. [Section 8 - AXI4 with Hardcoded Next Address](Section%2008%20-%20AXI4%20Full%20-%20Hardcoded%20Next%20Address.md),
   lessons 101-112.
9. [Section 9 - AXI4 Burst-Based Address Generation](Section%2009%20-%20AXI4%20Full%20-%20Burst-Based%20Address%20Generation.md),
   lessons 113-128.

## Reading rule

Treat each screenshot as evidence for the explanation below it. For every AXI
channel, acceptance occurs only on a rising edge with `VALID && READY`. During
a stall, the complete offered payload remains stable. When a course design
omits or simplifies a protocol feature, the note states the boundary and the
matching source comment records its behavioral consequence.
