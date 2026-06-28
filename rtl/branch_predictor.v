`include "rtl/riscv_defs.vh"

module branch_predictor (
    input wire clk, rstn,
    
    input wire        branch_in_ex,     // is branch executing in ex stage?
    input wire        branch_taken,     // was branch taken?

    output wire       predict_taken,    //  default: not taken  
    
    output reg [31:0] total_branches,
    output reg [31:0] taken_branches,
    output reg [31:0] mispredictions,
    output reg [31:0] penalty_cycles
);
    
    assign predict_taken = 1'b0;
    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin
           total_branches <= 0;
           taken_branches <= 0;
           mispredictions <= 0;
           penalty_cycles <= 0; 
        end
        else begin
            if(branch_in_ex) begin
                total_branches <= total_branches + 32'd1;
                
                if(branch_taken) begin
                    taken_branches <= taken_branches + 32'd1;
                    mispredictions <= mispredictions + 32'd1;
                    penalty_cycles <= penalty_cycles + 32'd2;
                end
            end
        end
    end

endmodule