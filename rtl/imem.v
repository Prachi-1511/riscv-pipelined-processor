module imem (
    input  wire [31:0] addr,
    output wire [31:0] instr
);
    
    reg [31:0] mem [0:63]; 

    initial begin
        $readmemh("sim/program.hex", mem); // Load instructions from hex file
    end

    assign instr = mem[addr[7:2]]; 

endmodule