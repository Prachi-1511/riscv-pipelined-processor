module if_stage (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        stall,
    input  wire        branch_taken,
    input  wire [31:0] branch_target,
    output wire [31:0] pc_out,
    output wire [31:0] instr_out,
    output wire [31:0] pc_plus4_out
);
    wire [31:0] next_pc;

    // PC selects between sequential and branch target
    assign next_pc = branch_taken ? branch_target : pc_out + 32'd4;

    pc pc0 (
        .clk          (clk),
        .rst_n        (rst_n),
        .stall        (stall),
        .branch_taken (branch_taken),
        .branch_target(next_pc),
        .pc_out       (pc_out)
    );

    imem imem0 ( .addr (pc_out), .instr(instr_out) );

    assign pc_plus4_out = pc_out + 32'd4;

endmodule