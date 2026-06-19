`include "rtl/riscv_defs.vh"

module top_pipeline (input wire clk, rst_n);
    // Stage wires 
    
    // IF outputs
    wire [31:0] if_pc, if_instr, if_pc_plus4;

    // IF/ID register outputs
    wire [31:0] ifid_pc, ifid_instr;

    // ID outputs
    wire [31:0] id_rs1_data, id_rs2_data, id_imm;
    wire [4:0]  id_rs1_addr, id_rs2_addr, id_rd;
    wire [3:0]  id_alu_op;
    wire        id_alu_src, id_mem_read, id_mem_write;
    wire        id_mem_to_reg, id_reg_write, id_branch, id_jump;

    // ID/EX register outputs 
    wire [31:0] idex_pc, idex_rs1_data, idex_rs2_data, idex_imm;
    wire [4:0]  idex_rs1_addr, idex_rs2_addr, idex_rd;
    wire [3:0]  idex_alu_op;
    wire        idex_alu_src, idex_mem_read, idex_mem_write;
    wire        idex_mem_to_reg, idex_reg_write, idex_branch, idex_jump;

    // Hazard / control
    wire        stall       = 1'b0;
    wire        if_flush    = 1'b0;
    wire        id_flush    = 1'b0;

    // WB feedback into ID 
    wire        wb_reg_write = 1'b0;
    wire [4:0]  wb_rd        = 5'b0;
    wire [31:0] wb_data      = 32'b0;

    // IF Stage 
    if_stage if0 (
        .clk          (clk),
        .rst_n        (rst_n),
        .stall        (stall),
        .branch_taken (1'b0),     
        .branch_target(32'b0),   
        .pc_out       (if_pc),
        .instr_out    (if_instr),
        .pc_plus4_out (if_pc_plus4)
    );

    // IF/ID Pipeline Register 
    ifid_reg ifid0 (
        .clk      (clk),   
        .rst_n    (rst_n),
        .stall    (stall),  
        .flush    (if_flush),
        .pc_in    (if_pc),  
        .instr_in (if_instr),
        .pc_out   (ifid_pc), 
        .instr_out(ifid_instr)
    );

    // ID Stage
    id_stage id0 (
        .clk         (clk),     
        .rst_n       (rst_n),
        .instr       (ifid_instr),
        .pc          (ifid_pc),
        .wb_reg_write(wb_reg_write),
        .wb_rd       (wb_rd),   
        .wb_data     (wb_data),
        .rs1_data    (id_rs1_data),
        .rs2_data    (id_rs2_data),
        .imm         (id_imm),
        .rs1_addr    (id_rs1_addr),
        .rs2_addr    (id_rs2_addr),
        .rd          (id_rd),
        .alu_op      (id_alu_op),
        .alu_src     (id_alu_src),
        .mem_read    (id_mem_read),
        .mem_write   (id_mem_write),
        .mem_to_reg  (id_mem_to_reg),
        .reg_write   (id_reg_write),
        .branch      (id_branch),
        .jump        (id_jump)
    );

    idex_reg idex0 (
        .clk           (clk), 
        .rst_n         (rst_n), 
        .flush         (id_flush),
        .pc_in         (ifid_pc),
        .rs1_data_in   (id_rs1_data),   
        .rs2_data_in   (id_rs2_data),
        .imm_in        (id_imm),
        .rs1_addr_in   (id_rs1_addr),   
        .rs2_addr_in   (id_rs2_addr),
        .rd_in         (id_rd),
        .alu_op_in     (id_alu_op),     
        .alu_src_in    (id_alu_src),
        .mem_read_in   (id_mem_read),   
        .mem_write_in  (id_mem_write),
        .mem_to_reg_in (id_mem_to_reg), 
        .reg_write_in  (id_reg_write),
        .branch_in     (id_branch),     
        .jump_in       (id_jump),
        .pc_out        (idex_pc),
        .rs1_data_out  (idex_rs1_data), 
        .rs2_data_out  (idex_rs2_data),
        .imm_out       (idex_imm),
        .rs1_addr_out  (idex_rs1_addr), 
        .rs2_addr_out  (idex_rs2_addr),
        .rd_out        (idex_rd),
        .alu_op_out    (idex_alu_op),   
        .alu_src_out   (idex_alu_src),
        .mem_read_out  (idex_mem_read), 
        .mem_write_out (idex_mem_write),
        .mem_to_reg_out(idex_mem_to_reg), 
        .reg_write_out (idex_reg_write),
        .branch_out    (idex_branch),   
        .jump_out      (idex_jump)
    );

    // EX stage wires
    wire [31:0] ex_alu_result, ex_rs2_data, ex_branch_target;
    wire        ex_zero;

    ex_stage ex0 (
        .rs1_data       (idex_rs1_data),
        .rs2_data       (idex_rs2_data),
        .imm            (idex_imm),
        .pc             (idex_pc),
        .alu_op         (idex_alu_op),
        .alu_src        (idex_alu_src),
        .forward_a      (2'b00),          
        .forward_b      (2'b00),          
        .exmem_alu_result(32'b0),         
        .wb_data        (32'b0),          
        .alu_result     (ex_alu_result),
        .rs2_data_out   (ex_rs2_data),
        .zero           (ex_zero),
        .branch_target  (ex_branch_target)
    );
endmodule