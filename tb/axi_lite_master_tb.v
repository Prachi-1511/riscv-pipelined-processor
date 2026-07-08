`timescale 1ns/1ps

module axi_lite_master_tb;

    reg clk, rst_n, start_read;
    reg [31:0] read_addr;
    wire [31:0] read_data;
    wire done;

    wire ARVALID, RREADY;
    wire [31:0] ARADDR;
    reg  ARREADY;
    reg  RVALID;
    reg  [31:0] RDATA;

    integer pass_count = 0, fail_count = 0;

    axi_lite_master dut (
        .clk(clk), .rst_n(rst_n),
        .start_read(start_read), .read_addr(read_addr),
        .read_data(read_data), .done(done),
        .ARVALID(ARVALID), .ARADDR(ARADDR), .ARREADY(ARREADY),
        .RVALID(RVALID), .RDATA(RDATA), .RREADY(RREADY)
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

    initial begin
        $dumpfile("sim/axi_lite_master");
        $dumpvars(0, axi_lite_master_tb);
        
        clk=0; rst_n=0; start_read=0; read_addr=0;
        ARREADY=0; RVALID=0; RDATA=0;
        
        #12 rst_n = 1;

        // tests that master HOLDS
        @(negedge clk); start_read = 1; read_addr = 32'h100;
        @(negedge clk); start_read = 0;
        check(ARVALID == 1'b1, "ARVALID asserted immediately, not waiting for ARREADY");

        // ARREADY still 0
        @(negedge clk); 
        check(ARVALID == 1'b1 && ARADDR == 32'h100, "ARVALID/ARADDR held stable while slave not ready");

        ARREADY = 1;
        @(negedge clk); // address phase completes
        ARREADY = 0;
        check(RREADY == 1'b1, "RREADY asserted after address phase completes");

        // Slave takes 1 cycle to produce data
        @(negedge clk);
        RVALID = 1; RDATA = 32'hCAFEBABE;
        @(negedge clk); // RVALID && RREADY both true -> data captured
        RVALID = 0;
        check(done == 1'b1 && read_data == 32'hCAFEBABE, "Read data captured correctly on handshake");

        $display("\n--- RESULTS: %0d PASS / %0d FAIL ---", pass_count, fail_count);
        $finish;
    end

endmodule