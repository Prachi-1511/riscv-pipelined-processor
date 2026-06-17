# Single-Cycle Processor Test Plan

## Coverage goals
Every RV32I instruction type must be exercised at least once.
Every control signal must be asserted and verified.
The branch path must be tested for both taken and not-taken cases.

## Test cases

| ID | Instruction | Input state | Expected output | Signal verified |
|----|------------|-------------|-----------------|-----------------|
| T01 | ADDI | x0=0, imm=5 | x1=5 | reg_write, alu_src, alu_op=ADD |
| T02 | ADD  | x1=5, x2=3 | x3=8 | reg_write, alu_src=0 |
| T03 | SUB  | x1=5, x2=3 | x4=2 | funct7[30]=1 path |
| T04 | AND  | x1=5, x2=3 | x5=1 | alu_op=AND |
| T05 | OR   | x1=5, x2=3 | x6=7 | alu_op=OR |
| T06 | SLT  | x2=3, x1=5 | x7=1 | signed compare path |
| T07 | SW   | x3=8, addr=0 | mem[0]=8 | mem_write, alu_src |
| T08 | LW   | addr=0 | x8=8 | mem_read, mem_to_reg |
| T09 | BEQ taken | x3=x8=8 | PC+8 | branch, zero flag |
| T10 | BEQ not-taken | verify x9=0 | ADDI skipped | branch path bypassed |

## Known gaps (to be addressed in pipeline phase)
- BNE, BLT, BGE not yet tested
- JAL/JALR not yet tested  
- Negative immediate arithmetic not yet tested