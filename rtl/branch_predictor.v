`include "riscv_defs.vh"

module branch_predictor (
    input wire clk, rst_n,
    
    input wire        branch_in_ex,     // is branch executing in ex stage?
    input wire        branch_taken,     // was branch taken?

    input wire [31:0] pc_in_ex,

    output wire       predict_taken,    //  default: not taken  
    
    output reg [31:0] total_branches,
    output reg [31:0] taken_branches,
    output reg [31:0] mispredictions,
    output reg [31:0] penalty_cycles
);
    reg [1:0] bht [0:63];                  // 64-entry Branch History Table
    wire [5:0] bht_index = pc_in_ex[7:2];  // Bits [7:2] of PC as BHT index
    
    assign predict_taken = bht[bht_index][1]; 

    integer i;
    initial begin
        for (i = 0; i < 64; i = i + 1)
            bht[i] = 2'b01; // Initialize all entries to 'weakly not taken'
    end
    
    integer j;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (j = 0; j < 64; j = j + 1)
                bht[j]    <= 2'b01; 
           total_branches <= 32'b0;
           taken_branches <= 32'b0;
           mispredictions <= 32'b0;
           penalty_cycles <= 32'b0; 
        end
        else begin
            if (branch_in_ex) begin
                total_branches <= total_branches + 32'd1;
                
                if(branch_taken) begin
                    taken_branches <= taken_branches + 32'd1;
                    bht[bht_index] <= (bht[bht_index] == 2'b11) ? 2'b11 : bht[bht_index] + 2'b01;
                end
                else
                    bht[bht_index] <= (bht[bht_index] == 2'b00) ? 2'b00 : bht[bht_index] - 2'b01;
                
                if (predict_taken != branch_taken) begin
                    mispredictions <= mispredictions + 32'd1;
                    penalty_cycles <= penalty_cycles + 32'd2;
                end
            end
        end
    end

endmodule