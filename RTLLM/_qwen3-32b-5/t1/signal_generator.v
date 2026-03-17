module signal_generator (
    input clk,
    input rst_n,
    output reg [4:0] wave
);

reg state; // 0 for increment, 1 for decrement
reg [4:0] next_wave;
reg state_next;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state <= 1'b0;
        wave <= 5'd0;
    end else begin
        case (state)
            1'b0: begin
                if (wave == 5'd31) begin
                    next_wave = 5'd31;
                    state_next = 1'b1;
                end else begin
                    next_wave = wave + 1;
                    state_next = 1'b0;
                end
            end
            1'b1: begin
                if (wave == 5'd0) begin
                    next_wave = 5'd0;
                    state_next = 1'b0;
                end else begin
                    next_wave = wave - 1;
                    state_next = 1'b1;
                end
            end
            default: begin
                next_wave = wave;
                state_next = state;
            end
        endcase
        state <= state_next;
        wave <= next_wave;
    end
end

endmodule
