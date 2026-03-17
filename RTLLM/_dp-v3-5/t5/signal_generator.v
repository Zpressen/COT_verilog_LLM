module signal_generator (
    input clk,
    input rst_n,
    output reg [4:0] wave
);

reg state; // 0 = increment, 1 = decrement

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        state <= 0;
        wave <= 0;
    end
    else begin
        case (state)
            0: begin
                wave <= wave + 1;
                if (wave == 30) state <= 1; // Will be 31 next cycle
            end
            1: begin
                wave <= wave - 1;
                if (wave == 1) state <= 0; // Will be 0 next cycle
            end
        endcase
    end
end

endmodule
