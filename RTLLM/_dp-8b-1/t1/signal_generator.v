module signal_generator (
    input clk,
    input rst_n,
    output reg [4:0] wave
);

reg state;  // 0 = increment, 1 = decrement

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        // Active-low reset: clear state and wave
        state <= 1'b0;
        wave <= 5'b0;
    end
    else begin
        case (state)
            1'b0: begin
                // Increment state
                wave <= wave + 1'b1;
                if (wave == 5'd30) begin
                    // Next cycle will reach 31, transition to decrement state
                    state <= 1'b1;
                end
            end
            1'b1: begin
                // Decrement state
                wave <= wave - 1'b1;
                if (wave == 5'd1) begin
                    // Next cycle will reach 0, transition to increment state
                    state <= 1'b0;
                end
            end
            default: begin
                // Should never happen, but good practice to include
                state <= 1'b0;
                wave <= 5'b0;
            end
        endcase
    end
end

endmodule
