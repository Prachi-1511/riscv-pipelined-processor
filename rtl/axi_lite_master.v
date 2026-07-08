`include "rtl/axi_lite_if.vh"

module axi_lite_master (
    input  wire        clk,
    input  wire        rst_n,

    // Simple internal request interface
    input  wire        start_read,
    input  wire [31:0] read_addr,
    output reg  [31:0] read_data,
    output reg         done,

    // AXI4-Lite Read Address channel
    output reg          ARVALID,
    output reg  [31:0]  ARADDR,
    input  wire         ARREADY,

    // AXI4-Lite Read Data channel
    input  wire         RVALID,
    input  wire [31:0]  RDATA,
    output reg          RREADY
);

    localparam IDLE      = 2'b00;
    localparam ADDR_PHASE= 2'b01;
    localparam DATA_PHASE= 2'b10;

    reg [1:0] state;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state    <= IDLE;
            ARVALID  <= 1'b0;
            ARADDR   <= 32'b0;
            RREADY   <= 1'b0;
            read_data<= 32'b0;
            done     <= 1'b0;
        end 
        else begin
            done <= 1'b0; 

            case (state)
                IDLE: begin
                    if (start_read) begin
                        ARVALID <= 1'b1;
                        ARADDR  <= read_addr;
                        state   <= ADDR_PHASE;
                    end
                end

                ADDR_PHASE: begin
                    if (ARVALID && ARREADY) begin
                        ARVALID <= 1'b0;   // address accepted, drop VALID
                        RREADY  <= 1'b1;   // ready to accept data
                        state   <= DATA_PHASE;
                    end
                    // else: hold ARVALID and ARADDR stable, keep waiting
                end

                DATA_PHASE: begin
                    if (RVALID && RREADY) begin
                        read_data <= RDATA;
                        RREADY    <= 1'b0;
                        done      <= 1'b1;
                        state     <= IDLE;
                    end
                    // else: hold RREADY high, keep waiting
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule