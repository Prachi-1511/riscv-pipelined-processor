// Opcodes (bits [6:0])
`define OP_R_TYPE  7'b011_0011 // ADD, SUB, AND, OR, XOR, SLL, SRL, SRA
`define OP_I_ALU   7'b001_0011 // ADDI, ANDI, ORI, XORI, SLTI
`define OP_I_LOAD  7'b000_0011 // LW, LH, LB, LBU, LHU
`define OP_S_TYPE  7'b010_0011 // SW, SH, SB
`define OP_B_TYPE  7'b110_0011 // BEQ, BNE, BLT, BGE, BLTU, BGEU

`define OP_LUI     7'b011_0111 // LUI
`define OP_AUIPC   7'b001_0111 // AUIPC

`define OP_JAL     7'b110_1111 // JAL
`define OP_JALR    7'b110_0111 // JALR


// funct3 for R-type and I-type ALU
`define F3_ADD_SUB 3'b000 // ADD/SUB , ADDI
`define F3_SLL     3'b001 // Shift left logical
`define F3_SLT     3'b010 // Set less than (signed)
`define F3_SLTU    3'b011 // Set less than (unsigned)
`define F3_XOR     3'b100 // XOR
`define F3_SR      3'b101 // SRL or SRA 
`define F3_OR      3'b110 // OR
`define F3_AND     3'b111 // AND


// funct3 for B-Type (branches & loads)
`define F3_BEQ     3'b000
`define F3_BNE     3'b001
`define F3_BLT     3'b100
`define F3_BGE     3'b101
`define F3_BLTU    3'b110
`define F3_BGEU    3'b111

`define F3_LB      3'b000
`define F3_LH      3'b001
`define F3_LW      3'b010
`define F3_LBU     3'b100
`define F3_LHU     3'b101


// funct3 for S-type (stores)
`define F3_SB      3'b000
`define F3_SH      3'b001
`define F3_SW      3'b010


// funct7 key bit
`define F7_NORMAL  1'b0 // ADD, SRL
`define F7_ALT     1'b1 // SUB, SRA


// ALU operation codes — driven by control unit
`define ALU_ADD  4'b0000
`define ALU_SUB  4'b0001
`define ALU_AND  4'b0010
`define ALU_OR   4'b0011
`define ALU_XOR  4'b0100
`define ALU_SLT  4'b0101  // signed less-than
`define ALU_SLTU 4'b0110  // unsigned less-than
`define ALU_SLL  4'b0111  // shift left logical
`define ALU_SRL  4'b1000  // shift right logical
`define ALU_SRA  4'b1001  // shift right arithmetic