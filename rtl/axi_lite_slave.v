`include "rtl/axi_lite_if.vh"

module axi_lite_slave (
    input  wire        clk,
    input  wire        rst_n,

    // Read Address channel
    input  wire         ARVALID,
    input  wire [31:0]  ARADDR,
    output reg           ARREADY,

    // Read Data channel
    output reg           RVALID,
    output reg  [31:0]   RDATA,
    output reg  [1:0]    RRESP,
    input  wire          RREADY
);

    // 16-word memory, for loopback test
    reg [31:0] mem [0:15];
    integer i;

    localparam IDLE    = 1'b0;
    localparam RESPOND = 1'b1;
    reg state;

    initial begin
        for (i = 0; i < 16; i = i + 1)
            mem[i] = 32'hA000_0000 + i; // predictable pattern: A0000000, A0000001, ...
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state   <= IDLE;
            ARREADY <= 1'b1;   // ready for a new address
            RVALID  <= 1'b0;
            RDATA   <= 32'b0;
            RRESP   <= `AXI_RESP_OKAY;
        end 
        else begin
            case (state)
                IDLE: begin
                    ARREADY <= 1'b1;  
                    if (ARVALID && ARREADY) begin
                        RDATA   <= mem[ARADDR[5:2]]; // word-addressed
                        RVALID  <= 1'b1;
                        RRESP   <= `AXI_RESP_OKAY;
                        ARREADY <= 1'b0;  // busy responding, don't accept a new address yet
                        state   <= RESPOND;
                    end
                end

                RESPOND: begin
                    if (RVALID && RREADY) begin
                        RVALID  <= 1'b0;
                        ARREADY <= 1'b1;  // ready for next transaction
                        state   <= IDLE;
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule