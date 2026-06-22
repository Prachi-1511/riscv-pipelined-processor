module forwarding_unit(
    // What EX currently needs
    input  wire [4:0] idex_rs1,
    input  wire [4:0] idex_rs2,
    // EX/MEM stage — one cycle ahead
    input  wire [4:0] exmem_rd,
    input  wire       exmem_reg_write,
    // MEM/WB stage — two cycles ahead
    input  wire [4:0] memwb_rd,
    input  wire       memwb_reg_write,
    // Outputs to MUXes in ex_stage.v
    output reg [1:0]  forward_a,
    output reg [1:0]  forward_b
);

    always @(*) begin
        // default values
        forward_a = 2'b00;
        forward_b = 2'b00;

        // rs1 forwarding
        if (exmem_reg_write && (exmem_rd != 5'b0) && (exmem_rd == idex_rs1))
            forward_a = 2'b01; // Forward from EX/MEM stage
        else if (memwb_reg_write && (memwb_rd != 5'b0) && (memwb_rd == idex_rs1))
            forward_a = 2'b10; // Forward from MEM/WB stage

        // rs2 forwarding
        if (exmem_reg_write && (exmem_rd != 5'b0) && (exmem_rd == idex_rs2))
            forward_b = 2'b01; // Forward from EX/MEM stage
        else if (memwb_reg_write && (memwb_rd != 5'b0) && (memwb_rd == idex_rs2))
            forward_b = 2'b10; // Forward from MEM/WB stage
    end

endmodule