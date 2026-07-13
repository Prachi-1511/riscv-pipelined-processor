// fundamental DFT building block

module scan_ff (
    input  wire clk,
    input  wire rst_n,
    input  wire scan_enable,   // 1 = test mode, 0 = normal functional mode
    input  wire scan_in,       // previous flip-flop's output
    input  wire d,             // normal functional data input
    output reg  q,
    output wire scan_out      
);
    wire mux_out = scan_enable ? scan_in : d;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) q <= 1'b0;
        else        q <= mux_out;
    end

    assign scan_out = q;
endmodule