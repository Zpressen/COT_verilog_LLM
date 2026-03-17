module signal_generator (
    input clk,
    input rst_n,
    output reg [4:0] wave
);

reg state;  // 0 = increment, 1 = decrement

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        wave <= 5'b0;
        state <= 1'b0;
    end
    else begin
        case (state)
            1'b0: begin
                wave <= wave + 1;
                if (wave == 5'd30) begin  // Will become 31 after this increment
                    state <= 1'b1;
                end
            end
            1'b1: begin
                wave <= wave - 1;
                if (wave == 5'd1) begin   // Will become 0 after this decrement
                    state <= 1'b0;
                end
            end
        endcase
    end
end

endmodule
