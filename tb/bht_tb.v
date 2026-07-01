`timescale 1ns/1ps
module bht_tb;
    reg clk, rst_n;
    always #5 clk = ~clk;

    top_pipeline dut (.clk(clk), .rst_n(rst_n));

    wire [31:0] rf [0:31];
    genvar gi;
    generate
        for (gi = 0; gi < 32; gi = gi + 1) begin : probe
            assign rf[gi] = dut.id0.rf0.regfile[gi];
        end
    endgenerate

    // BHT state probe — watch counter for the loop's branch PC
    // BNE in loop is at address 0x14 → bht_index = 0x14[7:2] = 5
    wire [1:0] loop_counter = dut.bp0.bht[5];
    wire [31:0] total   = dut.bp0.total_branches;
    wire [31:0] mispred = dut.bp0.mispredictions;
    wire [31:0] penalty = dut.bp0.penalty_cycles;

    integer pass_count = 0, fail_count = 0;
    task check32;
        input [31:0] actual, expected; input [255:0] name;
        begin
            if (actual===expected) begin
                $display("  PASS | %-35s | got %0d", name, actual);
                pass_count = pass_count+1;
            end 
            else begin
                $display("  FAIL | %-35s | exp %0d got %0d", name, expected, actual);
                fail_count = fail_count+1;
            end
        end
    endtask

    initial begin
        $dumpfile("sim/bht.vcd");
        $dumpvars(0, bht_tb);
        
        clk <= 0; rst_n <= 0;
        #12 rst_n = 1;

        repeat (70) @(posedge clk);
        #1 $display("");
        $display("==========================================");
        $display("  Day 17 — 2-bit BHT Verification        ");
        $display("==========================================");

        $display("--- Functional ---");
        check32(rf[1], 32'd8,  "x1 loop counter");
        check32(rf[3], 32'd28, "x3 accumulator (sum 0..7)");

        $display("--- Prediction Quality ---");
        check32(total, 32'd8, "total branches (8 BNE executions)");

        check32(mispred, 32'd2, "mispredictions (down from 7 in Day 16)");
        check32(penalty, 32'd4, "penalty cycles (down from 14 in Day 16)");

        // BHT counter state after loop: should be 10 (weakly taken, exited once)
        if (loop_counter === 2'b10)
            $display("  PASS | BHT counter at 10 (weakly taken after exit)");
        else
            $display("  FAIL | BHT counter = %b (expected 10)", loop_counter);

        $display("--- Improvement vs Day 16 ---");
        $display("  Day 16 penalty cycles : 14 (predict-not-taken, 7 misses)");
        $display("  Day 17 penalty cycles : %0d (2-bit BHT, 2 misses)", penalty);
        $display("  Reduction             : %0d%%", (14-penalty)*100/14);

        $display("==========================================");
        $display("  %0d PASS  %0d FAIL", pass_count, fail_count);
        $display("==========================================");
        $finish;
    end
endmodule