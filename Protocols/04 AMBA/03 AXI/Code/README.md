# AXI course code atlas

This directory is the code half of the AXI revision structure. The matching
course explanations and screenshots live in `../Lectures/`; the executable
course resources stay here in the instructor's lesson order.

## What is preserved

- All 23 downloadable code-resource lessons from lessons 1-128 are represented.
- The instructor's module names, signal names, executable statements, FSM
  architecture, and testbench stimulus are preserved.
- Only comments and file organization were added.
- A course page containing several modules was split into one module per file,
  with design modules under `rtl/` and supplied stimulus under `tb/`.
- Every source header identifies its section, implementation-video range,
  downloadable lesson, assumptions, omitted or simplified signals, and the
  behavioral consequence.

These are teaching implementations. If the course code compromises a protocol
rule, the comment records the compromise; it does not silently substitute a
different implementation.

## Study and code order

| Section | Implementation and verification lectures | Code resource | Unit |
|---|---|---:|---|
| 01 - Introduction to AXI | 7-10 | 010 | [Valid/Ready handshake](<Section 01 - Introduction to AXI/Lessons 007-010 - Valid Ready Handshake/>) |
| 02 - AXI-Stream fundamentals | 20-22 | 022 | [AXIS master](<Section 02 - AXI-Stream Interface Fundamentals/Lessons 020-022 - AXIS Master/>) |
| 02 - AXI-Stream fundamentals | 23-26 | 026 | [AXIS slave](<Section 02 - AXI-Stream Interface Fundamentals/Lessons 023-026 - AXIS Slave/>) |
| 02 - AXI-Stream fundamentals | 27-28 | 028 | [Master/slave integration](<Section 02 - AXI-Stream Interface Fundamentals/Lessons 027-028 - Master Slave Integration/>) |
| 03 - AXI-Stream IPs | 30-33 | 033 | [Round-robin arbiter](<Section 03 - AXI-Stream IPs/Lessons 030-033 - Round Robin Arbiter/>) |
| 03 - AXI-Stream IPs | 34-38 | 038 | [AXIS arbiter](<Section 03 - AXI-Stream IPs/Lessons 034-038 - AXIS Arbiter/>) |
| 03 - AXI-Stream IPs | 39-42 | 042 | [AXIS FIFO](<Section 03 - AXI-Stream IPs/Lessons 039-042 - AXIS FIFO/>) |
| 03 - AXI-Stream IPs | 43-44 | 044 | [Alternate AXIS FIFO](<Section 03 - AXI-Stream IPs/Lessons 043-044 - AXIS FIFO Alternate/>) |
| 05 - AXI-Lite single beat | 60-67 | 066, 067 | [Write-only manager/subordinate](<Section 05 - AXI-Lite Single Beat without Pipeline/Lessons 060-067 - AXIL Write Only Master and Slave/>) |
| 05 - AXI-Lite single beat | 68-72 | 071, 072 | [Protocol-checker exercise](<Section 05 - AXI-Lite Single Beat without Pipeline/Lessons 068-072 - AXI Protocol Checker/>) |
| 05 - AXI-Lite single beat | 73-81 | 081 | [Read-only manager/subordinate](<Section 05 - AXI-Lite Single Beat without Pipeline/Lessons 073-081 - AXIL Read Only Master and Slave/>) |
| 06 - AXI-Lite read/write | 86-93 | 092, 093 | [Combined AXI-Lite manager](<Section 06 - AXI-Lite Combined Read and Write/Lessons 086-093 - AXIL Read Write Master/>) |
| 07 - AXI-Lite GPIO | 95-100 | 100 | [AXI-Lite GPIO](<Section 07 - AXI-Lite GPIO/Lessons 095-100 - AXIL GPIO/>) |
| 08 - AXI4 single beat | 103-112 | 107, 110, 112 | [Single-beat manager/subordinate](<Section 08 - AXI4 Single Beat/Lessons 103-112 - AXI4 Single Beat Master and Slave/>) |
| 09 - AXI4 burst modes | 115-128 | 122, 125, 127, 128 | [FIXED, INCR, and WRAP bursts](<Section 09 - AXI4 Burst Modes/Lessons 115-128 - AXI4 Burst Master and Slave/>) |

Section 4 has no downloadable code resource: its lessons 45-54 establish the
AXI-Lite channel model used by Section 5.

## Directory convention

Each unit contains only the categories supplied by the course:

- `rtl/` - design and integration modules;
- `tb/` - instructor testbench/stimulus modules;
- `demo/` - the lesson 10 module, where clock, reset, source, receiver, and
  random stimulus intentionally coexist.

The folder name records the full lecture range. Each file header repeats the
exact downloadable lesson number.

## How to read the comments

Start at the source header:

1. **Assumptions** states the environment that the code silently relies on.
2. **Used / omitted / simplified** distinguishes actual ports from protocol
   fields that are absent, ignored, tied to constants, or reduced for teaching.
3. **Behavioral consequence** explains what that choice changes.
4. A signal-definition comment immediately above each declaration explains the
   declared signal where it enters the code.

For any channel, an operation completes only on a rising edge where its
`VALID` and `READY` are both HIGH. Visible payload without that handshake is
not an accepted transfer.

## Exact-source integrity notes

- Lesson 72 refers to Vivado-generated `design_1_wrapper`, which is not
  included on the downloadable page.
- Lesson 72 also ends without `endmodule`. The missing terminator is preserved
  and deliberately reported by the compile checker instead of being silently
  repaired.
- Lesson 92's page repeats the testbench after the design module. The design is
  stored once under lesson 92, and the dedicated lesson 93 testbench is the
  canonical `tb_axilite_m.sv`.
- Lesson 100's testbench instantiates `axilite_m`, while its supplied GPIO
  design module is named `axilite_s`. Both names are preserved, so the full
  lesson-100 pair intentionally stops at elaboration with that mismatch.
- Lesson 100 uses `6'h004` and `6'h008` for the GPIO offsets. Icarus warns that
  those literals contain extra hex digits; their retained values resolve to
  offsets 4 and 8.
- Lessons 112 and 127 instantiate the Vivado-generated
  `axi_protocol_checker_0`, which is not included in either downloadable code
  resource. Their manager and subordinate RTL compile independently; the
  integration tops require that external IP.
- The lesson 124/125 WRAP-read helper retains two references to write-helper
  scratch addresses (`addr1` and `addr4`) where the read scratch addresses
  would be expected. Inline comments record the possible stale/unknown-address
  behavior without changing the instructor's statements.

## Compile check

Run this from the current directory:

```powershell
powershell -ExecutionPolicy Bypass -File .\verify.ps1
```

The checker uses Icarus Verilog in SystemVerilog-2012 mode and writes temporary
outputs outside the repository. It compiles only; it does not run observational
testbenches that stop interactively.

The checked baseline is:

- 7 of 7 independently usable RTL components compile, including the design
  modules inside all four incomplete integration/testbench packages;
- 11 of 15 complete course-unit builds compile;
- 4 course-unit builds stop exactly where documented: lesson 72's missing
  terminator, lesson 100's DUT-name mismatch, and the two absent protocol-checker
  IP instances in lessons 112 and 127;
- 0 unexpected compile failures.
