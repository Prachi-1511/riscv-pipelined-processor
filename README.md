# RISC-V Pipelined Processor (RV32I)

A fully pipelined 32-bit RISC-V processor implementing the RV32I base ISA,
built as a 30-day structured RTL design project. Designed to demonstrate
industry-relevant skills in digital design, verification, and hardware
architecture for frontend semiconductor roles.
 
**Tools:** Icarus Verilog · GTKWave · Vivado · VS Code  
**Language:** Verilog (IEEE 1364-2005)  
**ISA:** RISC-V RV32I (40 instructions)

---

## Architecture Overview

```
      ┌─────────────────────────────────────────────────────────────┐
      │                   5-Stage Pipeline                          │
      │                                                             │
      │  ┌──────┐  ┌──────┐  ┌──────┐  ┌──────┐  ┌──────┐        │
      │  │  IF  │  │  ID  │  │  EX  │  │ MEM  │  │  WB  │        │
      │  │      │  │      │  │      │  │      │  │      │        │
      │  │ IMEM │  │ REG  │  │ ALU  │  │DMEM  │  │ MUX  │        │
      │  │  PC  │  │ CTRL │  │ FWD  │  │      │  │      │        │
      │  └──┬───┘  └──┬───┘  └──┬───┘  └──┬───┘  └──┬───┘        │
      │   IF/ID     ID/EX     EX/MEM    MEM/WB                    │
      │  ┌──┴───┐  ┌──┴───┐  ┌──┴───┐  ┌──┴───┐                  │
      │  │ REG  │  │ REG  │  │ REG  │  │ REG  │                  │
      │  └──────┘  └──────┘  └──────┘  └──────┘                  │
      │                                                             │
      │  ┌─────────────────┐   ┌──────────────────────┐           │
      │  │  Hazard Unit     │   │   Forwarding Unit     │           │
      │  │  (load-use stall)│   │  (EX/MEM + MEM/WB)    │           │
      │  └─────────────────┘   └──────────────────────┘           │
      └─────────────────────────────────────────────────────────────┘
```

---

## Implementation Status

| Day | Topic | Key Modules | Status |
|-----|-------|------------|--------|
| 01 | RISC-V ISA & Instruction Formats | `riscv_defs.vh` | ✅ Complete |
| 02 | ALU Design | `alu.v`, `alu_tb.v` | ✅ Complete |
| 03 | Register File | `regfile.v`, `regfile_tb.v` | ✅ Complete |
| 04 | Instruction Memory & PC | `imem.v`, `pc.v`, `fetch_tb.v` | ✅ Complete |
| 05 | Decode & Control Unit | `control.v`, `imm_gen.v` | ✅ Complete |
| 06 | Single-Cycle Datapath | `top_single_cycle.v`, `dmem.v` | ✅ Complete |
| 07 | Verification & Testbench | `top_single_cycle_tb.v` | ✅ Complete |
| 08 | Pipeline Registers | `pipeline_regs.v` | ✅ Complete |
| 09 | IF and ID Stages | `if_stage.v`, `id_stage.v` | ✅ Complete |
| 10 | EX Stage + Forwarding MUX | `ex_stage.v` | ✅ Complete |
| 11 | MEM and WB Stages | `mem_stage.v`, `wb_stage.v` | ✅ Complete |
| 12 | Hazard Detection Unit | `hazard_unit.v` | ✅ Complete |
| 13 | Data Forwarding Unit | `forwarding_unit.v` | ✅ Complete |
| 14 | Full Pipeline Integration | `top_pipeline.v` | 🔄 In Progress |
| 15 | Branch Hazards & Flush | — | ⏳ Pending |
| 16 | Static Branch Prediction | — | ⏳ Pending |
| 17 | 2-Bit Dynamic Predictor | — | ⏳ Pending |
| 18 | Instruction Cache | — | ⏳ Pending |
| 19 | Data Cache | — | ⏳ Pending |
| 20 | Cache Miss Handling | — | ⏳ Pending |
| 21 | Cache Integration | — | ⏳ Pending |
| 22 | AXI4-Lite Protocol | — | ⏳ Pending |
| 23 | AXI4-Lite Master | — | ⏳ Pending |
| 24 | AXI4-Lite Slave Memory | — | ⏳ Pending |
| 25 | Performance Counters | — | ⏳ Pending |
| 26 | Full System Integration | — | ⏳ Pending |
| 27 | Comprehensive Testbench | — | ⏳ Pending |
| 28 | Synthesis | — | ⏳ Pending |
| 29 | Timing Analysis | — | ⏳ Pending |
| 30 | Portfolio Finalization | — | ⏳ Pending |

---

## Repository Structure

```
riscv-pipelined-processor/
├── rtl/                    # RTL source files (synthesisable Verilog)
│   ├── riscv_defs.vh       # ISA constants — opcodes, funct3, ALU ops
│   ├── alu.v               # 32-bit ALU (ADD/SUB/AND/OR/XOR/SLT/shifts)
│   ├── regfile.v           # 32×32 register file, async read, sync write
│   ├── imem.v              # Instruction memory (ROM, $readmemh)
│   ├── dmem.v              # Data memory (async read, sync write)
│   ├── pc.v                # Program counter with stall and branch
│   ├── control.v           # Main control unit (opcode → control signals)
│   ├── imm_gen.v           # Immediate generator (all 6 RV32I formats)
│   ├── hazard_unit.v       # Load-use hazard detection
│   ├── forwarding_unit.v   # EX/MEM and MEM/WB data forwarding
│   ├── pipeline_regs.v     # IF/ID, ID/EX, EX/MEM, MEM/WB registers
│   ├── if_stage.v          # Instruction fetch stage
│   ├── id_stage.v          # Instruction decode stage
│   ├── ex_stage.v          # Execute stage (ALU + forwarding MUXes)
│   ├── mem_stage.v         # Memory access stage
│   ├── wb_stage.v          # Write-back stage
│   ├── top_single_cycle.v  # Single-cycle processor (Days 1-7 baseline)
│   └── top_pipeline.v      # Pipelined processor top-level
├── tb/                     # Testbenches (simulation only)
│   ├── alu_tb.v
│   ├── regfile_tb.v
│   ├── fetch_tb.v
│   ├── pipeline_regs_tb.v
│   ├── if_id_tb.v
│   ├── hazard_tb.v
│   ├── forwarding_tb.v
│   ├── top_single_cycle_tb.v
│   └── pipeline_full_tb.v
├── sim/                    # Simulation scripts and hex programs
│   ├── program.hex         # Basic 3-instruction test (ADDI, ADDI, ADD)
│   ├── program_hazard.hex  # Back-to-back RAW hazard test (no NOPs)
│   ├── program_nops.hex    # Same program with NOPs (pre-forwarding baseline)
│   └── run_all.sh          # Compile and run all testbenches
├── docs/                   # Design documentation
│   ├── test_plan.md        # Verification test plan
│   ├── architecture.md     # Detailed architecture notes
│   └── waveforms/          # GTKWave screenshots
├── constraints/            # Synthesis and FPGA constraints (Day 28+)
└── README.md               # This file
```

---

## Quick Start

### Prerequisites
```bash
# Install Icarus Verilog
sudo apt-get install iverilog gtkwave    # Ubuntu/Debian
brew install icarus-verilog gtkwave     # macOS
```

### Run the single-cycle processor
```bash
iverilog -o sc_sim rtl/riscv_defs.vh rtl/pc.v rtl/imem.v rtl/regfile.v \
         rtl/alu.v rtl/control.v rtl/imm_gen.v rtl/dmem.v \
         rtl/top_single_cycle.v tb/top_single_cycle_tb.v
vvp sc_sim
```

### Run the pipelined processor (Days 8-13)
```bash
iverilog -o pipe_sim rtl/riscv_defs.vh rtl/pc.v rtl/imem.v rtl/regfile.v \
         rtl/alu.v rtl/control.v rtl/imm_gen.v rtl/dmem.v \
         rtl/pipeline_regs.v rtl/if_stage.v rtl/id_stage.v rtl/ex_stage.v \
         rtl/mem_stage.v rtl/wb_stage.v rtl/hazard_unit.v \
         rtl/forwarding_unit.v rtl/top_pipeline.v tb/pipeline_full_tb.v
vvp pipe_sim
```

### View waveforms
```bash
gtkwave pipeline.vcd
```

---

## Key Design Decisions

### Forwarding priority (EX/MEM over MEM/WB)
When two upstream instructions both write the same register, the forwarding
unit always selects the more recent value (EX/MEM) over the older one
(MEM/WB). Implemented as `if/else if`, not independent `if` statements —
this synthesises to a priority encoder, not a parallel MUX.

### Load-use hazard: stall vs flush
A load-use hazard requires exactly one pipeline bubble. The hazard unit:
- **Freezes** PC and IF/ID (stall=1) — holds the dependent instruction
- **Flushes** ID/EX (id_flush=1) — inserts a NOP bubble downstream
- `if_flush` stays **0** — the dependent instruction must be preserved,
  not killed. Confusing stall and flush here is the most common pipeline bug.

### Asynchronous read, synchronous write
Both the register file and data memory use combinational reads and
clocked writes. This ensures data is available within the same clock
cycle it is requested — critical for single-cycle ID-stage register reads
in a pipelined design.

### Write-before-read bypass in register file
When WB writes to a register that ID simultaneously reads (same cycle),
the register file returns the new write data directly rather than the
stale stored value. This handles the 3-cycle RAW distance transparently
without requiring a forwarding path from WB to EX.

---

## Verification Summary (Days 1-13)

| Testbench | Instructions tested | Hazard coverage | Result |
|-----------|-------------------|-----------------|--------|
| `alu_tb.v` | All 10 ALU ops | N/A | ✅ PASS |
| `regfile_tb.v` | Write, read, x0 guard, WBR bypass | N/A | ✅ PASS |
| `fetch_tb.v` | Sequential fetch, PC+4 | N/A | ✅ PASS |
| `top_single_cycle_tb.v` | ADD, SUB, AND, OR, SLT, SW, LW, BEQ | Single-cycle | ✅ PASS |
| `pipeline_regs_tb.v` | Stall, flush, normal advance | IF/ID register | ✅ PASS |
| `pipeline_full_tb.v` (NOPs) | ADDI, ADDI, ADD with spacing | None | ✅ PASS |
| `forwarding_tb.v` | Back-to-back RAW hazards | EX/MEM + MEM/WB | ✅ PASS |

---

## Performance Analysis

| Metric | Single-cycle | Pipelined (Days 8-13) |
|--------|-------------|----------------------|
| CPI | 1.0 | ~1.0 (non-load) / 2.0 (load-use) |
| Max frequency | 125 MHz (8ns path) | ~400 MHz (2ns/stage) |
| Throughput | 125 MIPS | ~333 MIPS |
| Load-use penalty | 0 (one cycle) | 1 cycle stall |
| RAW hazard penalty | N/A | 0 (forwarded) |

---

## Learning Outcomes Demonstrated

- **RTL design:** Fully pipelined datapath from scratch in synthesisable Verilog
- **Hazard handling:** Load-use stall detection; data forwarding (EX/MEM + MEM/WB)
- **Verification:** Self-checking testbenches with PASS/FAIL assertions
- **ISA knowledge:** All 6 RV32I instruction formats, full opcode/funct3/funct7 decode
- **Timing:** Synchronous vs asynchronous logic; flip-flop vs combinational inference
- **Tools:** Icarus Verilog simulation, GTKWave waveform analysis

---

## Author

**Prachi** — BTech (NIT Kurukshetra)  
Targeting frontend semiconductor roles: RTL Design, Design Verification, DFT  