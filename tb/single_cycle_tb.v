`timescale 1ns/1ps

module single_cycle_tb;
    reg clk, rst_n;

    always #5 clk = ~clk; 
    
    single_cycle dut ( .clk(clk), .rst_n(rst_n) );

    // Valid in simulation only
    wire [31:0] pc   = dut.pc_out;
    wire [31:0] x10  = dut.rf0.regfile[10];
    wire [31:0] x11  = dut.rf0.regfile[11];
    wire [31:0] x12  = dut.rf0.regfile[12];
    wire [31:0] instr = dut.instr;

    initial begin
        
        $dumpfile("sim/single_cycle.vcd");
        $dumpvars(0, single_cycle_tb);
        
        clk = 0; rst_n = 0;

        #12 rst_n = 1;
        repeat (6) begin
            @(posedge clk); #1;
            $display("PC=%h  instr=%h  x10=%0d  x11=%0d  x12=%0d",
                      pc, instr, x10, x11, x12);
        end
        
        if (x10 === 32'd10 && x11 === 32'd11 && x12 === 32'd21)
            $display("PASS: 10 + 11 = 21 computed correctly");
        else
            $display("FAIL: x10=%0d x11=%0d x12=%0d", x10, x11, x12);

        $finish;
    end

endmodule