`include "rtl/riscv_defs.vh"

module ex_stage (
    // Data inputs from ID/EX register
    input  wire [31:0] rs1_data,
    input  wire [31:0] rs2_data,
    input  wire [31:0] imm,
    input  wire [31:0] pc,
    // Control inputs
    input  wire [3:0]  alu_op,
    input  wire        alu_src,
    // Forwarding inputs 
    input  wire [1:0]  forward_a,
    input  wire [1:0]  forward_b,
    input  wire [31:0] exmem_alu_result,  // EX/MEM forwarding source
    input  wire [31:0] wb_data,           // MEM/WB forwarding source
    // Outputs
    output wire [31:0] alu_result,
    output wire [31:0] rs2_data_out,      // passes through for stores
    output wire        zero,
    output wire [31:0] branch_target
);

    // Forwarding MUX — ALU port A
    reg [31:0] alu_a;
    always @(*) begin
        case (forward_a)
            2'b00: alu_a = rs1_data;          // no forwarding
            2'b01: alu_a = exmem_alu_result;  // forward from EX/MEM
            2'b10: alu_a = wb_data;           // forward from MEM/WB
            default: alu_a = rs1_data;
        endcase
    end
    
    // Forwarding MUX — ALU port B (rs2 path only)
    reg [31:0] forwarded_rs2;
    always @(*) begin
        case (forward_b)
            2'b00: forwarded_rs2 = rs2_data;
            2'b01: forwarded_rs2 = exmem_alu_result;
            2'b10: forwarded_rs2 = wb_data;
            default: forwarded_rs2 = rs2_data;
        endcase
    end

    // ALU Src MUX 
    wire [31:0] alu_b = alu_src ? imm : forwarded_rs2;
   
    alu alu0 (
        .a      (alu_a),
        .b      (alu_b),
        .alu_op (alu_op),
        .result (alu_result),
        .zero   (zero)
    );

    assign branch_target = pc + imm;
    assign rs2_data_out = forwarded_rs2;

endmodule