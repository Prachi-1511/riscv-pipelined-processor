`timescale 1ns/1ps

module cache_ctrl_tb;

    reg clk, rst_n, cache_hit, req_valid;
    wire stall, fill_trigger;

    integer pass_count = 0;
    integer fail_count = 0;
    integer stall_cycles = 0;

    cache_ctrl #(.miss_penalty(4)) dut (
        .clk(clk), .rst_n(rst_n),
        .cache_hit(cache_hit), .req_valid(req_valid),
        .stall(stall), .fill_trigger(fill_trigger)
    );

    always #5 clk = ~clk;

    task check(input cond, input [8*64:1] name);
        begin
            if (cond) begin
                pass_count = pass_count + 1;
                $display("PASS: %s", name);
            end else begin
                fail_count = fail_count + 1;
                $display("FAIL: %s", name);
            end
        end
    endtask

    initial begin
        $dumpfile("sim/cache_ctrl.vcd");
        $dumpvars(0, cache_ctrl_tb);
        
        clk = 0; rst_n = 0; cache_hit = 0; req_valid = 0;
        #10 rst_n = 1;

        // Hit case -> no stall at all
        @(negedge clk); req_valid = 1; cache_hit = 1;
        @(negedge clk);
        check(stall == 1'b0, "Hit: stall stays low");
        
        req_valid = 0; cache_hit = 0;

        // Miss case -> stall for exactly miss_penalty cycles, then fill_trigger pulses once
        @(negedge clk); req_valid = 1; cache_hit = 0;
        @(negedge clk); req_valid = 0; 

        stall_cycles = 0;
        if (stall) 
            stall_cycles = stall_cycles + 1;

        repeat (5) begin
            @(negedge clk);
            if (stall) 
                stall_cycles = stall_cycles + 1;
            if (fill_trigger) 
                $display("  fill_trigger pulsed at this cycle");
        end
        check(stall_cycles == 4, "Miss: stalled for exactly 4 cycles");

        $display("\n--- RESULTS: %0d PASS / %0d FAIL ---", pass_count, fail_count);
        $finish;
    end

endmodule