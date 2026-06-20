`timescale 1ns/1ps

module pipeline_full_tb;
    reg clk = 0, rst_n = 0;
    always #5 clk = ~clk;

    top_pipeline dut (.clk(clk), .rst_n(rst_n));

    wire [31:0] rf [0:31];
    genvar gi;
    generate
        for (gi = 0; gi < 32; gi = gi + 1) begin : probe
            assign rf[gi] = dut.id0.rf0.regfile[gi];
        end
    endgenerate

    initial begin
        $dumpfile("sim/pipeline.vcd");
        $dumpvars(0, pipeline_full_tb);
        
        #12 rst_n = 1;

        // Pipeline takes 5 cycles to fill, then results appear
        repeat (12) @(posedge clk);

        #1 $display("x10=%0d (expect 10)", rf[10]);
        $display("x11=%0d (expect 11)", rf[11]);
        $display("x12=%0d (expect 21)", rf[12]);

        if (rf[10]===32'd10 && rf[11]===32'd11 && rf[12]===32'd21)
            $display("PASS: pipeline computes 10+11=21");
        else
            $display("FAIL — check waveform for hazard");

        $finish;
    end
endmodule