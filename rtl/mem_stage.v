module mem_stage (
    input  wire        clk,
    input  wire [31:0] alu_result,   // memory address
    input  wire [31:0] rs2_data,     // store data
    input  wire        mem_read,
    input  wire        mem_write,
    output wire [31:0] mem_read_data
);
    dmem dmem0 (
        .clk       (clk),
        .mem_write (mem_write),
        .mem_read  (mem_read),
        .addr      (alu_result),
        .write_data(rs2_data),
        .read_data (mem_read_data)
    );
endmodule