module icache (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [31:0] addr,       // PC from fetch stage
    input  wire        mem_read,   // fetch requesting an instruction
    output reg  [31:0] instr_out,
    output reg          hit
);

    localparam SETS        = 16;
    localparam INDEX_BITS  = 4;   // log2(16)
    localparam OFFSET_BITS = 2;  // word-aligned, carries no info
    localparam TAG_BITS    = 32 - INDEX_BITS - OFFSET_BITS; // 26

    reg                  valid     [0:SETS-1];
    reg [TAG_BITS-1:0]   tag_array [0:SETS-1];
    reg [31:0]           data_array[0:SETS-1];

    wire [INDEX_BITS-1:0] index = addr[5:2];
    wire [TAG_BITS-1:0]   tag   = addr[31:6];

    integer i;
    initial begin
        for (i = 0; i < SETS; i = i + 1)
            valid[i] = 1'b0;
    end

    // Combinational hit/miss check
    always @(*) begin
        if (mem_read && valid[index] && (tag_array[index] == tag)) begin
            hit       = 1'b1;
            instr_out = data_array[index];
        end else begin
            hit       = 1'b0;
            instr_out = 32'b0;
        end
    end

    // Fill a line on miss 
    task automatic fill_line(input [31:0] fill_addr, input [31:0] fill_data);
        begin
            valid[fill_addr[5:2]]      = 1'b1;
            tag_array[fill_addr[5:2]]  = fill_addr[31:6];
            data_array[fill_addr[5:2]] = fill_data;
        end
    endtask

endmodule