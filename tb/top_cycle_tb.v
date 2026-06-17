`timescale 1ns/1ps

module top_cycle_tb;
    reg clk , rst_n;
    always #5 clk = ~clk;

    single_cycle dut (.clk(clk), .rst_n(rst_n));

    // Hierarchical probes into register file and data memory
    wire [31:0] rf [0:31];
    genvar gi;
    generate
        for (gi = 0; gi < 32; gi = gi + 1) begin : reg_probe
            assign rf[gi] = dut.rf0.regfile[gi];
        end
    endgenerate

    wire [31:0] dmem0 = dut.dmem0.mem[0];  

    integer pass_count = 0, fail_count = 0;

    task check32;
        input [31:0] actual, expected;
        input [127:0] name;
    begin
        if (actual === expected) begin
            $display("  PASS | %s = %0d", name, actual);
            pass_count = pass_count + 1;
        end else begin
            $display("  FAIL | %s: expected %0d got %0d", name, expected, actual);
            fail_count = fail_count + 1;
        end
    end
    endtask

    initial begin
        $dumpfile("top_cycle.vcd");
        $dumpvars(0, top_cycle_tb);
        
        clk = 0; rst_n = 0;
        
        #12 rst_n = 1;
        // Run enough cycles for all instructions + NOPs
        repeat (16) @(posedge clk);

        #1 $display("=== Single-cycle processor verification ===");

        // Arithmetic
        check32(rf[1],  32'd5,  "x1  ADDI  5");
        check32(rf[2],  32'd3,  "x2  ADDI  3");
        check32(rf[3],  32'd8,  "x3  ADD   5+3");
        check32(rf[4],  32'd2,  "x4  SUB   5-3");
        check32(rf[5],  32'd1,  "x5  AND   5&3");
        check32(rf[6],  32'd7,  "x6  OR    5|3");
        check32(rf[7],  32'd1,  "x7  SLT   3<5");

        // Memory
        check32(dmem0,  32'd8,  "mem[0] SW x3");
        check32(rf[8],  32'd8,  "x8  LW from mem[0]");

        // Branch (BEQ taken — x9 must stay 0, x10 must be 42)
        check32(rf[9],  32'd0,  "x9  not written (branch skipped ADDI 99)");
        check32(rf[10], 32'd42, "x10 ADDI 42 (post-branch)");

        $display("---");
        $display("Total: %0d PASS  %0d FAIL", pass_count, fail_count);
        if (fail_count == 0)
            $display("ALL PASS — single-cycle processor verified");

        $finish;
    end
endmodule