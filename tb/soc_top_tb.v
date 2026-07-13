`timescale 1ns/1ps
module soc_top_tb;

    reg clk, rst_n;
    reg [31:0] mcycle_before;
    
    always #5 clk = ~clk;
    
    soc_top dut (.clk(clk), .rst_n(rst_n));
    
    pipeline_assertions u_assert (
        .clk(clk), .rst_n(rst_n),
        .hzd_stall(dut.u_cpu.hzd_stall),
        .if_flush(dut.u_cpu.if_flush),
        .id_flush(dut.u_cpu.id_flush),
        .cache_stall(dut.u_cpu.cache_stall),
        .branch_taken(dut.u_cpu.branch_taken)
    );

    coverage_model u_cov (
        .clk(clk), .rst_n(rst_n),
        .hzd_stall(dut.u_cpu.hzd_stall),
        .branch_taken(dut.u_cpu.branch_taken),
        .cache_stall(dut.u_cpu.cache_stall),
        .icache_hit(dut.u_cpu.icache_hit),
        .dcache_hit(dut.u_cpu.dcache_hit),
        .fwd_a(dut.u_cpu.fwd_a),
        .fwd_b(dut.u_cpu.fwd_b)
    );
    
    integer pass_count = 0, fail_count = 0;
    task check(input cond, input [8*64:1] msg);
        begin
            if (cond) begin pass_count=pass_count+1; $display("PASS: %s", msg); end
            else begin fail_count=fail_count+1; $display("FAIL: %s", msg); end
        end
    endtask

    initial begin
        $dumpfile("sim/soc_top.vcd");
        $dumpvars(0, soc_top_tb);
        
        clk=0; rst_n=0;
        #12 rst_n = 1;

        repeat (50) @(posedge clk);

        check(!$isunknown(dut.mcycle), "mcycle counter is defined (no X) after 50 cycles");

        mcycle_before = dut.mcycle;
        repeat (20) @(posedge clk);
        check(dut.mcycle == mcycle_before + 20, "mcycle advances by exactly 20 over 20 clean cycles");
        
        check(!$isunknown(dut.u_axi_master.state), "AXI master FSM state is defined, no X propagation");

        $display("\n--- RESULTS: %0d PASS / %0d FAIL ---", pass_count, fail_count);

        u_cov.report_coverage();
        $finish;
    end

endmodule