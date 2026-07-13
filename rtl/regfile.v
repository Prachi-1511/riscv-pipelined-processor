`include "riscv_defs.vh"

module regfile (
    input  wire        clk,
    input  wire        we,          // write enable
    input  wire [4:0]  rs1,         
    input  wire [4:0]  rs2,         
    input  wire [4:0]  rd,          
    input  wire [31:0] write_data,  // write data
    output wire [31:0] read_data1,  
    output wire [31:0] read_data2 );
    
    reg [31:0] regfile [0:31];  
    
    integer i;
    initial begin
        for (i = 0; i < 32; i = i + 1)
            regfile[i] = 32'b0;
    end
    
    always @(posedge clk) begin
        if (we && (rd != 5'b00000))
            regfile[rd] <= write_data;
    end

    assign read_data1 = (rs1 == 5'b00000) ? 32'b0 : 
                        ( (we && (rd == rs1) && (rd != 5'b0)) ? write_data : regfile[rs1] );
    assign read_data2 = (rs2 == 5'b00000) ? 32'b0 : 
                        ( (we && (rd == rs2) && (rd != 5'b0)) ? write_data : regfile[rs2] );

endmodule