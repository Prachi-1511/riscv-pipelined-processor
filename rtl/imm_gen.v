`include "rtl/riscv_defS.vh"

module imm_gen (
    input  wire [31:0] instr,
    output reg  [31:0] imm_out
);

    always @(*) begin
        
        case (instr[6:0])
            `OP_I_ALU, `OP_I_LOAD, `OP_JALR:
                 // I-type: bits [31:20], sign-extended
                imm_out = {{20{instr[31]}}, instr[31:20]}; 

            `OP_S_TYPE:
                // S-type: bits [31:25] and [11:7], sign-extended
                imm_out = {{20{instr[31]}}, instr[31:25], instr[11:7]};

            `OP_B_TYPE:
                // B-type: {imm[12],imm[11],imm[10:5],imm[4:1],1'b0}
                imm_out = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};

            `OP_LUI, `OP_AUIPC:
                // U-type: upper 20 bits, lower 20 zeroed
                imm_out = {instr[31:12], 12'b0};

            `OP_JAL:
                // J-type: {imm[20],imm[10:1],imm[11],imm[19:12],1'b0}
                imm_out = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};

            default:
                imm_out = 32'b0;
        endcase
    end

endmodule