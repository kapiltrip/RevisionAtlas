# AXI handwritten layer

[Back to AXI](README.md) | [Course atlas](Course%20Atlas.md) | [Back to AMBA](../README.md)

This is Layer 2 of the AXI chapter. It preserves Kapil's handwritten AXI notes,
maps each page to the exact course lesson, and places the verified solution
beside the original question.

## Intake status

- One handwritten page is present; its original image is preserved below.
- The page maps directly to
  [Video 31 — Round-robin arbiter part 2](Section%2003%20-%20AXI-Stream%20IPs.md#video-31---round-robin-arbiter-part-2).
- Any later AXI-Stream claim will be checked against
  [Arm IHI 0051B](../../../_internal/Protocols/04%20AMBA/03%20AXI/sources/ARM-IHI-0051B-AMBA-AXI-Stream-Protocol-Specification.pdf).

## Handwritten-page index

- [Page 1 — Round-robin next-state priority](#page-1---why-does-s1-check-req2-first):
  why `s1` tests `req2` before `req1`, fully solved below.

## Page 1 - Why does `s1` check `req2` first?

![Handwritten round-robin FSM question asking why state s1 checks req2 first](../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2001/round-robin-fairness-question-s1-priority.jpg)

### What is written on the page

The page contains the combinational next-state decoder:

- `idle` checks `req1` first, then `req2`;
- `s1` checks `req2` first, then `req1`;
- `s2` begins by checking `req1`;
- the highlighted question asks why the order changes inside `s1`.

The partial `s2` logic should be completed as the mirror of `s1`: check
`req1`, then retain `s2` if only `req2` remains, otherwise return to `idle`.

### Direct answer

`s1` means requester 1 owns the **current** grant. The next-state decoder is
choosing who should own the **next** grant. Therefore it checks `req2` first so
that a waiting requester 2 gets its turn after requester 1 has just been
served.

If both requests are HIGH in `s1`, the desired transition is:

$$
s1 \xrightarrow{req1=1,\ req2=1} s2
$$

In `s2`, the logic is symmetric:

$$
s2 \xrightarrow{req1=1,\ req2=1} s1
$$

The alternating state sequence is what produces round-robin fairness.

### What would go wrong if `s1` checked `req1` first?

Suppose both requests remain HIGH. This incorrect order:

```systemverilog
s1: begin
    if (req1)
        next_state = s1;
    else if (req2)
        next_state = s2;
end
```

would always take the first branch. The FSM would remain in `s1`, `gnt1` would
stay HIGH, and requester 2 could wait forever. That is starvation and reduces
the design to fixed priority while it is in `s1`.

Source-code order matters because an `if`/`else if` chain is a priority chain.
When several conditions are true, only the first true branch determines the
result.

### Edge-by-edge trace when both requests stay HIGH

| Rising edge result | Registered state | `gnt1` | `gnt2` | Next-state decision |
|---:|---|:---:|:---:|---|
| After leaving reset | `idle` | 0 | 0 | `idle` checks `req1` first, so choose `s1`. |
| 1 | `s1` | 1 | 0 | `req2` is waiting, so choose `s2`. |
| 2 | `s2` | 0 | 1 | `req1` is waiting, so choose `s1`. |
| 3 | `s1` | 1 | 0 | Choose `s2` again. |
| 4 | `s2` | 0 | 1 | Choose `s1` again. |

`idle` gives requester 1 the initial tie-break, but the `s1`/`s2` transitions
rotate priority after that first decision. With persistent simultaneous
requests, each requester receives one grant every two service cycles.

### Complete corrected next-state solution

```systemverilog
always_comb begin
    next_state = state;

    case (state)
        idle: begin
            if (req1)
                next_state = s1;    // Initial tie-break favors requester 1
            else if (req2)
                next_state = s2;
            else
                next_state = idle;
        end

        s1: begin
            if (req2)
                next_state = s2;    // Rotate away from the current winner
            else if (req1)
                next_state = s1;    // Keep serving req1 if nobody else waits
            else
                next_state = idle;
        end

        s2: begin
            if (req1)
                next_state = s1;    // Symmetric rotation after serving req2
            else if (req2)
                next_state = s2;
            else
                next_state = idle;
        end

        default: next_state = idle;
    endcase
end
```

The initial `next_state = state` is a defensive default. The explicit branches
still document every intended transition and prevent latch inference.

### Boundary conditions to remember

- If only `req1` remains HIGH in `s1`, staying in `s1` is correct; there is no
  competing requester to serve.
- If only `req2` is HIGH in `s1`, transition to `s2`.
- If neither request is HIGH, return to `idle`.
- A requester should normally hold its request until it observes its grant or a
  defined service-accept event.
- This simple design assumes one grant cycle equals one completed service. For
  a multi-cycle resource, priority must rotate on `done`/acceptance, not merely
  on every clock.
- This is still a plain request/grant arbiter. The later AXI-Stream version must
  additionally hold the selected transfer stable during back-pressure.

**Recall:** In one sentence, why does `s2` check `req1` first? Because requester
2 is already receiving the current grant, so requester 1 must receive first
priority for the next grant.

## How each page will be integrated

1. Save a readable image with a meaningful topic name.
2. Embed the complete page directly in this README or the matching later day
   page.
3. Transcribe the signals, waveform annotations, RTL, and equations in the same
   order Kapil wrote them.
4. Explain the hardware event at each marked clock edge instead of merely
   restating the labels.
5. Correct terminology or protocol rules beside the relevant statement.
6. Link the page to the matching Layer 1 video section so the two sources remain
   adjacent during revision.
7. Add one page-specific recall test and, where useful, a trace table.

## Current boundary

The course layer currently ends at **49. Understanding Write data channel**.
Sections 1-3 are complete, and Section 4 is documented through its fifth
lesson. This handwritten layer currently has one page mapped to Video 31;
future handwritten arbiter, FIFO, or AXI4-Lite pages should be linked to their
matching section file without extending beyond the live course boundary.
