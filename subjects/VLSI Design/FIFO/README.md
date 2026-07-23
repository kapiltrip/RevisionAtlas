# FIFO

FIFO is the second major VLSI design topic in this repository. The aim is not to begin by copying a finished Verilog module. The aim is to learn how a FIFO is constructed, what hardware each part becomes after synthesis, how boundary cases are verified, and why an asynchronous FIFO needs a clock-domain-crossing architecture rather than a small modification to a synchronous FIFO.

> **Current scope:** this page is the design and learning approach only. No RTL or testbench code is included yet.

## The cleaned-up roadmap

This is the handwritten plan converted into an implementation order:

| Stage | Build or study | Why it comes here | Evidence required before moving on |
|---:|---|---|---|
| 1 | RAM | The FIFO needs storage, and the RAM's port and read-latency behavior affect the complete FIFO interface. | A clear memory contract and the intended memory resource visible after synthesis |
| 2 | Synchronous FIFO around the RAM | One clock lets the storage, pointers, flags, and boundary rules be understood without CDC complexity. | Correct ordering, wrap-around, `full`, `empty`, overflow, and underflow behavior |
| 3 | Verification, synthesis, and timing | Functional simulation alone does not prove that the intended RAM was inferred or that the design meets timing. | Passing directed/random tests, correct inferred hardware, and clean timing reports |
| 4 | Asynchronous FIFO | Only after the FIFO rules are stable should independent write and read clocks be introduced. | Correct local flags, synchronized Gray pointers, CDC review, and defined reset behavior |
| 5 | Asynchronous-FIFO verification | CDC latency and unrelated clocks create cases that a single-clock testbench cannot expose. | Passing tests across clock ratios, phase relationships, stalls, wrap-around, and resets |

The order matters. If RAM behavior, FIFO boundary rules, verification, and CDC are learned simultaneously, a failure is difficult to localize. Here, every stage introduces only one new class of problem.

## 1. Begin with the contract, not the RTL

Before designing anything, write a one-page specification that answers every item below.

### Parameters

- **Data width:** how many bits one FIFO entry contains.
- **Depth:** how many entries can be stored.
- **Address width:** enough bits to select every legal RAM location.
- **Depth rule:** decide whether the first design supports only powers of two. This is the cleanest starting point. Arbitrary depth needs explicit pointer wrap at `DEPTH - 1`; allowing a binary pointer to wrap naturally is incorrect when the depth is not a power of two.

### Interface meaning

- A write is **accepted** only when a write is requested and the FIFO can accept it.
- A read is **accepted** only when a read is requested and the FIFO contains valid data.
- `full` means another accepted write would exceed the storage capacity.
- `empty` means there is no valid entry available to read.
- Decide whether rejected operations merely do nothing or also produce `overflow` and `underflow` indicators.

Keep **request** and **accepted operation** separate in the reasoning. Pointers, occupancy, and the reference model must change only for accepted operations.

### Timing behavior

Decide these points explicitly:

- Is the RAM read synchronous, and therefore does the data appear after a clock edge?
- Is the FIFO a standard-read FIFO or first-word fall-through (FWFT)?
- On which cycle does output data become valid after an accepted read?
- Are `full` and `empty` current-state flags or next-state/look-ahead flags?
- What happens if read and write are requested in the same cycle?
- At `empty`, may a simultaneous write and read pass the new word through, or is the read rejected?
- At `full`, may a simultaneous read make room for the write in that same cycle, or is the write rejected?

There is more than one valid interface contract, but there must be only one contract in the design and testbench. Do not allow the RTL and testbench to invent different answers.

### Reset behavior

- State the active level and whether assertion and release are synchronous or asynchronous.
- After reset, both pointers represent the same empty location: `empty` must be asserted and `full` deasserted.
- State whether output data is invalid, cleared, or simply ignored until a valid read completes.
- For an asynchronous FIFO, define whether both clock domains must be reset together and how traffic is held off while synchronized state settles.

## 2. Understand what the FIFO should synthesize into

A FIFO is not normally a long row of words shifting on every write. Think of it as a stationary memory plus control state.

| Design idea | Expected hardware meaning |
|---|---|
| Stored entries | Distributed RAM, block RAM, UltraRAM, or registers, depending on size, style, and target device |
| Write pointer | Counter/register whose address selects the next RAM location to be written |
| Read pointer | Counter/register whose address selects the next RAM location to be read |
| Occupancy or extended-pointer state | Registers and arithmetic/comparison logic used to distinguish empty from full |
| `full` and `empty` | Comparators and small combinational logic, normally registered or local to the relevant clock domain |
| Asynchronous pointer transfer | Gray conversion plus synchronizer registers; the data bus itself remains in dual-port memory |

After each implementation, inspect the elaborated schematic first and the synthesized schematic/utilization report second. The first reveals the logical structure; the second reveals what the tool actually mapped into device resources. AMD Vivado can infer several RAM organizations and map the description into one or more RAM primitives, so the coding style and selected port behavior are part of the hardware architecture, not mere syntax ([UG901: Memory Inference Capabilities](https://docs.amd.com/r/en-US/ug901-vivado-synthesis/Memory-Inference-Capabilities)).

## 3. Stage 1 — learn the RAM first

Start with the smallest memory organization the FIFO needs: one write path and one read path. For the first synchronous FIFO, both operations use the same clock. Keep the RAM conceptually separate from the FIFO control so a memory problem cannot be confused with a pointer problem.

Determine and record:

1. Whether the target is registers, distributed RAM, or block RAM.
2. Whether reading is synchronous or asynchronous.
3. The read latency seen at the module boundary.
4. The read-during-write behavior when both ports address the same location: read-first, write-first, or no-change.
5. Whether the output has an additional register.
6. What the synthesis utilization report says was actually inferred.

Do not continue merely because behavioral simulation can store and retrieve data. Continue when simulation behavior and inferred hardware agree with the written contract.

## 4. Stage 2 — build the synchronous FIFO

Use one clock for the RAM, write pointer, read pointer, flags, and all acceptance decisions.

### Recommended first architecture

- A dual-port-style memory: one logical write port and one logical read port.
- A write pointer that advances only after an accepted write.
- A read pointer that advances only after an accepted read.
- An occupancy counter for the first version because it makes the state easy to observe and debug.
- `empty` derived from zero occupancy and `full` derived from occupancy equal to depth.

Once this version is completely understood, repeat the exercise with extended pointers: use the RAM-address bits for location and an extra wrap bit to distinguish equal-address empty from equal-address full. This second implementation prepares the pointer reasoning needed by the asynchronous FIFO.

### State transitions to reason through on paper

| Accepted operations in one cycle | Occupancy change | Pointer movement |
|---|---:|---|
| Neither | 0 | Neither pointer moves |
| Write only | +1 | Write pointer moves |
| Read only | -1 | Read pointer moves |
| Read and write | 0 | Both pointers move |

Then apply the boundary contract. A request that is rejected at `full` or `empty` must not move its pointer or corrupt occupancy. Simultaneous requests at the boundaries must follow the exact policy written in the specification.

### Questions that must be answerable before testing

- Why can equal read and write addresses mean either empty or full?
- Why is an additional wrap bit or occupancy state needed?
- Why must pointer width and RAM address width be treated as related but different quantities?
- What changes when depth is not a power of two?
- Which status values describe the state before the active edge, and which describe the state after accepted operations?
- How does RAM read latency affect `data_valid` and the scoreboard?

## 5. Stage 3 — verify before optimizing

The testbench should contain a reference queue that stores every accepted input word. On each accepted read, compare the FIFO output against the oldest expected word at the latency required by the interface contract. Never update the reference queue from a request that the DUT rejected.

### Directed tests

Run these first because each failure points to a specific rule:

1. Reset and check the initial flags without traffic.
2. Write one word, then read it.
3. Fill exactly to depth and check the `full` transition.
4. Attempt an extra write and prove that stored data and pointers are unchanged.
5. Drain exactly to zero and check the `empty` transition.
6. Attempt an extra read and prove that no state is consumed.
7. Write and read together in the middle of the occupancy range.
8. Exercise the specified simultaneous-operation policy at `empty` and at `full`.
9. Cross the physical end of RAM repeatedly to prove pointer wrap-around.
10. Reset after partial filling and verify that stale memory contents are not treated as valid entries.

### Random and invariant-based tests

After directed cases pass, randomize requests and data while maintaining a software reference queue. Run long enough to wrap both pointers many times.

Check these invariants throughout the run:

- Occupancy never becomes negative or greater than depth.
- `empty` and `full` are never both asserted in a synchronous FIFO.
- A rejected operation cannot advance its pointer.
- Output order is exactly input order; duplication, loss, and reordering are all failures.
- After the same number of accepted writes and reads, the FIFO returns to empty.

Repeat with small awkward configurations such as depth 1, depth 2, and the smallest supported data width. If arbitrary depth is supported, include non-power-of-two depths and force frequent wrap-around.

## 6. Synthesis and timing review

Functional correctness is only one checkpoint. For the synthesized design:

1. Confirm that the memory mapped to the intended resource rather than unexpectedly becoming many flip-flops.
2. Check that there are no unintended latches, gated clocks, or combinational loops.
3. Read utilization for RAM, LUT, and register cost.
4. Add a real clock constraint and inspect worst setup and hold paths.
5. Look especially at paths through pointer increment, occupancy/flag comparison, and write/read acceptance logic.
6. Confirm that the RAM's output latency in the netlist matches the testbench contract.
7. Record maximum frequency only after the timing constraints and reports are trustworthy.

If the status comparison becomes the critical path, first examine whether the flag can be computed from registered next-state information. Do not pipeline a flag casually: changing flag latency changes the FIFO's externally visible acceptance contract.

## 7. Stage 4 — advance to the asynchronous FIFO

An asynchronous FIFO has unrelated `wr_clk` and `rd_clk` domains. It is not a synchronous FIFO with a second clock connected to the read process.

### Architecture to understand before implementation

- Keep the first asynchronous FIFO depth at a power of two. The conventional binary-counter-to-Gray-pointer method relies on traversing the complete power-of-two count cycle; arbitrary-depth asynchronous FIFOs need additional architecture and proof rather than only a changed wrap comparison.
- The write domain owns the binary write pointer, Gray write pointer, write acceptance, and `full` flag.
- The read domain owns the binary read pointer, Gray read pointer, read acceptance, and `empty` flag.
- Binary pointers are used locally for RAM addressing and arithmetic.
- Gray versions are crossed because adjacent Gray-count states change only one bit.
- The Gray write pointer is synchronized into the read domain; the Gray read pointer is synchronized into the write domain.
- Each domain compares its local next pointer with the synchronized remote pointer to generate its own safe status flag.
- FIFO payload data is written and read through dual-port memory; it is not sent through a bank of ordinary bit synchronizers.

AMD's independent-clock FIFO architecture similarly uses memory, local counters, binary-to-Gray conversion, synchronized pointers, and local status logic ([PG327: Independent Clocks](https://docs.amd.com/r/en-US/pg327-emb-fifo-gen/Independent-Clocks-Block-RAM-and-Distributed-RAM)). It also makes every interface/status signal valid only in its respective clock domain ([PG327: Pipelining and Synchronization](https://docs.amd.com/r/en-US/pg327-emb-fifo-gen/Understand-Signal-Pipelining-and-Synchronization)).

### The CDC points that must not be skipped

- A two-flop synchronizer reduces metastability propagation risk; it does not make an arbitrary multi-bit binary bus coherent.
- Synchronize the Gray pointer into the destination domain, then use that synchronized value only in destination-domain logic.
- Register the source Gray pointer before synchronization so combinational glitches do not become CDC events.
- Expect conservative flag release: for example, `empty` may remain asserted for read-clock cycles after a write because the new write pointer must cross into the read domain.
- Keep `full` in the write domain and `empty` in the read domain. Do not use either flag directly in the other domain.
- Give synchronizer registers the appropriate implementation attributes and physically meaningful CDC constraints.
- Review the implementation with the tool's CDC report; do not declare a crossing safe merely because simulation has no metastability model.

Even a Gray-coded bus needs suitable timing or skew control so the receiving domain cannot observe changes from multiple source states together. AMD explicitly calls for latency or bus-skew constraints on Gray-coded CDC buses ([UG1387: Constraints on Individual CDC Paths](https://docs.amd.com/r/en-US/ug1387-acap-hardware-ip-platform-dev-methodology/Constraints-on-Individual-CDC-Paths)); the CDC report should also be inspected for unexpected paths and missing synchronizer properties ([UG906: CDC Detailed Report](https://docs.amd.com/r/en-US/ug906-vivado-design-analysis/Detailed-Report)).

## 8. Stage 5 — verify the asynchronous FIFO

Use one reference queue, but drive write-side decisions on `wr_clk` and read-side decisions on `rd_clk`. The scoreboard must understand the specified read latency and the fact that pointer information crosses domains with delay.

Vary all of these deliberately:

- Write clock faster than read clock.
- Read clock faster than write clock.
- Equal nominal frequency with a phase offset.
- Non-integer clock ratios so edge relationships continually move.
- Long pauses in either clock domain.
- Bursts that repeatedly approach `full` and `empty`.
- Concurrent traffic through many pointer wraps.
- Reset before traffic, during partial occupancy, and near coincident clock edges, following the documented reset policy.

Check data integrity from accepted operations, not from instantaneous cross-domain flag intuition. Synchronization delay makes conservative status latency normal; data loss, duplication, reordering, unsafe CDC topology, or capacity violation is not normal.

## Definition of done

The FIFO topic is complete only when all of the following can be demonstrated and explained:

- [ ] The interface and every boundary case are specified before RTL.
- [ ] The RAM's read latency and read-during-write behavior are known.
- [ ] The synchronous FIFO passes directed, random, wrap-around, and invariant checks.
- [ ] Synthesis infers the expected memory and control hardware.
- [ ] Timing constraints are present and setup/hold reports are clean.
- [ ] The asynchronous design uses local binary/Gray pointers and synchronized remote Gray pointers.
- [ ] `full` and `empty` are generated and consumed only in their owning domains.
- [ ] CDC analysis finds no unexplained unsafe crossings.
- [ ] Gray-pointer timing/skew requirements are constrained, not assumed.
- [ ] The asynchronous FIFO passes changing clock ratios, stalls, resets, and repeated wrap-around.
- [ ] The complete design can be explained from RAM → pointers → accepted operations → flags → synchronization → physical implementation.

## Planned folder growth

Only this approach README is needed now. When implementation begins, grow this topic without mixing the stages:

| Future area | Intended content |
|---|---|
| RAM | Memory experiments and synthesis observations |
| Synchronous FIFO | One-clock design, written contract, and waveforms |
| Synchronous verification | Directed tests, randomized scoreboard, invariants, and coverage |
| Asynchronous FIFO | CDC architecture, constraints, and pointer reasoning |
| Asynchronous verification | Independent-clock tests, CDC reports, and reset experiments |

The guiding rule is: **make the FIFO contract correct in one clock, prove the inferred hardware, and only then introduce clock-domain crossing.**
