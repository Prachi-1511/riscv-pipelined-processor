`timescale 1ns/1ps

module ifid_tb;
    reg clk , rst_n;
    always #5 clk = ~clk;

    top_pipeline dut (.clk(clk), .rst_n(rst_n));

    // Probe internal signals
    wire [31:0] pc     = dut.if_pc;
    wire [31:0] instr  = dut.if_instr;
    wire [31:0] ifid_i = dut.ifid_instr;
    wire [3:0]  alu_op = dut.id_alu_op;
    wire        rw     = dut.id_reg_write;

    initial begin
        $dumpfile("sim/ifid.vcd");
        $dumpvars(0, ifid_tb);

        clk = 0; rst_n = 0;
        #1 $display("PC=%h | IF_instr=%h | ID_instr=%h | alu_op=%b | reg_write=%b",
                    pc, instr, ifid_i, alu_op, rw);

        #12 rst_n = 1;

        // Watch 6 cycles — instruction fetched in cycle N
        // appears in ID in cycle N+1 (one cycle pipeline lag)
        repeat (6) begin
            @(posedge clk);
            #1 $display("PC=%h | IF_instr=%h | ID_instr=%h | alu_op=%b | reg_write=%b",
                    pc, instr, ifid_i, alu_op, rw);
        end

        $finish;
    end
endmodule