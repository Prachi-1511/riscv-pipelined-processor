module cache_ctrl #(
    parameter miss_penalty = 4     // "fetch from memory" cycles
)(
    input  wire clk,
    input  wire rst_n,
    input  wire cache_hit,         // combinational hit signal from icache/dcache
    input  wire req_valid,         // fetch/mem stage is requesting an access
    output reg  stall,             // 1 cyclec: freeze pipeline
    output reg  fill_trigger       // 1-cycle pulse: tells cache "fill the line now"
);

    localparam IDLE = 2'b00, MISS_WAIT = 2'b01, FILL_WAIT = 2'b10;
    reg [1:0] state;
    reg [2:0] counter;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state        <= IDLE;
            counter      <= 0;
            stall        <= 1'b0;
            fill_trigger <= 1'b0;
        end else begin
            fill_trigger <= 1'b0; // default: pulse low unless set below

            case (state)
                IDLE: begin
                    if (req_valid && !cache_hit) begin
                        state   <= MISS_WAIT;
                        counter <= miss_penalty - 1;
                        stall   <= 1'b1;
                    end else begin
                        stall <= 1'b0;
                    end
                end

                MISS_WAIT: begin
                    if (counter == 0) begin
                        fill_trigger <= 1'b1;  // memory data "arrived" -> fill cache
                        state        <= FILL_WAIT;
                    end 
                    else counter <= counter - 1;
                end

                FILL_WAIT: begin
                    state <= IDLE;
                    stall <= 1'b0;
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule