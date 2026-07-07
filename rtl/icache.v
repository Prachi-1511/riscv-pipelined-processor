module icache (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [31:0] addr,         // PC from fetch stage
    input  wire        mem_read,     // fetch requesting an instruction
    input wire         fill_trigger, // fill cache line on miss
    input wire [31:0]  fill_data,    // data to fill on miss
    output reg  [31:0] instr_out,
    output reg          hit
);

    localparam sets        = 16;
    localparam index_bits  = $clog2(sets);   
    localparam offset_bits = $clog2(index_bits);  
    localparam tag_bits    = 32 - index_bits - offset_bits; 

    reg                  valid     [0:sets-1];
    reg [tag_bits-1:0]   tag_array [0:sets-1];
    reg [31:0]           data_array[0:sets-1];

    wire [index_bits-1:0] index = addr[5:2];
    wire [tag_bits-1:0]   tag   = addr[31:6];

    integer i;
     always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            for (i = 0; i < sets; i = i + 1) begin
                valid[i] <= 1'b0;
            end
        end
        else if (fill_trigger && mem_read) begin
            valid[index]      <= 1'b1;
            tag_array[index]  <= tag;
            data_array[index] <= fill_data;
        end
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