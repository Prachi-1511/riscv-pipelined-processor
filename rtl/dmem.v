module dmem (
    input wire clk,
    input wire mem_write,
    input wire mem_read,
    input wire [31:0] addr,
    input wire [31:0] write_data,
    output reg [31:0] read_data
);
    reg [31:0] mem [0:255]; 

    integer i;
    initial begin
        for (i = 0; i < 256; i = i + 1)
            mem[i] = 32'b0; 
    end

    // Synchronous write — data written on clock edge
    always @(posedge clk) begin
        if (mem_write) 
            mem[addr[31:2]] <= write_data; 
    end
    // Asynchronous read — same reasoning as register file
    always @(*) begin
        if (mem_read) 
            read_data = mem[addr[31:2]]; 
        else
            read_data = 32'b0; 
    end
endmodule