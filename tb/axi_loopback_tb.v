`timescale 1ns/1ps

module axi_loopback_tb;

    reg clk, rst_n, start_read;
    reg [31:0] read_addr;
    wire [31:0] read_data;
    wire done;

    wire ARVALID, ARREADY, RVALID, RREADY;
    wire [31:0] ARADDR, RDATA;
    wire [1:0]  RRESP;

    integer pass_count = 0, fail_count = 0;

    axi_lite_master u_master (
        .clk(clk), .rst_n(rst_n),
        .start_read(start_read), .read_addr(read_addr),
        .read_data(read_data), .done(done),
        .ARVALID(ARVALID), .ARADDR(ARADDR), .ARREADY(ARREADY),
        .RVALID(RVALID), .RDATA(RDATA), .RREADY(RREADY)
    );

    axi_lite_slave u_slave (
        .clk(clk), .rst_n(rst_n),
        .ARVALID(ARVALID), .ARADDR(ARADDR), .ARREADY(ARREADY),
        .RVALID(RVALID), .RDATA(RDATA), .RRESP(RRESP), .RREADY(RREADY)
    );

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

    task do_read(input [31:0] addr, input [31:0] expected);
        begin
            @(negedge clk); start_read = 1; read_addr = addr;
            @(negedge clk); start_read = 0;
            
            wait(done == 1'b1);
            #1 check(read_data == expected, "Loopback read returns correct memory content");
        end
    endtask

    initial begin
        $dumpfile("sim/axi_loopback");
        $dumpvars(0, axi_loopback_tb);
        
        clk=0; rst_n=0; start_read=0; read_addr=0;
        
        #12 rst_n = 1;
        @(negedge clk);

        // addr 0x00 -> index 0 -> mem[0] = A0000000
        do_read(32'h00000000, 32'hA0000000);

        // addr 0x14 -> index 5 -> mem[5] = A0000005
        do_read(32'h00000014, 32'hA0000005);

        // addr 0x3C -> index 15 -> mem[15] = A000000F
        do_read(32'h0000003C, 32'hA000000F);

        $display("\n--- RESULTS: %0d PASS / %0d FAIL ---", pass_count, fail_count);
        $finish;
    end

endmodule