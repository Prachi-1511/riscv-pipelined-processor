`include "rtl/riscv_defs.vh"

module single_cycle (
    input wire clk,
    input wire rst_n
);

    // internal wires
    wire [31:0] pc_out, pc_plus4, instr;
    wire [31:0] read_data1, read_data2, imm;
    wire [31:0] alu_b_mux, alu_result, mem_read_data, wb_data;

    // control signals
    wire reg_write, mem_write, mem_read, alu_src;
    wire mem_to_reg, branch, jump;
    wire [3:0] alu_op;
    wire zero;

    // Branch/jump target 
    wire [31:0] branch_target;
    wire pc_src;
    wire [2:0]  funct3 = instr[14:12];

    // PC + 4
    assign pc_plus4 = pc_out + 32'd4;
    assign branch_target = pc_out + imm; 
    
    wire branch_cond = (funct3 == `F3_BEQ) ?  zero           // BEQ: taken when equal
                       : (funct3 == `F3_BNE) ? ~zero : 1'b0; // BNE: taken when not equal
    
    assign pc_src = (branch & branch_cond) | jump;

    pc pc0 (.clk(clk), 
            .rst_n(rst_n), 
            .stall(1'b0), 
            .branch_target(pc_src ? branch_target : pc_plus4),
            .branch_taken(pc_src), 
            .pc_out(pc_out) ); 

    imem imem0 (.addr(pc_out), .instr(instr) );

    control ctrl10 (.opcode(instr[6:0]), 
                    .funct3(instr[14:12]), 
                    .funct7(instr[30]),
                    .reg_write(reg_write), 
                    .mem_write(mem_write), 
                    .mem_read(mem_read), 
                    .alu_src(alu_src), 
                    .mem_to_reg(mem_to_reg),
                    .branch(branch), 
                    .jump(jump), 
                    .alu_op(alu_op) );

    imm_gen gen0 ( .instr(instr), .imm_out(imm) );

    regfile rf0 (.clk(clk), 
                .we(reg_write), 
                .write_data(wb_data),
                .rs1(instr[19:15]), 
                .rs2(instr[24:20]), 
                .rd(instr[11:7]), 
                .read_data1(read_data1), 
                .read_data2(read_data2) );

    assign alu_b_mux = alu_src ? imm : read_data2;

    alu alu0 (.a(read_data1), 
            .b(alu_b_mux), 
            .alu_op(alu_op), 
            .result(alu_result), 
            .zero(zero) );

    dmem dmem0 (.clk(clk), 
                .mem_write(mem_write), 
                .mem_read(mem_read), 
                .addr(alu_result), 
                .write_data(read_data2), 
                .read_data(mem_read_data) );

    assign wb_data = jump ? pc_plus4 :
                     mem_to_reg ? mem_read_data : alu_result;

endmodule