module signal_generator (
    input      clk,
    input      rst_n,
    output reg [4:0] wave
);

reg state; // 0: increment, 1: decrement

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state <= 1'b0;
        wave  <= 5'b0;
    end else begin
        case (state)
            1'b0: begin // Increment phase
                if (wave == 5'd31) begin
                    state <= 1'b1; // Switch to decrement
                    // wave remains at 31
                end else begin
                    wave <= wave + 1;
                    // state remains 0
                end
            end
            1'b1: begin // Decrement phase
                if (wave == 5'd0) begin
                    state <= 1'b0; // Switch to increment
                    // wave remains at 0
                end else begin
                    wave <= wave - 1;
                    // state remains 1
                end
            end
        endcase
    end
end

endmodule
