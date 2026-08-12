# Section 7 - AXI4-Lite GPIO Use Case

[Previous: Section 6](Section%2006%20-%20AXI4-Lite%20Single%20Beat%20without%20Pipeline%20-%20FSM%20Approach.md) | [Section index](README.md) | [AXI chapter](../README.md) | [Next: Section 8](Section%2008%20-%20AXI4%20Full%20-%20Hardcoded%20Next%20Address.md)

**Course status:** 7/7 lessons complete, covering lessons 94-100.

This section turns the earlier protocol exercises into a small memory-mapped
peripheral. Software-visible register writes control an LED-like GPIO output;
reads return GPIO or status information. The address channel chooses a
register, `WSTRB` chooses bytes inside that register, and the peripheral logic
connects those stored bits to pins.

## Lessons 94-100

### Video 94 - Section 7 agenda

![Original full-frame Section 7 agenda](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/094-agenda-50.png)

The single agenda item—build AXI4-Lite GPIO from scratch—contains three separate
engineering problems: protocol termination, register-file semantics, and safe
external-pin handling. Keeping those layers separate makes the design easier
to verify.

### Video 95 - Generating register data from `WDATA` and `WSTRB`

![Original full-frame GPIO register map, byte lanes, and AXI4-Lite write waveform](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/095-building-axi-lite-gpio-ip-p1-generating-data-from-wdata-and-wstrb-25.png)

The handwritten byte boxes show the exact register update. For a 32-bit data
bus, `WSTRB[0]` controls bits `[7:0]`, `WSTRB[1]` controls `[15:8]`, and so on.
For byte lane $i$:

$$
gpio\_q[8i+7:8i] \leftarrow
\begin{cases}
WDATA[8i+7:8i], & WSTRB[i]=1 \\
gpio\_q[8i+7:8i], & WSTRB[i]=0
\end{cases}
$$

![Original full-frame completed WSTRB example beside read and write timing](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/095-building-axi-lite-gpio-ip-p1-generating-data-from-wdata-and-wstrb-75.png)

The merge occurs only for an accepted write-data item associated with the
accepted target address. A low strobe preserves the old byte; it does not write
zero. Address decode and strobe merge therefore belong to the same committed
write operation, even if AW and W arrived on different cycles.

#### Handwritten page 44 - GPIO registers and byte strobes

![Handwritten AXI notes: GPIO registers and byte strobes](../../../../_internal/Protocols/04%20AMBA/03%20AXI/handwritten/images/44-axi-lite-gpio-registers-and-byte-strobes.jpg)

**Explanation:** Each `WSTRB` bit enables one byte lane of the GPIO register
update. Partial writes therefore require per-byte write enables rather than
replacing all 32 bits whenever any strobe is asserted.

### Video 96 - Debouncing the GPIO input

![Original full-frame debounce counter RTL and switch-bounce diagram](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/096-building-axi-lite-gpio-ip-p2-debouncing-25.png)

The right diagram shows a mechanical button oscillating before it settles. The
counter on the left accepts a new logical level only after the sampled input
has remained consistently different for the selected interval. A short glitch
resets or fails to complete the count.

![Original full-frame later debounce RTL with stable-level timing notes](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/096-building-axi-lite-gpio-ip-p2-debouncing-75.png)

Debouncing and clock-domain safety are different jobs. A physical button is
asynchronous to `ACLK`; production hardware normally passes it through a
metastability synchronizer before the debounce counter consumes it. The course
code demonstrates the debounce decision and its chosen count width. Its inline
comments identify the assumed clock rate, debounce interval, initial level,
and whether synchronization is outside the lesson block.

#### Handwritten page 45 - GPIO button debouncing

![Handwritten AXI notes: GPIO button debouncing](../../../../_internal/Protocols/04%20AMBA/03%20AXI/handwritten/images/45-gpio-button-debouncing.jpg)

**Explanation:** The sample-wait-sample idea rejects short mechanical
transitions. Because the external switch is asynchronous to `ACLK`,
synchronization must precede the debounce filter so metastability is not treated
as an ordinary bounce sample.

### Video 97 - GPIO write FSM

![Original full-frame GPIO write FSM beside the first write-channel RTL](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/097-building-axi-lite-gpio-ip-p3-write-fsm-25.png)

The flowchart accepts address and data, performs the register update, then
returns one B response. The register must update once per logical write, not
once per cycle that `AWVALID` or `WVALID` happens to remain HIGH.

![Original full-frame completed GPIO write FSM and WSTRB-controlled update code](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/097-building-axi-lite-gpio-ip-p3-write-fsm-75.png)

The editor makes the byte-loop hardware explicit: each strobe controls one
byte's write enable. The address decoder determines which GPIO register those
enables target. Unsupported or read-only addresses must not modify storage;
the paired teaching code documents the response used for that case.

`BVALID` remains asserted until `b_fire`. Clearing it after one clock would
make the register update visible while potentially losing the response—the
software-visible operation would no longer have a reliable completion.

#### Handwritten page 46 - GPIO read/write flowchart

![Handwritten AXI notes: GPIO read/write flowchart](../../../../_internal/Protocols/04%20AMBA/03%20AXI/handwritten/images/46-gpio-read-write-flowchart.jpg)

**Explanation:** The flowchart serializes register access and returns either a
response or read data. It should accept `AW` and `W` independently rather than
requiring both `VALID` signals in the same cycle, while still allowing only the
intended number of outstanding commands.

#### Handwritten page 47 - GPIO Subordinate write FSM

![Handwritten AXI notes: GPIO Subordinate write FSM](../../../../_internal/Protocols/04%20AMBA/03%20AXI/handwritten/images/47-gpio-subordinate-write-fsm.jpg)

**Explanation:** The detailed states retain the write address and wait for write
data before updating the register. `AWREADY` and `WREADY` may be controlled
separately, provided an accepted item is stored until the transaction can
finish.

### Video 98 - GPIO read FSM

![Original full-frame GPIO read FSM and address-decode RTL](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/098-building-axi-lite-gpio-ip-p4-read-fsm-25.png)

The read path accepts one `ARADDR`, selects the addressed register or input
status, and presents one `RDATA/RRESP` item. Sampling a debounced input into
`RDATA` should create a coherent value for the held response.

![Original full-frame completed read-data mux and response-valid logic](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/098-building-axi-lite-gpio-ip-p4-read-fsm-75.png)

Once `RVALID` is asserted, the selected `RDATA` cannot follow a changing GPIO
pin while stalled. The result must be captured or otherwise guaranteed stable
until `r_fire`. This is the boundary between a live pin and an AXI response
payload.

### Video 99 - Testing GPIO operation

![Original full-frame GPIO testbench stimulus and expected register values](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/099-building-axi-lite-gpio-ip-p4-testing-operation-25.png)

The source frame drives writes, reads, and GPIO input changes. A strong
scoreboard keeps a byte-accurate shadow register: on each committed write it
merges only enabled lanes, and on each accepted read it compares the returned
value and response.

![Original full-frame GPIO Vivado waveform with AXI writes, reads, and pin behavior](../../../../_internal/Protocols/04%20AMBA/03%20AXI/images/Day%2003/099-building-axi-lite-gpio-ip-p4-testing-operation-75.png)

The waveform should prove four relationships:

- output GPIO changes after the intended accepted write;
- disabled strobe lanes retain their previous values;
- a read returns the decoded register or debounced input;
- B and R responses remain held through any injected ready stall.

The debounce test also needs a pulse shorter than the threshold and a stable
level longer than the threshold. Otherwise the waveform only proves direct
sampling, not debouncing.

### Lesson 100 - GPIO code resource

The Section 7 code folder preserves the instructor's AXI4-Lite GPIO module and
testbench. Its comments state the address map, data width, byte-lane mapping,
clock/debounce assumptions, GPIO synchronization boundary, unsupported-address
behavior, response handling, and one-outstanding capacity. These comments make
the exact classroom implementation safe to revise without replacing it with a
different architecture.

## Peripheral-design checkpoints

- Protocol handshakes decide when a request/result is accepted.
- Address decode decides which register the request targets.
- `WSTRB` decides which bytes inside that register change.
- A stalled `RDATA` value is a held response, not a continuously changing view
  of an input pin.
- Synchronization limits metastability risk; debouncing rejects repeated
  mechanical transitions. One does not replace the other.
- Register side effects occur exactly once for each committed operation.

## Active-recall checkpoint

1. What happens to a byte whose `WSTRB` bit is zero?
2. Why must address and data capture be associated before changing a GPIO
   register?
3. Why is a debounce counter not automatically a metastability synchronizer?
4. Which event should update the scoreboard's shadow register?
5. Why must read data stop following a live pin after `RVALID` is asserted?
6. What two directed stimuli prove the debounce threshold?

[Continue to Section 8](Section%2008%20-%20AXI4%20Full%20-%20Hardcoded%20Next%20Address.md).
