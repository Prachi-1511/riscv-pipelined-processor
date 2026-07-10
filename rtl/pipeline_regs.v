`include "rtl/riscv_defs.vh"

//  IF/ID  — captures fetch stage outputs
module ifid_reg (
    input  wire        clk, rst_n,
    input  wire        stall,   // freeze register
    input  wire        flush,   // insert NOP 
    input  wire [31:0] pc_in,
    input  wire [31:0] instr_in,
    output reg  [31:0] pc_out,
    output reg  [31:0] instr_out,
    output reg        valid_out
);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n || flush) begin
            pc_out    <= 32'b0;
            instr_out <= 32'h0000_0013;  // NOP on reset OR bubble on branch flush
            valid_out  <= 1'b0;          // bubble inserted on flush
        end 
        else if (!stall) begin           // only advance if not stalled
            pc_out    <= pc_in;
            instr_out <= instr_in;
            valid_out <= 1'b1;
        end
        // if stall=1 and no flush: register holds its value (implicit)
    end
endmodule


//  ID/EX  — captures decode stage outpput
module idex_reg (
    input  wire        clk, rst_n, flush, stall,
    // Data inputs from ID stage
    input  wire [31:0] pc_in,
    input  wire [31:0] rs1_data_in,
    input  wire [31:0] rs2_data_in,
    input  wire [31:0] imm_in,
    input  wire [4:0]  rs1_addr_in,   // needed by forwarding unit 
    input  wire [4:0]  rs2_addr_in,   // needed by forwarding unit
    input  wire [4:0]  rd_in,
    input wire  [2:0]  func3_in,
    // Control inputs
    input  wire [3:0]  alu_op_in,
    input  wire        alu_src_in,
    input  wire        mem_read_in,
    input  wire        mem_write_in,
    input  wire        mem_to_reg_in,
    input  wire        reg_write_in,
    input  wire        branch_in,
    input  wire        jump_in,
    input wire         valid_in, 
    // Data outputs
    output reg  [31:0] pc_out,
    output reg  [31:0] rs1_data_out,
    output reg  [31:0] rs2_data_out,
    output reg  [31:0] imm_out,
    output reg  [4:0]  rs1_addr_out,
    output reg  [4:0]  rs2_addr_out,
    output reg  [4:0]  rd_out,
    output reg  [2:0]  func3_out,
    // Control outputs
    output reg  [3:0]  alu_op_out,
    output reg         alu_src_out,
    output reg         mem_read_out,
    output reg         mem_write_out,
    output reg         mem_to_reg_out,
    output reg         reg_write_out,
    output reg         branch_out,
    output reg         jump_out,
    output reg         valid_out
);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n || flush) begin
            // Clear all — flush inserts a NOP bubble
            pc_out         <= 32'b0;
            rs1_data_out   <= 32'b0;
            rs2_data_out   <= 32'b0;
            imm_out        <= 32'b0;
            rs1_addr_out   <= 5'b0;
            rs2_addr_out   <= 5'b0;
            rd_out         <= 5'b0;
            alu_op_out     <= `ALU_ADD;
            alu_src_out    <= 1'b0;
            func3_out      <= 3'b0;
            mem_read_out   <= 1'b0;
            mem_write_out  <= 1'b0;
            mem_to_reg_out <= 1'b0;
            reg_write_out  <= 1'b0;
            branch_out     <= 1'b0;
            jump_out       <= 1'b0;
            valid_out      <= 1'b0;
        end 
        else if (!stall) begin
            pc_out         <= pc_in;
            rs1_data_out   <= rs1_data_in;
            rs2_data_out   <= rs2_data_in;
            imm_out        <= imm_in;
            rs1_addr_out   <= rs1_addr_in;
            rs2_addr_out   <= rs2_addr_in;
            rd_out         <= rd_in;
            alu_op_out     <= alu_op_in;
            alu_src_out    <= alu_src_in;
            func3_out      <= func3_in;
            mem_read_out   <= mem_read_in;
            mem_write_out  <= mem_write_in;
            mem_to_reg_out <= mem_to_reg_in;
            reg_write_out  <= reg_write_in;
            branch_out     <= branch_in;
            jump_out       <= jump_in;
            valid_out      <= flush ? 1'b0 : valid_in;  // bubble inserted on flush
        end
    end
endmodule


//  EX/MEM — captures execute stage outputs
module exmem_reg (
    input  wire        clk, rst_n,
    input wire         stall,
    input  wire [31:0] alu_result_in,
    input  wire [31:0] rs2_data_in,  // store data — passes through EX unchanged
    input  wire [4:0]  rd_in,
    input  wire        zero_in,
    input  wire        mem_read_in,
    input  wire        mem_write_in,
    input  wire        mem_to_reg_in,
    input  wire        reg_write_in,
    input  wire        branch_in,
    input  wire        jump_in,
    input wire         valid_in,
    
    output reg  [31:0] alu_result_out,
    output reg  [31:0] rs2_data_out,
    output reg  [4:0]  rd_out,
    output reg         zero_out,
    output reg         mem_read_out,
    output reg         mem_write_out,
    output reg         mem_to_reg_out,
    output reg         reg_write_out,
    output reg         branch_out,
    output reg         jump_out,
    output reg         valid_out
);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            alu_result_out <= 32'b0;
            rs2_data_out   <= 32'b0;
            rd_out         <= 5'b0;
            zero_out       <= 1'b0;
            mem_read_out   <= 1'b0;
            mem_write_out  <= 1'b0;
            mem_to_reg_out <= 1'b0;
            reg_write_out  <= 1'b0;
            branch_out     <= 1'b0;
            jump_out       <= 1'b0;
            valid_out      <= 1'b0;
        end 
        else if (!stall) begin
            alu_result_out <= alu_result_in;
            rs2_data_out   <= rs2_data_in;
            rd_out         <= rd_in;
            zero_out       <= zero_in;
            mem_read_out   <= mem_read_in;
            mem_write_out  <= mem_write_in;
            mem_to_reg_out <= mem_to_reg_in;
            reg_write_out  <= reg_write_in;
            branch_out     <= branch_in;
            jump_out       <= jump_in;
            valid_out      <= valid_in;
        end
    end
endmodule


//  MEM/WB — captures memory stage outputs
module memwb_reg (
    input  wire        clk, rst_n,
    input              stall,
    input  wire [31:0] alu_result_in,
    input  wire [31:0] mem_data_in,
    input  wire [4:0]  rd_in,
    input  wire        mem_to_reg_in,
    input  wire        reg_write_in,
    input wire         valid_in,
    
    output reg  [31:0] alu_result_out,
    output reg  [31:0] mem_data_out,
    output reg  [4:0]  rd_out,
    output reg         mem_to_reg_out,
    output reg         reg_write_out,
    output reg         valid_out
);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            alu_result_out <= 32'b0;
            mem_data_out   <= 32'b0;
            rd_out         <= 5'b0;
            mem_to_reg_out <= 1'b0;
            reg_write_out  <= 1'b0;
            valid_out      <= 1'b0;
        end 
        else if (!stall) begin
            alu_result_out <= alu_result_in;
            mem_data_out   <= mem_data_in;
            rd_out         <= rd_in;
            mem_to_reg_out <= mem_to_reg_in;
            reg_write_out  <= reg_write_in;
            valid_out      <= valid_in;
        end
    end
endmodule