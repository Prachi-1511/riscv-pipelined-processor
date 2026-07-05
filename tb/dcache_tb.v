`timescale 1ns/1ps

module dcache_tb;

    reg         clk, rst_n;
    reg         mem_read, mem_write;
    reg  [31:0] addr, wdata;
    wire [31:0] rdata;
    wire        hit, dirty_out;

    integer pass_count = 0;
    integer fail_count = 0;

    dcache dut (
        .clk(clk), .rst_n(rst_n), .addr(addr), .wdata(wdata),
        .mem_read(mem_read), .mem_write(mem_write),
        .rdata(rdata), .hit(hit), .dirty_out(dirty_out)
    );

    always #5 clk = ~clk;

    task do_write(input [31:0] a, input [31:0] d);
        begin
            addr = a; wdata = d; 
            mem_write = 1; mem_read = 0;
            @(posedge clk);
            #1 mem_write = 0;
        end
    endtask

    task check_read(input [31:0] actual_data, input exp_hit, input [31:0] exp_data, input exp_dirty);
        begin
            addr = actual_data; mem_read = 1; mem_write = 0;
            #1;
            if (hit === exp_hit && (!exp_hit || rdata === exp_data) && dirty_out === exp_dirty) begin
                pass_count = pass_count + 1;
                $display("PASS: addr=%h hit=%b data=%h dirty=%b", actual_data, hit, rdata, dirty_out);
            end 
            else begin
                fail_count = fail_count + 1;
                $display("FAIL: addr=%h expected hit=%b data=%h dirty=%b | got hit=%b data=%h dirty=%b",
                          actual_data, exp_hit, exp_data, exp_dirty, hit, rdata, dirty_out);
            end
        end
    endtask

    initial begin
        $dumpfile("sim/dcache.vcd");
        $dumpvars(0, dcache_tb);
        
        clk = 0; rst_n = 0; mem_read = 0; mem_write = 0; addr = 0; wdata = 0;
        #10 rst_n = 1;

        // Cold read miss
        check_read(32'h00000040, 1'b0, 32'h0, 1'b0);   

        // Write then read back 
        do_write(32'h00000040, 32'h11111111);
        check_read(32'h00000040, 1'b1, 32'h11111111, 1'b1);

        // Write-allocate on DIFFERENT tag, SAME index 
        do_write(32'h00000440, 32'h22222222); 
        check_read(32'h00000440, 1'b1, 32'h22222222, 1'b1);
        check_read(32'h00000040, 1'b0, 32'h0, 1'b1);    

        // Independent set stays untouched
        do_write(32'h00000048, 32'h33333333); 
        check_read(32'h00000048, 1'b1, 32'h33333333, 1'b1);
        check_read(32'h00000440, 1'b1, 32'h22222222, 1'b1); 

        $display("\n--- RESULTS: %0d PASS / %0d FAIL ---", pass_count, fail_count);
        $finish;
    end

endmodule