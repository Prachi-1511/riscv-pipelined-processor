`timescale 1ns/1ps

module icache_tb;

    reg         clk, rst_n, mem_read;
    reg  [31:0] addr;
    wire [31:0] instr_out;
    wire        hit;

    integer pass_count = 0;
    integer fail_count = 0;

    icache dut (
        .clk(clk), .rst_n(rst_n), .addr(addr),
        .mem_read(mem_read),
        .instr_out(instr_out), .hit(hit)
    );

    always #5 clk = ~clk;

    task check_hit(input [31:0] a, input exp_hit, input [31:0] exp_data);
        begin
            addr = a; mem_read = 1;
            #1;
            if (hit === exp_hit && (!exp_hit || instr_out === exp_data)) begin
                pass_count = pass_count + 1;
                $display("PASS: addr=%h hit=%b data=%h", a, hit, instr_out);
            end else begin
                fail_count = fail_count + 1;
                $display("FAIL: addr=%h expected hit=%b got hit=%b data=%h",
                          a, exp_hit, hit, instr_out);
            end
        end
    endtask

    initial begin
        $dumpfile("sim/icache.vcd");
        $dumpvars(0, icache_tb);
        
        clk = 0; rst_n = 0; mem_read = 0; addr = 0;
        #10 rst_n = 1;

        // Cold miss — nothing loaded yet
        check_hit(32'h00000050, 1'b0, 32'h0);

        // Fill set then hit
        dut.fill_line(32'h00000050, 32'hDEAD0050);
        check_hit(32'h00000050, 1'b1, 32'hDEAD0050);

        // Same index, different tag -> must MISS (conflict)
        check_hit(32'h00000150, 1'b0, 32'h0);

        // Fill set with new data
        dut.fill_line(32'h00000150, 32'hBEEF0150);
        check_hit(32'h00000150, 1'b1, 32'hBEEF0150);
        check_hit(32'h00000050, 1'b0, 32'h0); // A evicted, confirms conflict

        // Non-conflicting address, different set
        dut.fill_line(32'h00000090, 32'hCAFE0090); // index = 6
        check_hit(32'h00000090, 1'b1, 32'hCAFE0090);
        check_hit(32'h00000150, 1'b1, 32'hBEEF0150); // set 4 still intact

        $display("\n--- RESULTS: %0d PASS / %0d FAIL ---", pass_count, fail_count);
        $finish;
    end

endmodule