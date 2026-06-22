`timescale 1ns/1ps

module forwarding_tb;
    reg clk, rst_n;
    always #5 clk = ~clk;

    top_pipeline dut ( .clk(clk), .rst_n(rst_n) );

    wire [31:0] rf [0:31];
    genvar gi;
    generate
        for(gi=0; gi<32; gi=gi+1) begin: probe
            assign rf[gi] = dut.id0.rf0.regfile[gi];
        end
    endgenerate

    initial begin
        $dumpfile("sim/forwarding.vcd");
        $dumpvars(0, forwarding_tb);

        clk=0; rst_n=0;
        #12 rst_n=1;

        repeat(14) @(posedge clk);

        #1 if (rf[12] === 32'd21)
            $display("PASS: back-to-back hazard resolved by forwarding, x12=%0d", rf[12]);
        else
            $display("FAIL: x12=%0d, expected 21", rf[12]);
        
        $finish;
    end

endmodule