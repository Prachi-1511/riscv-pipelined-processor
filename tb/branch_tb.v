`timescale 1ns/1ps

module branch_tb;
    reg clk, rst_n;

    always #5 clk = ~clk; 
    
    top_pipeline dut ( .clk(clk), .rst_n(rst_n) );

    wire [31:0] rf[0:31];
    genvar gi;
    generate
        for (gi = 0; gi < 32; gi = gi + 1) begin : probe
            assign rf[gi] = dut.id0.rf0.regfile[gi];
        end
    endgenerate

    // Branch signals
    wire bt         = dut.branch_taken;
    wire [31:0] btg = dut.ex_branch_target;
    wire if_fl      = dut.if_flush;
    wire id_fl      = dut.id_flush;

    integer pass_count=0, fail_count=0;
    task check32;
        input [31:0] expected, actual;
        input [127:0] name;
        begin
            if (expected === actual) begin
                $display("  PASS | %s | got %0d",name,actual); 
                pass_count=pass_count+1; 
            end
            else begin 
                $display("  FAIL | %s | exp %0d got %0d",name, expected, actual); 
                fail_count=fail_count+1; 
            end
        end
    endtask

    initial begin
        $dumpfile("sim/branch.vcd");
        $dumpvars(0, branch_tb);
        
        clk = 0; rst_n = 0; 
        
        #12 rst_n = 1;

        repeat(20) begin
            @(posedge clk);
            #1 $display("PC=%h | branch_taken=%b | if_flush=%b | id_flush=%b | target=%h",
                        dut.if_pc, bt, if_fl, id_fl, btg);
        end
        
        $display("=== Branch Verification ===");

        // Taken branch
        check32(rf[1], 32'd5,  "x1 ADDI 5");
        check32(rf[2], 32'd5,  "x2 ADDI 5");
        check32(rf[3], 32'd0,  "x3 NOT written (branch skipped ADDI 99)");
        check32(rf[4], 32'd0,  "x4 NOT written (branch skipped ADDI 42)");
        check32(rf[5], 32'd43, "x5 ADDI 43 (post-branch target)");

        // Not-taken branch
        check32(rf[6], 32'd11, "x6 ADDI 11");
        check32(rf[7], 32'd12, "x7 ADDI 12");
        check32(rf[8], 32'd55, "x8 ADDI 55 (branch not taken, executes)");
        check32(rf[9], 32'd33, "x9 ADDI 33 (executes)");

        $display("--- %0d PASS  %0d FAIL ---", pass_count, fail_count);
        $finish;
    end

endmodule