`timescale 1ns/1ps

module top_pipeline_cache_tb;

    reg clk, rst_n;
    integer pass_count = 0, fail_count = 0;

    top_pipeline dut (.clk(clk), .rst_n(rst_n));

    always #5 clk = ~clk;

    task check(input cond, input [8*64:1] msg);
        begin
            if (cond) begin
                pass_count = pass_count+1; 
                $display("PASS: %s", msg);
            end
            else begin
                fail_count = fail_count+1; 
                $display("FAIL: %s", msg);
            end 
        end
    endtask

    initial begin
        $dumpfile("sim/top_cache.vcd");
        $dumpvars(0, top_pipeline_cache_tb);
        
        clk = 0; rst_n = 0;
        #12 rst_n = 1;

        // Cold-start: first fetch guaranteed
        repeat (3) @(posedge clk);
        #1 check(dut.stall == 1'b1, "Cold I-cache miss stalls pipeline");

        // After MISS_PENALTY cycles, stall should clear and fetch proceeds
        repeat (3) @(posedge clk);
        #1 check(dut.stall == 1'b0, "Stall clears after fill_trigger, fetch resumes");

        $display("\n--- RESULTS: %0d PASS / %0d FAIL ---", pass_count, fail_count);
        $finish;
    end

endmodule