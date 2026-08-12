# Section 8 - AXI4 Full with Hardcoded Next-Address Logic

[Previous: Section 7](Section%2007%20-%20AXI4-Lite%20GPIO%20Use%20Case.md) | [Course hub](../Course%20Atlas.md) | [AXI chapter](../README.md) | [Next: Section 9](Section%2009%20-%20AXI4%20Full%20-%20Burst-Based%20Address%20Generation.md)

**Course status:** 12/12 lessons complete, covering lessons 101-112.

This section moves from AXI4-Lite to full AXI4. Bursts, beat counts, last-beat
markers, and transaction IDs return. To isolate channel control from address
mathematics, the first implementation uses a fixed next-address assumption;
Section 9 replaces that shortcut with burst-type-driven generation.

## Full-AXI state that must travel with a transaction

A burst command contains more than an address. At minimum, the teaching logic
must preserve the accepted ID, length, size, and burst type until the data and
response phases have completed. For a burst:

$$
N_{beats}=AxLEN+1
$$

The beat counter advances on an accepted W or R beat. `WLAST`/`RLAST` identify
the final offered beat and are held with that beat during back-pressure.

### Video 101 - Section 8 agenda

![Original full-frame Section 8 agenda](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/101-agenda-50.png)

The agenda separates full-AXI signal study, single/burst transaction timing,
and paired Manager/Subordinate implementation. “Hardcoded next address” is a
declared teaching boundary, not a general AXI4 address generator.

### Video 102 - Typical full-AXI transactions

![Original full-frame initial full-AXI burst flow and channel waveforms](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/102-typical-axi-full-transactions-25.png)

The first frame shows a command state feeding repeated data beats. One accepted
AW command controls `AWLEN+1` accepted W items and one B response. One accepted
AR command controls `ARLEN+1` accepted R items.

![Original full-frame expanded read/write transaction flowcharts with beat waveforms](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/102-typical-axi-full-transactions-75.png)

The expanded flowcharts make terminal events visible:

- write address: one `aw_fire`;
- write data: repeat `w_fire`, assert `WLAST` on the final offered beat;
- write completion: one `b_fire`;
- read address: one `ar_fire`;
- read data: repeat `r_fire`, with `RLAST` on the final returned beat.

The counter must not advance during `WVALID && !WREADY` or
`RVALID && !RREADY`. Otherwise the held payload and its last marker would no
longer describe the same beat.

#### Handwritten page 48 - AXI4 single-beat signal set

![Handwritten AXI notes: AXI4 single-beat signal set](../../../../_internal/Protocols/04%20AMBA/03%20AXI/handwritten/images/48-axi4-single-beat-signals.jpg)

**Explanation:** The full-AXI address channel retains size, length, burst, and
ID fields even for a single-beat teaching example. A single beat uses `AWLEN=0`,
and the only accepted write-data beat carries `WLAST=1`.

### Video 103 - Write FSM

![Original full-frame write FSM and burst waveform](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/103-write-fsm-25.png)

The write flow begins with address issue, iterates over data, then waits for the
response. The state alone does not count beats; a handshake-gated counter
determines when the current data item is the last one.

![Original full-frame completed write FSM with final-beat and response branches](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/103-write-fsm-75.png)

For zero-based counter `beat_q`, the last offered beat is typically identified
by `beat_q == AWLEN_q`. The counter increments only on `w_fire`; `WLAST` is
derived from or registered with that same held beat. After final `w_fire`, the
FSM waits for `BVALID` and completes on `b_fire`.

#### Handwritten page 49 - AXI4 write FSM: address and data

![Handwritten AXI notes: AXI4 write FSM: address and data](../../../../_internal/Protocols/04%20AMBA/03%20AXI/handwritten/images/49-axi4-write-fsm-address-and-data.jpg)

**Explanation:** The FSM issues the address, streams write beats, and advances
its counter only on `WVALID && WREADY`. Both `AWVALID` and each write payload
must remain stable until their own acceptance edges.

#### Handwritten page 50 - AXI4 write FSM: last beat and response

![Handwritten AXI notes: AXI4 write FSM: last beat and response](../../../../_internal/Protocols/04%20AMBA/03%20AXI/handwritten/images/50-axi4-write-fsm-last-and-response.jpg)

**Explanation:** `WLAST` is asserted with the final valid write beat and held
through any stall. Only the accepted final beat leads to the write-response
phase, which finishes on `BVALID && BREADY`.

### Video 104 - Read FSM

![Original full-frame read FSM and returned burst waveform](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/104-read-fsm-25.png)

The Manager issues one AR command and accepts repeated R beats. `RID` and
`RRESP` accompany every returned beat; `RLAST` marks the final one. A scoreboard
associates the burst with the accepted `ARID`.

![Original full-frame completed read FSM with RLAST termination](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/104-read-fsm-75.png)

The Manager must remain ready only when it has storage for the next result. If
it lowers `RREADY`, `RDATA`, `RRESP`, `RID`, and `RLAST` freeze. The read FSM
leaves its data state only on an accepted beat with `RLAST=1`.

#### Handwritten page 51 - AXI4 read FSM

![Handwritten AXI notes: AXI4 read FSM](../../../../_internal/Protocols/04%20AMBA/03%20AXI/handwritten/images/51-axi4-read-fsm.jpg)

**Explanation:** The read sequence sends `AR`, accepts `R` beats, and completes
on an accepted `RLAST`. The Manager controls `RREADY`; the Subordinate controls
`RVALID`, `RDATA`, `RRESP`, and `RLAST`.

### Video 105 - Implementing the write channel

![Original full-frame write FSM beside Manager write-channel RTL](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/105-implementing-write-channel-25.png)

The editor introduces address/control registers, data/strb/last outputs, and
the write-response inputs. Accepted command fields are held for the complete
burst. The instructor's hardcoded data-width/address-step assumptions are
documented in the matching source rather than generalized silently.

![Original full-frame later write implementation with beat counter and WLAST logic](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/105-implementing-write-channel-75.png)

Trace one stall at the highlighted counter logic: while `WREADY=0`, the counter
does not change, `WDATA/WSTRB/WLAST` do not change, and `WVALID` remains HIGH.
When `w_fire` occurs, the design advances to the next teaching data value or
enters response wait after the final beat.

The implementation uses one outstanding write. Although full AXI supports
multiple IDs and outstanding operations, this block does not need a reorder or
ID queue because it does not overlap commands.

### Video 106 - Implementing the read channel

![Original full-frame read FSM beside Manager AR/R RTL](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/106-implementing-read-channel-25.png)

The AR registers carry the teaching ID/length/size/burst configuration. After
`ar_fire`, the Manager waits for R items and checks `RLAST` on accepted beats.

![Original full-frame read-result handling and completion logic](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/106-implementing-read-channel-75.png)

`RRESP` must be sampled with each `RDATA` beat. If the teaching local interface
uses only data, the source comments identify that response status is observed,
ignored, or assumed `OKAY`. `RLAST` without `r_fire` is not completion.

### Lesson 107 - Manager code resource

The instructor's Manager source is preserved under [Code](../Code/README.md).
Its inline contract names the fixed data width, hardcoded address step, chosen
burst length/ID behavior, one-outstanding restriction, omitted optional user
signals, and the handling of `BRESP`/`RRESP`.

### Video 108 - Implementing Subordinate write operation

![Original full-frame full-AXI Subordinate write FSM and first RTL branches](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/108-implementing-slave-write-operation-25.png)

The Subordinate captures AW control, accepts each W beat, applies strobes, and
returns B. It must associate the data stream with the accepted command even
though AXI4 removed AXI3's `WID`.

![Original full-frame later Subordinate write counter, WLAST, and response logic](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/108-implementing-slave-write-operation-75.png)

The expected beat count and accepted `WLAST` must agree. An early or missing
`WLAST` is a protocol error. After the final data handshake, `BID` is derived
from the stored `AWID` and held with `BRESP/BVALID` until `b_fire`.

The memory update occurs only on `w_fire`. `WSTRB` still supplies per-byte write
enables on every full-AXI beat.

### Video 109 - Subordinate read operation

![Original full-frame full-AXI Subordinate read FSM and address capture](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/109-slave-read-operation-25.png)

The Subordinate stores AR control and produces a sequence of R payloads. `RID`
comes from the stored `ARID`, and `RLAST` is attached to the final offered
beat.

![Original full-frame read-data generation, counter, response, and RLAST RTL](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/109-slave-read-operation-75.png)

The read address used for each teaching beat advances only after `r_fire`.
During an R stall, both the memory-selected data and all sidebands must remain
stable. Re-reading a live memory location combinationally while stalled can
violate that rule if another agent can modify the location; the classroom
memory assumptions are therefore part of the source contract.

### Lesson 110 - Subordinate code resource

The Subordinate source comments list its accepted ID/length/size/burst fields,
hardcoded next-address rule, memory geometry, response behavior, one-command
capacity, and any ignored protection/cache/QoS/user inputs. The code remains
the instructor's design with its boundaries made explicit.

### Video 111 - Connecting and verifying the full-AXI pair

![Original full-frame top-level Manager/Subordinate connection RTL](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/111-connecting-master-and-slave-together-and-verifying-design-25.png)

The top level connects all five full-AXI channels, including ID, length, size,
burst, response, and last-beat fields. Width equality and direction are the
first checks; transaction association is the behavioral check.

![Original full-frame Vivado waveform of connected full-AXI write and read transactions](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/111-connecting-master-and-slave-together-and-verifying-design-75.png)

The waveform should prove accepted beat count, monotonic teaching addresses,
correct final-beat markers, ID return, and response completion. A useful
scoreboard records each accepted command and retires it only after the matching
terminal B response or final accepted R beat.

### Lesson 112 - Connected design code resource

The final resource preserves the paired design and testbench. The testbench
comments identify the fixed burst/data assumptions and which checks would fail
if a different `AxSIZE` or `AxBURST` were applied. Section 9 is the deliberate
extension point for those cases.

## Hardcoded-address boundary

The teaching implementation is correct only for the exact configured profile
named in its source comments. A general full-AXI endpoint must derive beat
addresses from `AxSIZE` and `AxBURST`, enforce the 4-KiB transaction boundary,
and implement WRAP alignment/length rules. Do not remove the comments and reuse
the hardcoded step as if it supported arbitrary AXI4 bursts.

## Active-recall checkpoint

1. Why is `AxLEN` stored as beats minus one?
2. Which event advances the write beat counter?
3. Which signals freeze with a stalled final W beat?
4. Why does AXI4 need no `WID`?
5. Where do `BID` and `RID` originate in a one-outstanding design?
6. Why is a hardcoded four-byte increment not a general AXI4 address
   generator?
7. Which terminal events retire write and read commands in a scoreboard?

[Continue to Section 9](Section%2009%20-%20AXI4%20Full%20-%20Burst-Based%20Address%20Generation.md).
