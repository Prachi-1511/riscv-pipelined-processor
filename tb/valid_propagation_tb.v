`timescale 1ns/1ps

module valid_propagation_tb;

    reg clk, rst_n;
    
    always #5 clk = ~clk;

    top_pipeline dut (.clk(clk), .rst_n(rst_n));
    
    integer pass_count = 0, fail_count = 0;
    task check(input cond, input [8*64:1] msg);
        begin
            if (cond) begin 
                pass_count=pass_count+1; 
                $display("PASS: %s", msg); 
            end
            else begin 
                fail_count=fail_count+1; 
                $display("FAIL: %s", msg); 
            end
        end
    endtask

    initial begin
        clk=0; rst_n=0;
        #12 rst_n = 1;

        repeat (20) @(posedge clk);

        if (dut.cache_stall) 
            check(dut.idex_valid !== 1'bx, "ID/EX valid bit holds defined state during cache_stall (not force-cleared)");

        repeat (10) @(posedge clk); #1;
        check(!(dut.cache_stall && dut.instr_retired), "instr_retired never asserts during an active cache_stall");

        $display("\n--- RESULTS: %0d PASS / %0d FAIL ---", pass_count, fail_count);
        $finish;
    end

endmodule