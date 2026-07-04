module dcache (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [31:0] addr,
    input  wire [31:0] wdata,
    input  wire        mem_read,
    input  wire        mem_write,
    output reg  [31:0] rdata,
    output reg         hit,
    output reg         dirty_out   // observability only (write-through)
);

    localparam sets        = 16;
    localparam index_bits  = $clog2(sets);
    localparam tag_bits    = 26;

    reg                  valid     [0:sets-1];
    reg                  dirty     [0:sets-1];
    reg [tag_bits-1:0]   tag_array [0:sets-1];
    reg [31:0]           data_array[0:sets-1];

    wire [index_bits-1:0] index = addr[5:2];
    wire [tag_bits-1:0]   tag   = addr[31:6];

    integer i;
    initial begin
        for (i = 0; i < sets; i = i + 1) begin
            valid[i] = 1'b0;
            dirty[i] = 1'b0;
        end
    end

    // Read path — combinational
    always @(*) begin
        if (mem_read && valid[index] && (tag_array[index] == tag)) begin
            hit   = 1'b1;
            rdata = data_array[index];
        end else begin
            hit   = 1'b0;
            rdata = 32'b0;
        end
        dirty_out = dirty[index];
    end

    // Write path — sequential, write-through
    always @(posedge clk) begin
        if (mem_write) begin
            data_array[index] <= wdata;
            tag_array[index]  <= tag;
            valid[index]      <= 1'b1;
            dirty[index]      <= 1'b1;   
        end
    end

endmodule