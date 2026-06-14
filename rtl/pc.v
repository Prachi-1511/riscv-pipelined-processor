module pc (
    input  wire        clk, 
    input  wire        rst_n, 
    input  wire        stall,        // freeze PC 
    input  wire        branch_taken, // override PC
    input  wire [31:0] branch_target,
    output reg  [31:0] pc_out
);
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            pc_out <= 32'h0;
        else if (stall)
            pc_out <= pc_out;         // hold current PC
        else if (branch_taken)
            pc_out <= branch_target;  // jump to target
        else
            pc_out <= pc_out + 32'd4; // default: next instruction
    end

endmodule