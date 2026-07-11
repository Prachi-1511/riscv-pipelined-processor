module soc_top ( input  wire clk, rst_n );

    // CPU core — everything built Days 1-25 lives inside this one instance
    wire [31:0] cpu_axi_addr;
    wire        cpu_axi_start_read;
    wire [31:0] cpu_axi_read_data;
    wire        cpu_axi_done;

    top_pipeline u_cpu (.clk(clk), .rst_n(rst_n));

    // Performance counter block, visible at SoC level for external monitoring
    wire [31:0] mcycle, minstret, icache_hits, dcache_hits;
    
    perf_counters u_perf (
        .clk(clk), .rst_n(rst_n),
        .instr_retired(u_cpu.instr_retired),
        .icache_access(u_cpu.imem_req),
        .icache_hit(u_cpu.icache_hit),
        .dcache_access(u_cpu.dmem_req),
        .dcache_hit(u_cpu.dcache_hit),
        .mcycle(mcycle), .minstret(minstret),
        .icache_hits(icache_hits), .dcache_hits(dcache_hits)
    );

    // AXI-Lite peripheral, sitting alongside the CPU at SoC level
    wire ARVALID, ARREADY, RVALID, RREADY;
    wire [31:0] ARADDR, RDATA;

    axi_lite_master u_axi_master (
        .clk(clk), .rst_n(rst_n),
        .start_read(cpu_axi_start_read), .read_addr(cpu_axi_addr),
        .read_data(cpu_axi_read_data), .done(cpu_axi_done),
        .ARVALID(ARVALID), .ARADDR(ARADDR), .ARREADY(ARREADY),
        .RVALID(RVALID), .RDATA(RDATA), .RREADY(RREADY)
    );

    axi_lite_slave u_axi_slave (
        .clk(clk), .rst_n(rst_n),
        .ARVALID(ARVALID), .ARADDR(ARADDR), .ARREADY(ARREADY),
        .RVALID(RVALID), .RDATA(RDATA), .RREADY(RREADY)
    );

endmodule