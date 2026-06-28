`timescale 1ns/1ps

module branch_perf_tb;
    reg clk, rst_n;
    always #5 clk = ~clk;

    top_pipeline dut ( .clk(clk), .rst_n(rst_n) );

    // Register probes
    wire [31:0] rf [0:31];
    genvar gi;
    generate
        for (gi = 0; gi < 32; gi = gi + 1) begin : probe
            assign rf[gi] = dut.id0.rf0.regfile[gi];
        end
    endgenerate

    // Branch performance counter probes
    wire [31:0] total   = dut.bp0.total_branches;
    wire [31:0] taken   = dut.bp0.taken_branches;
    wire [31:0] mispred = dut.bp0.mispredictions;
    wire [31:0] penalty = dut.bp0.penalty_cycles;

    integer pass_count = 0, fail_count = 0;

    task check32;
        input [31:0] actual, expected; input [255:0] name;
    begin
        if (actual === expected) begin
            $display("  PASS | %-35s | got %0d", name, actual);
            pass_count = pass_count + 1;
        end else begin
            $display("  FAIL | %-35s | expected %0d got %0d", name, expected, actual);
            fail_count = fail_count + 1;
        end
    end
    endtask

    initial begin
        $dumpfile("sim/branch_predict.vcd");
        $dumpvars(0, branch_perf_tb);

        clk <= 0; rst_n <= 0;
        
        #12 rst_n = 1;
        repeat (70) @(posedge clk);
        
        #1 $display("");
        $display("=========================================");
        $display("  Branch Performance — Day 16            ");
        $display("=========================================");

        // Functional correctness
        $display("--- Functional Verification ---");
        check32(rf[1], 32'd8,  "x1 loop counter (final value)");
        check32(rf[2], 32'd8,  "x2 loop limit");
        check32(rf[3], 32'd28, "x3 accumulator (0+1+...+7)");
        check32(rf[4], 32'd28, "x4 expected result");

        // Branch performance counters
        $display("--- Branch Performance Counters ---");
        check32(total,   32'd8, "total branches (BNE executed 8 times)");
        check32(taken,   32'd7, "taken branches (7 loop iterations)");
        check32(mispred, 32'd7, "mispredictions (predict-not-taken, wrong 7x)");
        check32(penalty, 32'd14,"penalty cycles (7 × 2 cycles each)");

        // CPI calculation
        $display("--- CPI Analysis ---");
        $display("  Instructions in loop body : 3 (ADD, ADDI, BNE)");
        $display("  Loop iterations           : 8");
        $display("  Useful instruction cycles : %0d", 3*8 + 3);
        
        // 3 setup instrs (ADDI×3) + 8×3 loop body + 1 post-loop ADDI
        $display("  Penalty cycles            : %0d", penalty);
        $display("  Total measured cycles     : ~%0d", 3 + 3*8 + 1 + penalty);
        $display("  CPI (with branch penalty) : ~%0d.%02d",
                 (3 + 24 + 1 + penalty) / (3 + 24 + 1),
                 ((3 + 24 + 1 + penalty) * 100 / (3 + 24 + 1)) % 100);
        $display("");
        $display("  Predict-not-taken misprediction rate: %0d%%",
                 mispred * 100 / (total > 0 ? total : 1));
        $display("  Expected after Day 17 (2-bit BHT)  : ~3%% misprediction");

        $display("=========================================");
        $display("  %0d PASS  %0d FAIL", pass_count, fail_count);
        if (fail_count == 0)
            $display("  ALL PASS — branch prediction baseline established");
        $display("=========================================");

        $finish;
    end
endmodule