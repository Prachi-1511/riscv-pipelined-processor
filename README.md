# RISC-V Pipelined Processor (RV32I)

A 5-stage pipelined RISC-V processor (RV32I ISA) implemented in Verilog.  
Built as a structured 30-day RTL design project for semiconductor industry preparation.

## Architecture
- 5-stage pipeline: IF → ID → EX → MEM → WB
- Full RV32I base integer instruction set
- Hazard detection and forwarding unit
- AXI4-Lite memory interface

## Project Structure
| Folder | Contents |
|--------|----------|
| `rtl/` | Synthesizable Verilog source files |
| `tb/` | Testbenches and verification |
| `docs/` | Architecture notes and diagrams |
| `sim/` | Simulation waveforms and logs |
| `constraints/` | Synthesis constraints ||

## Tools
- Simulator: Icarus Verilog / Vivado
- Synthesis: Yosys
- Target: RV32I base ISA

## Author
Prachi Agrawal | B.Tech 3rd Year | NIT Kurukshetra