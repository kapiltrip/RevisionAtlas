# Computer Architecture dictionary

[Dictionary index](README.md) | [Back to Subjects](../README.md)

## RISC and CISC

### RISC — favor a regular set of easily composed operations

- **Definition:** RISC is an ISA design approach that emphasizes regular
  instruction formats, register-based computation, and comparatively simple
  operations that software composes into larger tasks. The ratified RV32I base,
  for example, defines four fixed 32-bit core formats and is explicitly a
  load-store architecture: loads and stores access memory while arithmetic
  instructions operate on registers ([RISC-V RV32I specification](https://docs.riscv.org/reference/isa/v20260120/unpriv/rv32.html)).
- **Plain meaning:** Give the hardware a small set of consistent building blocks;
  use several blocks when a program needs a larger operation.
- **Hardware meaning:** Fixed field positions and a limited number of operand
  patterns tend to make instruction boundaries and operands easier to decode.
  The datapath can repeatedly move values through registers and relatively
  uniform execution paths. This helps pipelining, but does not guarantee that
  every instruction takes one cycle.
- **Why it matters:** Regularity can simplify the processor front end, compiler
  instruction selection, verification, and the design of small implementations.
  It can also increase the number of instructions required for a task.
- **Do not confuse it with:** “Few instruction mnemonics.” A modern RISC ISA may
  have many optional scalar, vector, atomic, compressed, and cryptographic
  extensions. The “reduced” idea concerns the simplicity and regularity of the
  base operations, not a permanently tiny instruction manual.
- **Examples:** RISC-V and Arm A64 are RISC-style ISAs. Arm states that A64 uses
  32-bit instructions with fields in consistent positions, while most A64
  instructions operate on registers ([Arm A64 ISA guide](https://developer.arm.com/documentation/102374/0103/Registers-in-AArch64---general-purpose-registers),
  [Arm A64 encoding overview](https://developer.arm.com/community/arm-community-blogs/b/architectures-and-processors-blog/posts/the-a64-isa-and-compilers)).

### CISC — expose richer operations and operand forms to software

- **Definition:** CISC is an ISA design approach that exposes relatively rich
  instruction semantics, numerous operand or addressing forms, and often
  variable-length encodings. Intel's x86 ISA is the standard current example;
  Intel's own encoder/decoder documentation specifies x86 instructions as
  1–15-byte values ([Intel XED user guide](https://intelxed.github.io/ref-manual/)).
- **Plain meaning:** Let one architectural instruction request more work or
  describe operands more flexibly.
- **Hardware meaning:** The processor front end must determine instruction
  boundaries and interpret optional prefixes, opcode fields, addressing fields,
  displacements, and immediates. An instruction may also combine a memory access
  with an ALU operation. The implementation is free to break that architectural
  instruction into internal operations.
- **Why it matters:** Rich encodings can reduce static instruction count and can
  preserve excellent code density and backward compatibility, but decoding and
  execution are less uniform.
- **Do not confuse it with:** “One instruction always does an entire high-level
  language statement.” Nor does CISC imply that every instruction is slow or
  microcoded.
- **Example:** Intel 64/IA-32 (x86) is CISC-style. Intel publishes separate
  instruction-format and instruction-reference volumes because the ISA supports
  a broad range of encodings and operations
  ([Intel 64 and IA-32 Software Developer's Manuals](https://www.intel.com/content/www/us/en/developer/articles/technical/intel-sdm.html)).
