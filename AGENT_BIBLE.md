# ==============================================================================
# RISC-V RTL-TO-GDSII: THE AGENT BIBLE & MASTER PROJECT DOSSIER
# ==============================================================================

> **CONFIDENTIAL & MASTER REFERENCE**
> **Project:** Synthesizable RV32I Single-Cycle Processor from Scratch to Silicon (GDSII)
> **Author / Engineer:** Prasad Kale (ECE / VLSI Student)
> **GitHub:** https://github.com/prasad995/riscv-rtl-to-gds
> **Industry Mentor:** Sindhu Vollala
> **Active Environment:** WSL2 Ubuntu on Windows (User: `prasad`)
> **Primary Linux Working Directory:** `/home/prasad/riscv-rtl-to-gds`
> **Windows Mirror & Documentation Folder:** `C:\Users\kalep\OneDrive\Desktop\rtl to gds`
> **Status:** Phase 3 100% Complete (33/33 Tests Passed) | Phase 4 Starting

---

## 1. TEACHING & INTERACTION RULES (NON-NEGOTIABLE)

1. **Why Before What:** Always explain the physical/engineering *why* before giving commands or technical syntax.
2. **Simple Language First:** Explain the intuitive analogy first, followed by the rigorous VLSI standard.
3. **Predict Before Run:** Before running any simulation or script, require an explicit output prediction and compare against actual results.
4. **Evidence Over Claims:** Never accept "done" or "understood" without pasted terminal logs, timestamped waveforms, or Git commit hashes.
5. **Ready-to-Paste Code:** Provide complete, unabbreviated files using heredocs: `cat > path << 'EOF' ... EOF`.
6. **Root Cause Analysis:** When debugging, diagnose the architectural/logic root cause, not just the symptomatic fix.
7. **Schedule Honesty:** Never sugarcoat deadlines or tool limitations.

---

## 2. ENVIRONMENT & DIRECTORY MAPPING

| Scope | Location |
|---|---|
| **WSL2 Active Repo (Source of Truth)** | `/home/prasad/riscv-rtl-to-gds` |
| **Windows Mirror & Backup Folder** | `C:\Users\kalep\OneDrive\Desktop\rtl to gds` |
| **WSL Path to Windows Mirror** | `/mnt/c/Users/kalep/OneDrive/Desktop/rtl\ to\ gds` |
| **GitHub Remote** | `https://github.com/prasad995/riscv-rtl-to-gds.git` |
| **Git Auth Method** | GitHub Classic PAT (90-day expiry), saved via `git config --global credential.helper store` |
| **Installed EDA Tools** | Icarus Verilog 12.0 (`iverilog`, `vvp`), GTKWave 3.3.126, GNU Make, Git |
| **Pending EDA Tools** | Yosys (Synthesis), OpenLane / OpenROAD, SkyWater 130nm PDK, KLayout |

---

## 3. ARCHITECTURAL SPECIFICATION (RV32I SINGLE-CYCLE)

- **Instruction Set:** RV32I Base Integer ISA (32-bit instructions and registers).
- **Architecture Model:** Harvard Architecture (independent instruction memory and data memory).
- **Execution Model:** Single-cycle unpipelined (1 instruction per clock cycle).
- **Registers:** 32 general-purpose 32-bit registers ($x0$ hardwired to 0 on reads and writes; no hardware reset).
- **Instruction Formats:** R, I, S, B, U, J (with immediate scrambled bit-reconstruction).
- **ALU (10 Ops):** ADD (0000), SUB (0001), AND (0010), OR (0011), XOR (0100), SLL (0101), SRL (0110), SRA (0111), SLT (1000), SLTU (1001).
- **Control Unit Signals (10 total):**
  - `reg_write`, `alu_src`, `mem_read`, `mem_write`, `mem_to_reg`, `branch`, `jump`, `alu_op[3:0]`, `a_sel[1:0]`.
  - `a_sel` multiplexer control: `00 = rs1`, `01 = PC` (for AUIPC), `10 = Zero` (for LUI).
- **Branch & Jump Logic:**
  - Branch taken: `BEQ`, `BNE`, `BLT`, `BGE`, `BLTU`, `BGEU` evaluating comparator conditions.
  - Next-PC selection: `pc_src = jump || (branch && taken)`.
  - `JAL` target: $\text{PC} + \text{imm}$.
  - `JALR` target: $(\text{rs1} + \text{imm}) \ \& \ \sim 1$ (LSB cleared for word alignment).
- **Memory Subsystems:**
  - `instr_mem`: 1024 words (4 KB), combinational unclocked read.
  - `data_mem`: 4096 bytes (4 KB), Little-Endian, clocked write on posedge, combinational read with sign/zero extension via `funct3` (`lb`, `lh`, `lw`, `lbu`, `lhu`, `sb`, `sh`, `sw`).
- **Gating Decisions:** `reg_write` and `mem_write` are gated with `~rst` to prevent state corruption during reset.

---

## 4. MODULE DIRECTORY & FILE INVENTORY

```text
riscv-rtl-to-gds/
├── rtl/
│   ├── alu.v                 # 10-op arithmetic logic unit
│   ├── branch_jump_logic.v   # Branch condition checker & target calculator
│   ├── control_unit.v        # Main control decoder with a_sel
│   ├── data_mem.v            # 4KB Little-Endian data RAM
│   ├── imm_gen.v             # Immediate bit-reconstruction generator
│   ├── instr_decoder.v       # Pure bit-slicing instruction decoder
│   ├── instr_mem.v           # 1024-word instruction ROM loaded via $readmemh
│   ├── program_counter.v     # 32-bit PC register with async reset
│   ├── register_file.v       # 32x32 register file (x0 protected)
│   └── riscv_cpu.v           # Top-level datapath & multiplexer glue logic
├── tb/
│   ├── tb_alu.v / tb_branch_jump_logic.v / tb_control_unit.v
│   ├── tb_data_mem.v / tb_imm_gen.v / tb_instr_decoder.v
│   ├── tb_instr_mem.v / tb_program_counter.v / tb_register_file.v
│   ├── tb_riscv_cpu.v        # Master integration testbench
│   ├── test_addsub.hex       # Test 1: addi, add, sub
│   ├── test_logic.hex        # Test 2: and, or, xor, sll, srl, sra
│   ├── test_upper.hex        # Test 3: lui, auipc
│   ├── test_mem.hex          # Test 4: sw, lw, sb, lb, lbu
│   ├── test_branch.hex       # Test 5: beq, bne (5-iteration loop)
│   └── test_jal.hex          # Test 6: jal, jalr subroutine call/return
├── docs/
│   ├── images/
│   │   ├── datapath.svg      # Clean architectural datapath vector
│   │   └── gtkwave_sim.png   # Full GTKWave verified simulation waveform
├── Makefile                  # Automated make / make wave / make clean build system
└── README.md                 # Complete repository documentation
```

---

## 5. COMPLETE VERIFICATION RECORD (PHASE 3: 33/33 PASSED)

| Test ID | File | Target Instructions | Key Checks Verified | Result |
|:---:|---|---|---|:---:|
| **T1** | `test_addsub.hex` | `addi`, `add`, `sub` | $x1=5$, $x2=10$, $x3=15$, $x4=\text{-1}$, $x5=\text{-6}$ | **PASS (5/5)** |
| **T2** | `test_logic.hex` | `and`, `or`, `xor`, `sll`, `srl`, `sra` | Bitwise logic, SRA sign replication ($x10=\text{0xFFFFFFF0}$), SRL zero-fill ($x11=\text{0x0FFFFFF0}$) | **PASS (11/11)** |
| **T3** | `test_upper.hex` | `lui`, `auipc` | 32-bit constant ($0x12345678$), AUIPC PC+imm ($0x1008$), PC capture ($0x0C$) | **PASS (3/3)** |
| **T4** | `test_mem.hex` | `sw`, `lw`, `sb`, `lb`, `lbu` | Little-Endian RAM store/load, signed byte LB ($0xFFFFFF85$), unsigned byte LBU ($0x00000085$) | **PASS (6/6)** |
| **T5** | `test_branch.hex` | `beq`, `bne` | 5-iteration countdown loop ($sum=15$, $count=0$), forward branch skipping instruction 99 ($x5=42$) | **PASS (5/5)** |
| **T6** | `test_jal.hex` | `jal`, `jalr` | Function call to $0x10$, return address in $ra=0x08$, return via $jalr$ back to $0x08$ | **PASS (3/3)** |

---

## 6. PHASE ROADMAP & HOURS BUDGET

| Phase | Description | Hours | Target Date | Status |
|---|---|:---:|:---:|:---:|
| **Phase 0** | Linux, WSL2, Git, iverilog, GTKWave setup | 8–10 hrs | Completed | ✅ DONE |
| **Phase 1** | RISC-V RV32I architecture theory & encoding | 15 hrs | Completed | ✅ DONE |
| **Phase 2** | 10 RTL modules design & unit testing | 20–25 hrs | Completed | ✅ DONE |
| **Phase 3** | Top-level integration & verification (33 tests) | 10–12 hrs | Completed | ✅ DONE |
| **Phase 4** | Yosys Logic Synthesis & Static Timing Analysis | 15–20 hrs | Mid-Nov 2026 | ⏳ IN PROGRESS |
| **Phase 5** | Physical Design to GDSII (OpenLane + Sky130) | 35–45 hrs | Early Dec 2026 | 🎯 STRETCH |

---

## 7. CRITICAL LESSONS & BUG REGISTRY

1. **JALR rd Encoding Bug:** An instruction encoded with `rd=x1` (`000080E7`) overwrites $x1$ with $\text{PC}+4$ on return. The proper return idiom `jalr x0, ra, 0` must have `rd=00000` (`00008067`).
2. **x0 Dual Protection:** Hardwiring $x0$ in Verilog requires *both* forcing reads to 0 (`rs == 0 ? 0 : registers[rs]`) and gating writes (`if (we && rd != 0)`).
3. **Reset Write-Gating:** Without gating `we & ~rst`, spurious writes can occur during active reset cycles.
4. **Credential Helper:** PAT expiration fixed via `git config --global credential.helper store` and `~/.git-credentials`.

---

## 8. CHRONOLOGICAL SESSION LOG & PROJECT HISTORY

### Session 1–3: Phases 0–2 (Foundation & Unit Modules)
- **Environment:** WSL2 Ubuntu on Windows 11, Icarus Verilog 12.0, GTKWave.
- **RTL Built:** 10 core modules (`program_counter`, `instr_mem`, `instr_decoder`, `control_unit`, `imm_gen`, `register_file`, `alu`, `branch_jump_logic`, `data_mem`, `riscv_cpu`).
- **Unit Verification:** Verified with individual testbenches in `tb/` and waveform exports.

### Session 4: Phase 3 (Top-Level Datapath Integration & Master Verification)
- **Status:** 100% Passed (33/33 total tests across 6 test suites).
- **Test Programs Verified:**
  - `test_addsub.hex`: ALU add/sub signed arithmetic.
  - `test_logic.hex`: Bitwise logical ops + arithmetic vs logical shifts.
  - `test_upper.hex`: `lui` and `auipc` 32-bit constant construction.
  - `test_mem.hex`: Little-Endian load/store byte & word memory operations.
  - `test_branch.hex`: Branch taken/not-taken 5-iteration loop execution.
  - `test_jal.hex`: Subroutine jump and link / return via register ra.
- **Deliverables:** Top-level simulation waveform captured (`docs/images/gtkwave_sim.png`), datapath architecture documented (`docs/images/datapath.svg`), master `README.md` finalized and pushed to GitHub.

### Session 5: Project Folder Realignment & Phase 4 Preparation (2026-10-29)
- **Directory Transition:** Folder renamed to `C:\Users\kalep\OneDrive\Desktop\rtl to gds` to match standard VLSI RTL-to-GDSII methodology.
- **Path Mapping Confirmed:**
  - Active Windows Location: `C:\Users\kalep\OneDrive\Desktop\rtl to gds`
  - Active WSL2 Linux Path: `/home/prasad/riscv-rtl-to-gds`
  - WSL Mount: `/mnt/c/Users/kalep/OneDrive/Desktop/rtl to gds`
- **EDA Tool Inventory Check:**
  - `iverilog`, `vvp`, `gtkwave`, `make`, `git` confirmed present.
  - `yosys` candidate 0.52 identified in Ubuntu universe repository.
- **Next Milestone:** Phase 4 Logic Synthesis kickoff (Yosys installation & synthesis script development for ALU & CPU core).

