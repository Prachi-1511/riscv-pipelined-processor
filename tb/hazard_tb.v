`timescale 1ns/1ps

module hazard_tb;
    reg clk, rst_n;
    
    always #5 clk = ~clk; // 100MHz clock

    top_pipeline dut ( .clk(clk), .rst_n(rst_n) );

    initial begin
        $dumpfile("sim/hazard.vcd");
        $dumpvars(0, hazard_tb);

        clk = 0; rst_n = 0;
        #1 $display("PC=%h stall=%b idex_mem_read=%b idex_rd=%0d ifid_rs1=%0d ifid_rs2=%0d",
                dut.if_pc, dut.hzd_stall, dut.idex_mem_read,
                dut.idex_rd, dut.ifid_instr[19:15], dut.ifid_instr[24:20]);
        
        #12 rst_n = 1;

        repeat(10) begin
            @(posedge clk);
            #1 $display("PC=%h stall=%b idex_mem_read=%b idex_rd=%0d ifid_rs1=%0d ifid_rs2=%0d",
                dut.if_pc, dut.hzd_stall, dut.idex_mem_read,
                dut.idex_rd, dut.ifid_instr[19:15], dut.ifid_instr[24:20]);
        end
        $finish;
    end

endmodule