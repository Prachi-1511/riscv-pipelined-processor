`include "rtl/riscv_defs.vh"

module top_pipeline (input wire clk, rst_n);
    // IF outputs
    wire [31:0] if_pc, if_instr, if_pc_plus4;

    // IF/ID register outputs
    wire [31:0] ifid_pc, ifid_instr;

    // ID outputs
    wire [31:0] id_rs1_data, id_rs2_data, id_imm;
    wire [4:0]  id_rs1_addr, id_rs2_addr, id_rd;
    wire [3:0]  id_alu_op;
    wire [2:0]  id_func3;
    wire        id_alu_src, id_mem_read, id_mem_write;
    wire        id_mem_to_reg, id_reg_write, id_branch, id_jump;

    // ID/EX register outputs 
    wire [31:0] idex_pc, idex_rs1_data, idex_rs2_data, idex_imm;
    wire [4:0]  idex_rs1_addr, idex_rs2_addr, idex_rd;
    wire [3:0]  idex_alu_op;
    wire [2:0]  idex_func3;
    wire        idex_alu_src, idex_mem_read, idex_mem_write;
    wire        idex_mem_to_reg, idex_reg_write, idex_branch, idex_jump;

    // EX stage wires
    wire [31:0] ex_alu_result, ex_rs2_data, ex_branch_target;
    wire        ex_zero;

    // EX/MEM Register
    wire [31:0] exmem_alu_result, exmem_rs2_data;
    wire [4:0]  exmem_rd;
    wire        exmem_zero, exmem_mem_read, exmem_mem_write;
    wire        exmem_mem_to_reg, exmem_reg_write, exmem_branch, exmem_jump;

    // MEM Stage 
    wire [31:0] mem_read_data;

    // MEM/WB Register
    wire [31:0] memwb_alu_result, memwb_mem_data;
    wire [4:0]  memwb_rd;
    wire        memwb_mem_to_reg, memwb_reg_write;

    // WB Stage
    wire [31:0] final_wb_data;

    // Hazard / control
    wire        stall       = hzd_stall;
    wire        id_flush    = hzd_stall || branch_taken; // flush IF/ID when stalling
    wire        if_flush    = branch_taken;

    // WB feedback into ID 
    wire        wb_reg_write = memwb_reg_write;
    wire [4:0]  wb_rd        = memwb_rd;
    wire [31:0] wb_data      = final_wb_data;

    // Branch condition
    wire branch_cond = (idex_func3 == `F3_BEQ) ? ex_zero : (idex_func3 == `F3_BNE) ? ~ex_zero : 1'b0;
    wire branch_taken = (idex_branch && branch_cond) || idex_jump;

    // IF Stage 
    if_stage if0 (
        .clk          (clk),
        .rst_n        (rst_n),
        .stall        (stall),
        .branch_taken (branch_taken),     
        .branch_target(ex_branch_target),   
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
        .func3       (id_func3),
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
        .func3_in      (id_func3),     
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
        .func3_out     (idex_func3),  
        .alu_src_out   (idex_alu_src),
        .mem_read_out  (idex_mem_read), 
        .mem_write_out (idex_mem_write),
        .mem_to_reg_out(idex_mem_to_reg), 
        .reg_write_out (idex_reg_write),
        .branch_out    (idex_branch),   
        .jump_out      (idex_jump)
    );

    ex_stage ex0 (
        .rs1_data        (idex_rs1_data),
        .rs2_data        (idex_rs2_data),
        .imm             (idex_imm),
        .pc              (idex_pc),
        .alu_op          (idex_alu_op),
        .alu_src         (idex_alu_src),
        .forward_a       (fwd_a),          
        .forward_b       (fwd_b),          
        .exmem_alu_result(exmem_alu_result),         
        .wb_data         (final_wb_data),          
        .alu_result      (ex_alu_result),
        .rs2_data_out    (ex_rs2_data),
        .zero            (ex_zero),
        .branch_target   (ex_branch_target)
    );

    exmem_reg exmem0 (
        .clk           (clk), 
        .rst_n         (rst_n),
        .alu_result_in (ex_alu_result),
        .rs2_data_in   (ex_rs2_data),
        .rd_in         (idex_rd),
        .zero_in       (ex_zero),
        .mem_read_in   (idex_mem_read),
        .mem_write_in  (idex_mem_write),
        .mem_to_reg_in (idex_mem_to_reg),
        .reg_write_in  (idex_reg_write),
        .branch_in     (idex_branch),
        .jump_in       (idex_jump),
        .alu_result_out(exmem_alu_result),
        .rs2_data_out  (exmem_rs2_data),
        .rd_out        (exmem_rd),
        .zero_out      (exmem_zero),
        .mem_read_out  (exmem_mem_read),
        .mem_write_out (exmem_mem_write),
        .mem_to_reg_out(exmem_mem_to_reg),
        .reg_write_out (exmem_reg_write),
        .branch_out    (exmem_branch),
        .jump_out      (exmem_jump)
    );

    mem_stage mem0 (
        .clk          (clk),
        .alu_result   (exmem_alu_result),
        .rs2_data     (exmem_rs2_data),
        .mem_read     (exmem_mem_read),
        .mem_write    (exmem_mem_write),
        .mem_read_data(mem_read_data)
    );

    memwb_reg memwb0 (
        .clk           (clk), 
        .rst_n         (rst_n),
        .alu_result_in (exmem_alu_result),
        .mem_data_in   (mem_read_data),
        .rd_in         (exmem_rd),
        .mem_to_reg_in (exmem_mem_to_reg),
        .reg_write_in  (exmem_reg_write),
        .alu_result_out(memwb_alu_result),
        .mem_data_out  (memwb_mem_data),
        .rd_out        (memwb_rd),
        .mem_to_reg_out(memwb_mem_to_reg),
        .reg_write_out (memwb_reg_write)
    );

    wb_stage wb0 (
        .alu_result(memwb_alu_result),
        .mem_data  (memwb_mem_data),
        .mem_to_reg(memwb_mem_to_reg),
        .wb_data   (final_wb_data)
    );

    // Hazard unit
    wire hzd_stall;
    hazard_unit hzd0 (
        .idex_mem_read(idex_mem_read),
        .idex_rd      (idex_rd),
        .ifid_rs1     (ifid_instr[19:15]), // rs1
        .ifid_rs2     (ifid_instr[24:20]), // rs2
        .stall        (hzd_stall),
        .pc_write_disable(),
        .ifid_write_disable()
    );

    // Forwarding unit
    wire [1:0] fwd_a, fwd_b;
    forwarding_unit fwd0 (
        .idex_rs1       (idex_rs1_addr),
        .idex_rs2       (idex_rs2_addr),
        .exmem_rd       (exmem_rd),
        .exmem_reg_write(exmem_reg_write),
        .memwb_rd       (memwb_rd),
        .memwb_reg_write(memwb_reg_write),
        .forward_a      (fwd_a),
        .forward_b      (fwd_b)
    );

     // Branch predictor outputs
    wire [31:0] bp_total, bp_taken, bp_mispred, bp_penalty; 
    branch_predictor bp0 (
        .clk             (clk),
        .rst_n           (rst_n),
        .branch_in_ex    (idex_branch),
        .branch_taken    (branch_taken),
        .pc_in_ex        (idex_pc),
        .predict_taken   (),
        .total_branches  (bp_total),
        .taken_branches  (bp_taken),
        .mispredictions  (bp_mispred),
        .penalty_cycles  (bp_penalty)
    );

endmodule