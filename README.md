# RISCV_3CYCLED_PIPELINED_ARCH
# 3-Stage Pipelined RISC-V Processor (SystemVerilog)

This repository presents a **3-stage pipelined RISC-V processor** implemented in **SystemVerilog**, designed as part of a computer architecture coursework project.  
The implementation emphasizes **architectural clarity, correctness, and modular design**, following a clean and well-defined pipeline structure.

The processor supports a representative subset of the RISC-V ISA and demonstrates disciplined control-flow management, instruction propagation, and pipeline timing.

---

## Architecture Overview

The processor is organized into **three pipeline stages**, each with clearly defined responsibilities:

### Stage 1: Instruction Fetch (IF)
- Program Counter (PC) update logic
- Instruction memory access
- Sequential PC increment (PC + 4)
- Control-flow redirection for branches and jumps

### Stage 2: Instruction Decode / Execute (ID/EX)
- Instruction field decoding (opcode, funct3, funct7, rs1, rs2, rd)
- Immediate value generation
- Register file read
- ALU execution
- Branch condition evaluation
- Control signal generation

### Stage 3: Memory Access / Writeback (MEM/WB)
- Data memory access for load and store instructions
- Load width and signed/unsigned handling
- Writeback data selection (ALU result, memory data, or PC + 4)
- Register file writeback

---

## Pipeline Registers

The design explicitly implements pipeline registers to preserve instruction flow and timing:

### IF/ID Register
- Program Counter (PC)
- PC + 4
- Instruction Register (IR)

### EX/MEM Register
- ALU result
- Store data
- PC and PC + 4
- Instruction Register (IR)
- Associated control signals

The **PC and full instruction word are propagated across all stages**, enabling precise instruction tracking, debugging, and verification.

---

## Control and Data Path Design

- A centralized **controller module** generates all control signals
- The ALU supports arithmetic, logical, and comparison operations
- The immediate generator supports R, I, S, B, and J instruction formats
- Load and store operations support multiple data widths and signedness

All modules are designed with **clear interfaces and separation of concerns**, improving readability and extensibility.

---

## Hazard Handling Strategy

- **Control hazards** (branches, JAL, JALR) are resolved in the ID/EX stage
- Program Counter redirection is applied in the subsequent cycle
- Speculative execution and branch prediction are intentionally omitted
- **Data hazards are assumed to be handled through instruction scheduling**, consistent with the assignment scope

This approach favors **predictable timing and architectural transparency** over aggressive optimization.

---

## Module Overview

- `pc` – Program Counter logic
- `inst_mem` – Instruction memory
- `if_id_reg` – IF/ID pipeline register
- `inst_dec` – Instruction decoder
- `imm_gen` – Immediate generator
- `controller` – Control unit
- `reg_file` – Register file
- `alu` – Arithmetic Logic Unit
- `ex_mem_reg` – EX/MEM pipeline register
- `data_mem` – Data memory

Each module is independently testable and reusable.

---

## Key Design Highlights

- Clearly defined pipeline stages
- Accurate PC and instruction propagation
- Correct handling of branches, jumps, loads, and stores
- Modular and maintainable SystemVerilog codebase
- Strong foundation for future enhancements

---

## Notes

This processor is intended for **educational and architectural exploration** rather than high-performance synthesis.  
The design provides a solid baseline for extensions such as forwarding units, hazard detection logic, or deeper pipelines.
