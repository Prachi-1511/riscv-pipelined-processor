// Opcodes (bits [6:0])
localparam OP_R_TYPE  = 7'b011_0011; // ADD, SUB, AND, OR, XOR, SLL, SRL, SRA
localparam OP_I_ALU   = 7'b001_0011; // ADDI, ANDI, ORI, XORI, SLTI
localparam OP_I_LOAD  = 7'b000_0011; // LW, LH, LB, LBU, LHU
localparam OP_S_TYPE  = 7'b010_0011; // SW, SH, SB
localparam OP_B_TYPE  = 7'b110_0011; // BEQ, BNE, BLT, BGE, BLTU, BGEU

localparam OP_LUI     = 7'b011_0111; // LUI
localparam OP_AUIPC   = 7'b001_0111; // AUIPC

localparam OP_JAL     = 7'b110_1111; // JAL
localparam OP_JALR    = 7'b110_0111; // JALR


// funct3 for R-type and I-type ALU
localparam F3_ADD_SUB = 3'b000; // ADD/SUB , ADDI
localparam F3_SLL     = 3'b001; // Shift left logical
localparam F3_SLT     = 3'b010; // Set less than (signed)
localparam F3_SLTU    = 3'b011; // Set less than (unsigned)
localparam F3_XOR     = 3'b100; // XOR
localparam F3_SR      = 3'b101; // SRL or SRA 
localparam F3_OR      = 3'b110; // OR
localparam F3_AND     = 3'b111; // AND

// funct3 for B-Type (branches & loads)
localparam F3_BEQ     = 3'b000;
localparam F3_BNE     = 3'b001;
localparam F3_BLT     = 3'b100;
localparam F3_BGE     = 3'b101;
localparam F3_BLTU    = 3'b110;
localparam F3_BGEU    = 3'b111;

localparam F3_LB      = 3'b000;
localparam F3_LH      = 3'b001;
localparam F3_LW      = 3'b010;
localparam F3_LBU     = 3'b100;
localparam F3_LHU     = 3'b101;


// funct3 for S-type (stores)
localparam F3_SB      = 3'b000;
localparam F3_SH      = 3'b001;
localparam F3_SW      = 3'b010;


// funct7 key bit
localparam F7_NORMAL  = 1'b0; // ADD, SRL
localparam F7_ALT     = 1'b1; // SUB, SRA