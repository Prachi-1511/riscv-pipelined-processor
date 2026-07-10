module perf_counters (
    input  wire clk,
    input  wire rst_n,

    input  wire instr_retired,   // when instruction reaches WB
    input  wire icache_access,   
    input  wire icache_hit,      // when icache_access high
    input  wire dcache_access,   
    input  wire dcache_hit,      // when dcache_access high

    output reg [31:0] mcycle,
    output reg [31:0] minstret,
    output reg [31:0] icache_hits,
    output reg [31:0] dcache_hits
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mcycle      <= 32'b0;
            minstret    <= 32'b0;
            icache_hits <= 32'b0;
            dcache_hits <= 32'b0;
        end 
        else begin
            mcycle <= mcycle + 1;   // increments every single cycle, unconditionally

            if (instr_retired)
                minstret <= minstret + 1;

            if (icache_access && icache_hit)
                icache_hits <= icache_hits + 1;

            if (dcache_access && dcache_hit)
                dcache_hits <= dcache_hits + 1;
        end
    end

endmodule