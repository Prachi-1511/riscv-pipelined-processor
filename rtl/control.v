`include "rtl/riscv_defS.vh"

module control (
    input  wire [6:0] opcode,
    input  wire [2:0] funct3,
    input  wire       funct7,
    output reg        branch,
    output reg        mem_read,
    output reg        mem_to_reg,
    output reg        mem_write,
    output reg        alu_src,
    output reg        reg_write,
    output reg        jump,
    output reg [3:0]  alu_op
);

    always @(*) begin
        // Default values
        branch      = 1'b0;
        mem_read    = 1'b0;
        mem_to_reg  = 1'b0;
        mem_write   = 1'b0;
        alu_src     = 1'b0;
        reg_write   = 1'b0;
        jump        = 1'b0;
        alu_op      = `ALU_ADD;

        case (opcode)
            
            `OP_R_TYPE: begin
                reg_write   = 1'b1;
                alu_src     = 1'b0; 
                case (funct3)
                    `F3_ADD_SUB: alu_op = funct7 ? `ALU_SUB : `ALU_ADD;
                    `F3_AND:     alu_op = `ALU_AND;
                    `F3_OR:      alu_op = `ALU_OR;
                    `F3_XOR:     alu_op = `ALU_XOR;
                    `F3_SLL:     alu_op = `ALU_SLL;
                    `F3_SLT:     alu_op = `ALU_SLT;
                    `F3_SLTU:    alu_op = `ALU_SLTU;
                    `F3_SR:      alu_op = funct7 ? `ALU_SRA : `ALU_SRL;
                    default:     alu_op = `ALU_ADD; 
                endcase
            end
            
            `OP_I_ALU: begin
                reg_write   = 1'b1;
                alu_src     = 1'b1; 
                case (funct3)
                    `F3_ADD_SUB: alu_op = `ALU_ADD;
                    `F3_AND:     alu_op = `ALU_AND;
                    `F3_OR:      alu_op = `ALU_OR;
                    `F3_XOR:     alu_op = `ALU_XOR;
                    `F3_SLL:     alu_op = `ALU_SLL;
                    `F3_SLT:     alu_op = `ALU_SLT;
                    `F3_SLTU:    alu_op = `ALU_SLTU;
                    `F3_SR:      alu_op = funct7 ? `ALU_SRA : `ALU_SRL;
                    default:     alu_op = `ALU_ADD; 
                endcase
            end
            
            `OP_I_LOAD: begin
                mem_read    = 1'b1;
                mem_to_reg  = 1'b1;
                reg_write   = 1'b1;
                alu_src     = 1'b1; 
                alu_op      = `ALU_ADD; 
            end
            
            `OP_S_TYPE: begin
                mem_write   = 1'b1;
                alu_src     = 1'b1; 
                alu_op      = `ALU_ADD; 
            end
            
            `OP_B_TYPE: begin
                branch      = 1'b1;
                alu_SRC     = 1'b0;
                alu_op      = `ALU_SUB;
            end

            `OP_LUI: begin
                reg_write   = 1'b1;
                alu_src     = 1'b1; 
                alu_op      = `ALU_ADD; 
            end
            
            `OP_JAL: begin
                jump        = 1'b1;
                reg_write   = 1'b1; 
            end
            
            `OP_JALR: begin
                jump        = 1'b1;
                reg_write   = 1'b1; 
                alu_src     = 1'b1; 
                alu_op      = `ALU_ADD;
            end
            
            default: begin
                // For unsupported opcodes, keep all control signals at their default values
            end
        endcase
    end

endmodule