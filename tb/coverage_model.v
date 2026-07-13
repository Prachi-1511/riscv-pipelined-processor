module coverage_model (
    input wire clk,
    input wire rst_n,
    input wire hzd_stall,
    input wire branch_taken,
    input wire cache_stall,
    input wire icache_hit,
    input wire dcache_hit,
    input wire [1:0] fwd_a,
    input wire [1:0] fwd_b
);

    // Coverage bins - each one a scenario we explicitly care about seeing
    integer cov_loaduse_stall     = 0;
    integer cov_branch_taken      = 0;
    integer cov_icache_hit        = 0;
    integer cov_icache_miss       = 0;
    integer cov_dcache_hit        = 0;
    integer cov_dcache_miss       = 0;
    integer cov_fwd_exmem_a       = 0;  // forward_a == 2'b01
    integer cov_fwd_memwb_a       = 0;  // forward_a == 2'b10
    integer cov_fwd_exmem_b       = 0;
    integer cov_fwd_memwb_b       = 0;
    integer cov_cache_stall_hit   = 0;  // cache_stall AND a hit at same cycle

    always @(posedge clk) begin
        if (rst_n) begin
            if (hzd_stall)              cov_loaduse_stall = cov_loaduse_stall + 1;
            if (branch_taken)           cov_branch_taken  = cov_branch_taken + 1;
            if (icache_hit)             cov_icache_hit    = cov_icache_hit + 1;
            if (!icache_hit)            cov_icache_miss   = cov_icache_miss + 1;
            if (dcache_hit)             cov_dcache_hit    = cov_dcache_hit + 1;
            if (!dcache_hit)            cov_dcache_miss   = cov_dcache_miss + 1;
            if (fwd_a == 2'b01)         cov_fwd_exmem_a   = cov_fwd_exmem_a + 1;
            if (fwd_a == 2'b10)         cov_fwd_memwb_a   = cov_fwd_memwb_a + 1;
            if (fwd_b == 2'b01)         cov_fwd_exmem_b   = cov_fwd_exmem_b + 1;
            if (fwd_b == 2'b10)         cov_fwd_memwb_b   = cov_fwd_memwb_b + 1;
        end
    end

    // Report at end of simulation
    task report_coverage;
        integer hit_bins, total_bins;
        begin
            total_bins = 10; hit_bins = 0;
            
            $display("\n===== FUNCTIONAL COVERAGE REPORT =====");
            hit_bins = hit_bins + (cov_loaduse_stall   > 0);
            hit_bins = hit_bins + (cov_branch_taken    > 0);
            hit_bins = hit_bins + (cov_icache_hit      > 0);
            hit_bins = hit_bins + (cov_icache_miss     > 0);
            hit_bins = hit_bins + (cov_dcache_hit      > 0);
            hit_bins = hit_bins + (cov_dcache_miss     > 0);
            hit_bins = hit_bins + (cov_fwd_exmem_a     > 0);
            hit_bins = hit_bins + (cov_fwd_memwb_a     > 0);
            hit_bins = hit_bins + (cov_fwd_exmem_b     > 0);
            hit_bins = hit_bins + (cov_fwd_memwb_b     > 0);

            $display("load-use stall     : %0d hits", cov_loaduse_stall);
            $display("branch taken       : %0d hits", cov_branch_taken);
            $display("icache hit / miss  : %0d / %0d", cov_icache_hit, cov_icache_miss);
            $display("dcache hit / miss  : %0d / %0d", cov_dcache_hit, cov_dcache_miss);
            $display("forward_a EX/MEM   : %0d hits", cov_fwd_exmem_a);
            $display("forward_a MEM/WB   : %0d hits", cov_fwd_memwb_a);
            $display("forward_b EX/MEM   : %0d hits", cov_fwd_exmem_b);
            $display("forward_b MEM/WB   : %0d hits", cov_fwd_memwb_b);
            $display("----------------------------------------");
            $display("COVERAGE: %0d / %0d bins hit = %0d%%", hit_bins, total_bins, (hit_bins*100)/total_bins);
        end
    endtask

endmodule