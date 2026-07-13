`timescale 1ns/1ps
module scan_ff_tb;

    reg clk, rst_n, scan_enable, scan_in, d;
    wire q, scan_out;
    integer pass_count = 0, fail_count = 0;

    scan_ff dut (.clk(clk), .rst_n(rst_n), .scan_enable(scan_enable),
                 .scan_in(scan_in), .d(d), .q(q), .scan_out(scan_out));

    always #5 clk = ~clk;

    task check(input cond, input [8*64:1] msg);
        begin
            if (cond) begin 
                pass_count=pass_count+1; 
                $display("PASS: %s", msg); 
            end
            else begin 
                fail_count=fail_count+1; 
                $display("FAIL: %s", msg); 
            end
        end
    endtask

    initial begin
        $dumpfile("sim/scan_ff.vcd");
        $dumpvars(0, scan_ff_tb);
        
        clk=0; rst_n=0; scan_enable=0; scan_in=0; d=0;
        #12 rst_n=1;

        
        @(negedge clk); d=1; scan_in=0;
        @(negedge clk);
        check(q == 1'b1, "Functional mode: q follows d");

        @(negedge clk); scan_enable=1; scan_in=1; d=0;
        @(negedge clk);
        check(q == 1'b1, "Scan mode: q follows scan_in, not d");

        scan_in=0; d=1;
        @(negedge clk);
        check(q == 1'b0, "Scan mode: q still follows scan_in even though d changed");

        $display("\n--- RESULTS: %0d PASS / %0d FAIL ---", pass_count, fail_count);
        $finish;
    end

endmodule