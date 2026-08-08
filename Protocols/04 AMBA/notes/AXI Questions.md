# AXI Questions

[Back to AXI](../03%20AXI/README.md) | [AXI Day 01 notes](AXI%20Day%2001.md) | [Back to AMBA](../README.md)

These notes keep Kapil's original AXI questions beside the exact lesson
section and the protocol rule needed to answer them. The current page is the
round-robin next-state question from
[Video 31](AXI%20Day%2001.md#video-31---round-robin-arbiter-part-2).

## Page 1 — Why does `s1` check `req2` first?

![Handwritten round-robin FSM question asking why state s1 checks req2 first](images/AXI/Day%2001/round-robin-fairness-question-s1-priority.jpg)

### Direct answer

`s1` means requester 1 owns the **current** grant. The next-state logic is
choosing the **next** owner. It checks `req2` first so a waiting requester 2
gets its turn after requester 1 has been served.

If both requests remain HIGH:

$$
s1 \xrightarrow{req1=1,\ req2=1} s2
$$

and symmetrically:

$$
s2 \xrightarrow{req1=1,\ req2=1} s1
$$

The alternating state sequence implements round-robin fairness.

### Why source-code order matters

An `if`/`else if` chain is a priority encoder. Only the first true branch
selects `next_state`.

This incorrect `s1` logic:

```systemverilog
s1: begin
    if (req1)
        next_state = s1;
    else if (req2)
        next_state = s2;
end
```

would remain in `s1` whenever both requests are HIGH. Requester 2 could wait
forever, which is starvation and fixed-priority behavior.

### Edge trace

| Edge result | State | Grant | Next choice when both requests stay HIGH |
|---:|---|---|---|
| reset released | `idle` | none | initial tie-break chooses `s1` |
| 1 | `s1` | `gnt1` | choose `s2` |
| 2 | `s2` | `gnt2` | choose `s1` |
| 3 | `s1` | `gnt1` | choose `s2` |
| 4 | `s2` | `gnt2` | choose `s1` |

The initial tie-break can favor requester 1 without making the arbiter unfair.
Fairness comes from rotating priority after service.

### Complete next-state logic

```systemverilog
always_comb begin
    next_state = state;

    case (state)
        idle: begin
            if (req1)
                next_state = s1;
            else if (req2)
                next_state = s2;
        end

        s1: begin
            if (req2)
                next_state = s2;
            else if (!req1)
                next_state = idle;
        end

        s2: begin
            if (req1)
                next_state = s1;
            else if (!req2)
                next_state = idle;
        end

        default: next_state = idle;
    endcase
end
```

The default `next_state = state` prevents an unintended latch and makes
“continue granting the current requester” the natural case.

## The service event is the real design decision

The simple FSM assumes one grant cycle equals one completed service. That is
only correct for a one-cycle resource.

For a multi-cycle shared block, rotate after an explicit `done` or acceptance
event. Rotating every clock can withdraw a grant before service finishes.

For an AXI-Stream arbiter, the minimum beat-level service event is:

$$
\text{out\_fire}
= \texttt{m\_axis\_tvalid}\land\texttt{m\_axis\_tready}
$$

If the output is stalled (`TVALID=1`, `TREADY=0`), the arbiter must keep the
same source selected and hold the entire output beat stable. Switching grants
during that interval can change `TDATA`, `TLAST`, or sideband signals while
the receiver is waiting.

Two common policies are:

- **beat arbitration:** rotate after each `out_fire`;
- **packet arbitration:** retain the source until
  `out_fire && m_axis_tlast`, then rotate.

Packet arbitration prevents beats from different inputs being interleaved
inside one output packet. The chosen policy must be explicit in RTL and the
scoreboard.

## Boundary conditions

- only `req1` HIGH in `s1` → remain `s1`;
- only `req2` HIGH in `s1` → move to `s2`;
- neither request HIGH → return to `idle`;
- a requester should hold its request until the defined service-accept event;
- fairness rotates after completed service, not merely after seeing a request;
- an AXI-Stream grant must not change an offered stalled beat.

## Verification checks

- with both requests continuously HIGH, grants alternate without starvation;
- with only one request HIGH, that requester keeps service;
- a short request is not lost before its grant/accept event;
- the grant is one-hot or zero-hot;
- under output back-pressure, selection and all stream payload signals remain
  stable;
- packet-level arbitration changes source only after an accepted `TLAST`.

## Recall

1. Why does `s1` test `req2` first?
2. What failure occurs if `s1` tests `req1` first?
3. Why is “rotate every clock” unsafe for a multi-cycle resource?
4. What exact event should rotate a beat-level AXI-Stream arbiter?
5. What exact event should rotate a packet-level arbiter?
