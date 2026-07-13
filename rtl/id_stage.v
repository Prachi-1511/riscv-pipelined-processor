`include "riscv_defs.vh"

module id_stage (
    input  wire        clk,
    input  wire        rst_n,
    // From IF/ID register
    input  wire [31:0] instr,
    input  wire [31:0] pc,
    // Write-back inputs (from WB stage — same cycle)
    input  wire        wb_reg_write,
    input  wire [4:0]  wb_rd,
    input  wire [31:0] wb_data,
    // Decoded outputs — go into ID/EX register
    output wire [2:0]  func3,
    output wire [31:0] rs1_data,
    output wire [31:0] rs2_data,
    output wire [31:0] imm,
    output wire [4:0]  rs1_addr,
    output wire [4:0]  rs2_addr,
    output wire [4:0]  rd,
    // Control outputs
    output wire [3:0]  alu_op,
    output wire        alu_src,
    output wire        mem_read,
    output wire        mem_write,
    output wire        mem_to_reg,
    output wire        reg_write,
    output wire        branch,
    output wire        jump
);
    // Extract register addresses directly from fixed bit positions
    assign rs1_addr = instr[19:15];
    assign rs2_addr = instr[24:20];
    assign rd       = instr[11:7];
    assign func3    = instr[14:12];
    
    // Register file — write-back feeds back into the same cycle
    regfile rf0 (
        .clk       (clk),
        .we        (wb_reg_write),
        .rs1       (rs1_addr),
        .rs2       (rs2_addr),
        .rd        (wb_rd),
        .write_data(wb_data),
        .read_data1(rs1_data),
        .read_data2(rs2_data)
    );
    
    // Immediate generator
    imm_gen immgen0 ( .instr  (instr), .imm_out(imm) );

    // Control unit
    control ctrl0 (
        .opcode    (instr[6:0]),
        .funct3    (instr[14:12]),
        .funct7    (instr[30]),
        .reg_write (reg_write),
        .alu_src   (alu_src),
        .mem_read  (mem_read),
        .mem_write (mem_write),
        .mem_to_reg(mem_to_reg),
        .branch    (branch),
        .jump      (jump),
        .alu_op    (alu_op)
    );

endmodule