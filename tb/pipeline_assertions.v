module pipeline_assertions (
    input wire clk,
    input wire rst_n,
    input wire hzd_stall,
    input wire if_flush,
    input wire id_flush,
    input wire cache_stall,
    input wire branch_taken
);

    always @(posedge clk) begin
        if (rst_n && hzd_stall && if_flush)
            $error("VIOLATION: hzd_stall and if_flush both asserted in the same cycle");
    end

    reg cache_stall_prev;
    integer stall_len;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cache_stall_prev <= 1'b0;
            stall_len        <= 0;
        end else begin
            if (cache_stall)
                stall_len <= stall_len + 1;
            else
                stall_len <= 0;

            if (stall_len > 6)
                $error("VIOLATION: cache_stall held longer than expected FSM bound");

            cache_stall_prev <= cache_stall;
        end
    end

    always @(posedge clk) begin
        if (rst_n && cache_stall && id_flush && !hzd_stall && !branch_taken)
            $error("VIOLATION: cache_stall triggered id_flush -- Day 25 bug has regressed");
    end

endmodule