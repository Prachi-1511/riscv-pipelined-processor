`timescale 1ns/1ps

module pipeline_final_tb;
    reg clk, rst_n;
    always #5 clk = ~clk; //100MHz clock

    top_pipeline dut ( .clk(clk), .rst_n(rst_n) );

    // ── Hierarchical probes — all 32 registers ────────────────────
    wire [31:0] rf [0:31];
    genvar gi;
    generate
        for (gi = 0; gi < 32; gi = gi + 1) begin : reg_probe
            assign rf[gi] = dut.id0.rf0.regfile[gi];
        end
    endgenerate

    // Data memory for SW/LW test
    wire [31:0] dmem0 = dut.mem0.dmem0.mem[0];

    // pipeline control for CPI measurement
    wire        pipe_stall   = dut.hzd_stall;
    wire [1:0]  pipe_fwd_a   = dut.fwd_a;
    wire [1:0]  pipe_fwd_b   = dut.fwd_b;

    // Counters for CPI calculation
    integer cycle_count  = 0;
    integer stall_count  = 0;
    integer fwd_a_count  = 0;
    integer fwd_b_count  = 0;

    always @(posedge clk) begin
        if (rst_n) begin
            cycle_count <= cycle_count + 1;
            if (pipe_stall)  
                stall_count <= stall_count + 1;
            if (pipe_fwd_a != 2'b00) 
                fwd_a_count <= fwd_a_count + 1;
            if (pipe_fwd_b != 2'b00)
                fwd_b_count <= fwd_b_count + 1;
        end
    end

    integer pass_count=0, fail_count=0;
    task check32;
        input [31:0] actual, expected;
        input [127:0] name;
    begin
        if (actual === expected) begin
            $display("  PASS | %-30s | got %0d", name, actual);
            pass_count = pass_count + 1;
        end 
        else begin
            $display("  FAIL | %-30s | expected %0d got %0d",
                     name, expected, actual);
            fail_count = fail_count + 1;
        end
    end
    endtask

    initial begin
        $dumpfile("sim/pipeline_final.vcd");
        $dumpvars(0, pipeline_final_tb);

        clk = 0; rst_n = 0;
        #12 rst_n = 1;

        repeat(35) @(posedge clk);
        #1;
        $display("");
        $display("========================================");
        $display("  Full Pipeline Verification — Day 14   ");
        $display("========================================");

        $display("--- ADDI ---");
        check32(rf[1],  32'd5,  "x1  ADDI x0,5");
        check32(rf[2],  32'd3,  "x2  ADDI x0,3");
        check32(rf[10], 32'd10, "x10 ADDI x0,10");
        check32(rf[11], 32'd7,  "x11 ADDI x0,7");

        $display("--- R-type + EX/MEM forwarding ---");
        check32(rf[3],  32'd8,  "x3  ADD  x1+x2");
        check32(rf[4],  32'd2,  "x4  SUB  x1-x2");
        check32(rf[5],  32'd1,  "x5  AND  x1&x2");
        check32(rf[6],  32'd7,  "x6  OR   x1|x2");
        check32(rf[7],  32'd6,  "x7  XOR  x1^x2");

        $display("--- MEM/WB forwarding ---");
        check32(rf[8],  32'd8,  "x8  ADD  x0+x3 (MEM/WB fwd)");
        check32(rf[9],  32'd2,  "x9  ADD  x0+x4 (MEM/WB fwd)");

        $display("--- SW/LW + load-use stall ---");
        check32(dmem0,  32'd8,  "mem[0] SW x3");
        check32(rf[12], 32'd8,  "x12 LW  from mem[0]");
        check32(rf[13], 32'd13, "x13 ADD  x12+x1 (load-use resolved)");

        $display("--- SLT ---");
        check32(rf[14], 32'd1,  "x14 SLT  3<5 = 1");
        check32(rf[15], 32'd0,  "x15 SLT  5<3 = 0");

        // CPI Analysis
        $display("--- Performance Analysis ---");
        $display("  Total cycles          : %0d", cycle_count);
        $display("  Instructions          : 20");
        $display("  Stall cycles (load-use): %0d", stall_count);
        $display("  Forward A events      : %0d", fwd_a_count);
        $display("  Forward B events      : %0d", fwd_b_count);
        $display("  CPI                   : %0d.%02d",
                 cycle_count/20, (cycle_count*100/20)%100);

        // Final summary
        $display("========================================");
        $display("  %0d PASS  %0d FAIL", pass_count, fail_count);
        if (fail_count == 0)
            $display("  ALL PASS — pipeline verified");
        else
            $display("  FAILURES DETECTED — open sim/pipeline_full.vcd");
        $display("========================================");

        $finish;
    end
endmodule