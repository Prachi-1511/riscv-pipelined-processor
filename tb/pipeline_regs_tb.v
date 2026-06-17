`timescale 1ns/1ps

module pipeline_regs_tb;
    reg clk , rst_n;
    
    always #5 clk = ~clk;

    // IF/ID test
    reg  [31:0] pc_in = 0, instr_in = 0;
    reg  stall = 0, flush = 0;
    wire [31:0] pc_out, instr_out;

    ifid_reg ifid0 (
        .clk(clk), .rst_n(rst_n), .stall(stall), .flush(flush),
        .pc_in(pc_in), .instr_in(instr_in),
        .pc_out(pc_out), .instr_out(instr_out)
    );

    integer pass_count = 0, fail_count = 0;
    
    task check32;
        input [31:0] a, e; input [127:0] n;
        begin
            if (a===e) begin
                $display("PASS %s",n); 
                pass_count++;
            end
            else begin
                $display("FAIL %s exp=%h got=%h",n,e,a); 
                fail_count++;
            end
        end
    endtask

    initial begin
        $dumpfile("sim/pipe_reg.vcd");
        $dumpvars(0, pipeline_regs_tb);
        
        clk = 0; rst_n = 0; stall = 0; flush = 0;
        
        #12 rst_n = 1;

        // Normal advance
        pc_in = 32'h4; instr_in = 32'hDEADBEEF;
        @(posedge clk);
        #1 check32(pc_out, 32'h4, "IFID normal pc");
        check32(instr_out, 32'hDEADBEEF, "IFID normal instr");

        // Stall — register must hold previous value
        pc_in = 32'h8; instr_in = 32'hCAFEBABE;
        stall = 1;
        @(posedge clk);
        #1 check32(pc_out, 32'h4, "IFID stall holds pc");
        check32(instr_out, 32'hDEADBEEF, "IFID stall holds instr");

        // Flush — register must become NOP
        stall = 0; flush = 1;
        @(posedge clk); #1;
        check32(instr_out, 32'h0000_0013, "IFID flush inserts NOP");

        flush = 0;
        $display("--- %0d PASS  %0d FAIL", pass_count, fail_count);
        $finish;
    end
endmodule