`timescale 1ns/1ps
`include "rtl/riscv_defs.vh"
module alu_tb;
    reg [31:0] a, b;
    reg [3:0] alu_op;
    wire [31:0] result;
    wire zero;

    alu dut ( .a(a), .b(b), .alu_op(alu_op), .result(result), .zero(zero) );

    integer pass_count = 0, fail_count = 0;
    
    task check_result;
        input [31:0] expected;
        input [63:0] test_name;   
        begin
            if (result === expected) begin
                $display("PASS | %s | got %0h", test_name, result);
                        pass_count = pass_count + 1;
            end 
            else begin
                $display("FAIL | %s | expected %0h got %0h",
                        test_name, expected, result);
                fail_count = fail_count + 1;
            end
        end
    endtask

    initial begin
        
        a = 32'd15;  b = 32'd10;  alu_op = `ALU_ADD;
        #10; check_result(32'd25, "ADD");

        a = 32'hFFFFFFFF; b = 32'd1; alu_op = `ALU_ADD; 
        #10; check_result(32'h0, "ADD ovf");

        a = 32'd5; b = 32'd5; alu_op = `ALU_SUB; 
        #10; check_result(32'd0, "SUB zero");
        
        a = 32'hFFFFFFFF; b = 32'd1;
        
        alu_op = `ALU_SLT;  
        #10; check_result(32'd1, "SLT sgn");
        alu_op = `ALU_SLTU; 
        #10; check_result(32'd0, "SLTU uns");

        a = 32'hFFFFFFFF; b = 32'd1; alu_op = `ALU_SRA; 
        #10; check_result(32'hFFFFFFFF, "SRA neg");

        a = 32'h7FFFFFFF; b = 32'd1; 
        
        alu_op = `ALU_SRL; 
        #10; check_result(32'h3FFFFFFF, "SRL pos");
        alu_op = `ALU_SRA; 
        #10; check_result(32'h3FFFFFFF, "SRA pos");
        
        $display("---");
        $display("Total: %0d PASS  %0d FAIL", pass_count, fail_count);
        $finish;
    end

endmodule    