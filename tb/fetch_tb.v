`timescale 1ns/1ps

module fetch_tb;

    reg clk = 0, rst_n = 0;
    wire [31:0] pc_out, instr, pc_next;

    pc pc0 ( .clk(clk), .rst_n(rst_n), .stall(1'b0), .branch_taken(1'b0),
               .branch_target(32'b0), .pc_out(pc_out) );
    
    imem im0  ( .addr(pc_out), .instr(instr) );

    always #5 clk = ~clk;

    initial begin
        
        $dumpfile("sim/fetch.vcd");
        $dumpvars(0, fetch_tb);

        clk = 0; rst_n = 0;
        #12 rst_n = 1;

        #1 $display("PC=%0h  instr=%0h", pc_out, instr);

        repeat (7) begin
            @(posedge clk);
            #1 $display("PC=%h  instr=%h", pc_out, instr);
        end
        
        $finish;
    end
endmodule