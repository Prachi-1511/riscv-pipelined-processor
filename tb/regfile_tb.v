`timescale 1ns/1ps

module regfile_tb;
    reg        clk, we;
    reg  [4:0] rs1, rs2, rd;
    reg  [31:0] write_data;
    wire [31:0] read_data1, read_data2;

    regfile dut (
        .clk(clk), .we(we),
        .rs1(rs1), .rs2(rs2), .rd(rd),
        .write_data(write_data),
        .read_data1(read_data1),
        .read_data2(read_data2)
    );

    always #5 clk = ~clk;

    integer pass_count = 0, fail_count = 0;
    task check;
        input [31:0] actual, expected;
        input [127:0] name;
        begin
            if (actual === expected) begin
                $display("PASS | %s", name); pass_count++;
            end
            else begin
                $display("FAIL | %s | exp=%h got=%h", name, expected, actual);
                fail_count++;
            end
        end
    endtask

    initial begin

        $dumpfile("sim/regfile.vcd");
        $dumpvars(0, regfile_tb);
        
        we = 0; rs1 = 0; rs2 = 0; rd = 0; write_data = 0; clk = 0;

        // Test 1: Write to x5 and read back
        @(posedge clk);
        #1 we = 1; rd = 5'd5; write_data = 32'hDEADBEEF;
        @(posedge clk);
        #1 we = 0; rs1 = 5'd5;
        #1 check(read_data1, 32'hDEADBEEF, "Read x5 after write");

        // Test 2: Write to x0 and read back
        @(posedge clk);
        #1 we = 1; rd = 5'd0; write_data = 32'hFFFFFFFF;
        @(posedge clk);
        #1 we = 0; rs1 = 5'd0;
        #1 check(read_data2, 32'h0, "x0 hardwired wire");

        // Test 3: Simultaneous read from diff. reg.
        @(posedge clk);
        #1 we = 1; rd = 5'd10; write_data = 32'hAAAAAAAA;
        @(posedge clk);
        #1 we = 1; rd = 5'd11; write_data = 32'h55555555;
        @(posedge clk);
        #1 we = 0; rs1 = 5'd10; rs2 = 5'd11; 
        #1 check(read_data1, 32'hAAAAAAAA, "dual read port 1");
           check(read_data2, 32'h55555555, "dual read port 2");

        // Test 4: Write enable low
        @(posedge clk);
        #1 rs1 = 5'd5;
        @(posedge clk);
        #1 we = 0; rd = 5'd5; write_data = 32'h00000000;
        #1 check(read_data1, 32'hDEADBEEF, "WE=0 no write");

        // Test 5: write-before-read bypass
        @(posedge clk);
        #1 we = 1; rd = 5'd7; write_data = 32'hCAFEBABE;
           rs1 = 5'd7;      // same address — bypass should activate
        #1 check(read_data1, 32'hCAFEBABE, "write-before-read bypass");
        @(posedge clk); 
        #1 we = 0;

        // Test complete
        $display("Total: %0d PASS  %0d FAIL", pass_count, fail_count);
        $finish;
    
    end
endmodule