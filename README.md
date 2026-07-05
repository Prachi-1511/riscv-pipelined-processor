# RISC-V Pipelined Processor (RV32I)

A fully pipelined 32-bit RISC-V processor implementing the RV32I base ISA,
extended with branch prediction and a two-level cache hierarchy, built as a
30-day structured RTL design project. Designed to demonstrate industry-relevant
skills in digital design, verification, and hardware architecture for frontend
semiconductor roles — RTL Design, Design Verification (DV), and DFT.

**Tools:** Icarus Verilog · GTKWave · Vivado · VS Code
**Language:** Verilog (IEEE 1364-2005)
**ISA:** RISC-V RV32I (40 instructions)

---

## Architecture Overview

┌─────────────────────────────────────────────────────────────┐
  │                   5-Stage Pipeline                          │
  │                                                              │
  │  ┌──────┐  ┌──────┐  ┌──────┐  ┌──────┐  ┌──────┐          │
  │  │  IF  │  │  ID  │  │  EX  │  │ MEM  │  │  WB  │          │
  │  │      │  │      │  │      │  │      │  │      │          │
  │  │ICACHE│  │ REG  │  │ ALU  │  │DCACHE│  │ MUX  │          │
  │  │  PC  │  │ CTRL │  │ FWD  │  │      │  │      │          │
  │  └──┬───┘  └──┬───┘  └──┬───┘  └──┬───┘  └──┬───┘          │
  │   IF/ID     ID/EX     EX/MEM    MEM/WB                     │
  │  ┌──┴───┐  ┌──┴───┐  ┌──┴───┐  ┌──┴───┐                   │
  │  │ REG  │  │ REG  │  │ REG  │  │ REG  │                   │
  │  └──────┘  └──────┘  └──────┘  └──────┘                   │
  │                                                              │
  │  ┌────────────┐ ┌─────────────┐ ┌──────────────────────┐   │
  │  │Hazard Unit │ │ Forwarding  │ │  Branch Predictor    │   │
  │  │(load-use)  │ │  Unit       │ │  64-entry BHT, 2-bit │   │
  │  └────────────┘ └─────────────┘ └──────────────────────┘   │
  │                                                              │
  │  ┌──────────────────────────────────────────────────────┐  │
  │  │  Cache Controller — 2-state FSM, AMAT-based stall     │  │
  │  └──────────────────────────────────────────────────────┘  │
  └─────────────────────────────────────────────────────────────┘

  ---

## Implementation Status

| Day | Topic | Key Modules | Status |
|-----|-------|------------|--------|
| 01 | RISC-V ISA & Instruction Formats | `riscv_defs.vh` | ✅ Complete |
| 02 | ALU Design | `alu.v`, `alu_tb.v` | ✅ Complete |
| 03 | Register File | `regfile.v`, `regfile_tb.v` | ✅ Complete |
| 04 | Instruction Memory & PC | `imem.v`, `pc.v`, `fetch_tb.v` | ✅ Complete |
| 05 | Decode & Control Unit | `control.v`, `imm_gen.v` | ✅ Complete |
| 06 | Single-Cycle Datapath | `single_cycle.v`, `dmem.v` | ✅ Complete |
| 07 | Verification & Testbench | `top_cycle_tb.v` | ✅ Complete |
| 08 | Pipeline Registers | `pipeline_regs.v` | ✅ Complete |
| 09 | IF and ID Stages | `if_stage.v`, `id_stage.v` | ✅ Complete |
| 10 | EX Stage + Forwarding MUX | `ex_stage.v` | ✅ Complete |
| 11 | MEM and WB Stages | `mem_stage.v`, `wb_stage.v` | ✅ Complete |
| 12 | Hazard Detection Unit | `hazard_unit.v` | ✅ Complete |
| 13 | Data Forwarding Unit | `forwarding_unit.v` | ✅ Complete |
| 14 | Full Pipeline Integration | `top_pipeline.v` | ✅ Complete |
| 15 | Branch Hazards & Flush | `program_branch.hex` | ✅ Complete |
| 16 | Static Branch Prediction | `branch_predictor.v`, `branch_perf_tb.v` | ✅ Complete |
| 17 | 2-Bit Dynamic Predictor (BHT) | `bht_tb.v` | ✅ Complete |
| 18 | Instruction Cache | `icache.v`, `icache_tb.v` | ✅ Complete — 7/0 |
| 19 | Data Cache (write-through, dirty bit) | `dcache.v`, `dcache_tb.v` | ✅ Complete — 6/0 |
| 20 | Cache Miss Handling + AMAT | `cache_ctrl.v`, `cache_ctrl_tb.v` | ✅ Complete — 2/0 |
| 21 | Full Cache Integration into Pipeline | `top_pipeline.v` (updated) | ⏳ In Progress |
| 22 | AXI4-Lite Protocol Basics | — | ⏳ Pending |
| 23 | AXI4-Lite Master FSM | — | ⏳ Pending |
| 24 | AXI4-Lite Slave + Loopback Test | — | ⏳ Pending |
| 25 | Performance Counters (CSRs) | — | ⏳ Pending |
| 26 | SoC Top-Level Integration | — | ⏳ Pending |
| 27 | SystemVerilog Assertions (SVA) | — | ⏳ Pending |
| 28 | Functional Coverage | — | ⏳ Pending |
| 29 | DFT Primer (scan chain concepts) | — | ⏳ Pending |
| 30 | Synthesis, Gate-Level Sim, Portfolio Polish | — | ⏳ Pending |

---

## Repository Structure

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
│   ├── branch_predictor.v  # 64-entry BHT, 2-bit saturating counters
│   ├── icache.v            # Direct-mapped instruction cache (16 sets)
│   ├── dcache.v            # Write-through data cache with dirty bit
│   ├── cache_ctrl.v        # Miss-handling FSM, parameterized MISS_PENALTY
│   ├── single_cycle.v      # Single-cycle processor (Days 1-7 baseline)
│   └── top_pipeline.v      # Pipelined processor top-level (cache-integrated)
├── tb/                     # Testbenches (simulation only)
│   ├── alu_tb.v
│   ├── regfile_tb.v
│   ├── fetch_tb.v
│   ├── pipeline_regs_tb.v
│   ├── ifid_tb.v
│   ├── hazard_tb.v
│   ├── forwarding_tb.v
│   ├── single_cycle_tb.v
│   ├── top_cycle_tb.v
│   ├── pipeline_full_tb.v
│   ├── pipeline_final_tb.v
│   ├── bht_tb.v
│   ├── branch_perf_tb.v
│   ├── icache_tb.v
│   ├── dcache_tb.v
│   ├── cache_ctrl_tb.v
│   └── top_pipeline_cache_tb.v
├── sim/                    # Simulation scripts and hex programs
│   ├── program_full.hex    # Exercise every instruction type built
│   ├── program_hazard.hex  # Back-to-back RAW hazard test (no NOPs)
│   ├── program_nops.hex    # Same program with NOPs (pre-forwarding baseline)
│   ├── program_branch.hex  # Checks if branch is correctly predicted
│   ├── program_loop.hex    # Branch loop — if_flush/id_flush verification
│   └── run_all.sh          # Compile and run all testbenches
├── docs/                   # Design documentation
│   ├── test_plan.md        # Verification test plan
│   ├── architecture.md     # Detailed architecture notes
│   └── waveforms/          # GTKWave screenshots
├── constraints/            # Synthesis and FPGA constraints (Day 28+)
└── README.md               # This file

---

## Quick Start

### Prerequisites
```bash
# Install Icarus Verilog
sudo apt-get install iverilog gtkwave    # Ubuntu/Debian
brew install icarus-verilog gtkwave      # macOS
```

### Run the single-cycle processor
```bash
iverilog -o top_sim rtl/riscv_defs.vh rtl/pc.v rtl/imem.v rtl/regfile.v \
         rtl/alu.v rtl/control.v rtl/imm_gen.v rtl/dmem.v \
         rtl/single_cycle.v tb/single_cycle_tb.v
vvp single_sim
```

### Run the pipelined processor (Days 8-17)
```bash
iverilog -o fullpipe_sim rtl/riscv_defs.vh rtl/pc.v rtl/imem.v rtl/regfile.v \
         rtl/alu.v rtl/control.v rtl/imm_gen.v rtl/dmem.v \
         rtl/pipeline_regs.v rtl/if_stage.v rtl/id_stage.v rtl/ex_stage.v \
         rtl/mem_stage.v rtl/wb_stage.v rtl/hazard_unit.v \
         rtl/forwarding_unit.v rtl/branch_predictor.v rtl/top_pipeline.v \
         tb/pipeline_full_tb.v
vvp fullpipe_sim
```

### Run the cache-integrated pipeline (Days 18-21)
```bash
iverilog -o cachepipe_sim rtl/top_pipeline.v rtl/icache.v rtl/dcache.v \
         rtl/cache_ctrl.v rtl/pipeline_regs.v rtl/if_stage.v rtl/id_stage.v \
         rtl/ex_stage.v rtl/mem_stage.v rtl/wb_stage.v rtl/hazard_unit.v \
         rtl/forwarding_unit.v rtl/branch_predictor.v \
         tb/top_pipeline_cache_tb.v
vvp cachepipe_sim
```

### View waveforms
```bash
gtkwave sim/pipeline_final.vcd
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

### Branch flush vs load-use stall — two different mechanisms, same signals
A taken branch triggers a genuine 2-cycle flush: `if_flush` kills the
wrong-path instruction in IF/ID, `id_flush` kills the one already in ID/EX.
This is the only case where `if_flush` is ever asserted — reusing the exact
signal names from the load-use hazard unit, but for a structurally different
reason (destroying wrong-path instructions vs. preserving a correct one).

### Branch prediction — 64-entry BHT, 2-bit saturating counters
Indexed by `pc[7:2]` (6 bits → 64 entries; bits[1:0] carry no information
due to word alignment). Each entry only flips prediction after two
consecutive contrary outcomes, filtering single-iteration noise. Measured
result: misprediction rate dropped from 87.5% (static predict-not-taken) to
25% (2-bit BHT), cutting branch penalty cycles by 71%.

### Cache address decoding (16-set, direct-mapped, 1 word/block)
`tag[31:6]` (26 bits) | `index[5:2]` (4 bits) | `offset[1:0]` (unused —
block size is 1 word). Index directly selects a storage slot (no
associative search); tag comparison confirms correctness before signalling
hit. Two addresses with the same index but different tags conflict and
evict each other — verified explicitly in `icache_tb.v` and `dcache_tb.v`.

### Write-through + write-allocate (D-Cache)
Cache and main memory are updated together on every write (write-through),
and a write miss still loads the line into cache (write-allocate). A dirty
bit is tracked per line for observability, even though write-through does
not functionally require it — this establishes the mechanism needed for
write-back-style eviction later. Write-through/write-back and
write-allocate/write-no-allocate are two independent design axes and are
never conflated.

### Cache miss handling — AMAT model
`AMAT = Hit Time + (Miss Rate × Miss Penalty)`. A 2-state FSM
(IDLE / MISS_WAIT) asserts `stall` the cycle a miss is detected, counts
down a parameterized `MISS_PENALTY`, then pulses `fill_trigger` for exactly
one cycle — a single pulse, not a held level, so the same line is never
refilled repeatedly while stalled.

### Asynchronous read, synchronous write
Registers, caches, and data memory all use combinational reads and clocked
writes. This ensures data is available within the same clock cycle it is
requested, while state changes remain glitch-free and edge-triggered.

### Write-before-read bypass in register file
When WB writes to a register that ID simultaneously reads (same cycle),
the register file returns the new write data directly rather than the
stale stored value — handling the 3-cycle RAW distance without a third
forwarding path.

### Testbench-DUT edge alignment
All DUTs update state on `posedge clk`. Testbenches sample and drive on
`negedge clk` — exactly half a cycle later — so every check reads fully
settled data instead of racing the DUT's own clock edge.

---

## Verification Summary (Days 1-20)

| Testbench | Coverage | Result |
|-----------|----------|--------|
| `alu_tb.v` | All 10 ALU ops | ✅ PASS |
| `regfile_tb.v` | Write, read, x0 guard, WBR bypass | ✅ PASS |
| `fetch_tb.v` | Sequential fetch, PC+4 | ✅ PASS |
| `top_single_cycle_tb.v` | ADD, SUB, AND, OR, SLT, SW, LW, BEQ | ✅ PASS |
| `pipeline_regs_tb.v` | Stall, flush, normal advance | ✅ 15 PASS |
| `forwarding_tb.v` | Back-to-back RAW hazards | ✅ PASS |
| `pipeline_final_tb.v` | Full pipeline, all hazard types | ✅ 15 PASS, 0 FAIL |
| `branch_perf_tb.v` / `bht_tb.v` | Static vs 2-bit BHT, 8-iteration loop | ✅ 15 PASS, 0 FAIL |
| `icache_tb.v` | Cold miss, fill/hit, conflict eviction, set isolation | ✅ 7 PASS, 0 FAIL |
| `dcache_tb.v` | Write→read-back hit, dirty bit, conflict eviction | ✅ 6 PASS, 0 FAIL |
| `cache_ctrl_tb.v` | Stall duration = MISS_PENALTY, single fill_trigger pulse | ✅ 2 PASS, 0 FAIL |

---

## Performance Analysis

| Metric | Single-cycle | Pipelined (Day 17) |
|--------|-------------|----------------------|
| CPI | 1.0 | ~1.0 (non-load) / 2.0 (load-use) |
| Max frequency | ~125 MHz (8ns path) | ~400 MHz |
| Throughput | 125 MIPS | ~2.67x improvement |
| Branch misprediction rate | N/A | 25% (BHT) vs 87.5% (static) |
| Branch penalty reduction | N/A | 14 → 4 cycles (71%) |
| AMAT (10% miss rate, 4-cycle penalty) | N/A | 1.4 cycles |

---

## Learning Outcomes Demonstrated

- **RTL design:** Fully pipelined datapath from scratch in synthesisable Verilog
- **Hazard handling:** Load-use stall, data forwarding, branch flush, 2-bit dynamic branch prediction
- **Memory hierarchy:** Direct-mapped I-Cache/D-Cache, write-through + dirty bit, miss-handling FSM, AMAT analysis
- **Verification:** Self-checking testbenches with PASS/FAIL assertions; correct DUT/testbench clock-edge alignment
- **ISA knowledge:** All 6 RV32I instruction formats, full opcode/funct3/funct7 decode
- **Timing:** Synchronous vs asynchronous logic; flip-flop vs combinational inference
- **Tools:** Icarus Verilog simulation, GTKWave waveform analysis, Vivado synthesis (Day 28+)

---

## Author

**Prachi** — BTech (NIT Kurukshetra)
Targeting frontend semiconductor roles: RTL Design, Design Verification, DFT