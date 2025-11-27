module pulse_detect (
    input clk,
    input rst_n,
    input data_in,
    output reg data_out
);

reg [1:0] state, next_state;
localparam S0 = 2'd0, S1 = 2'd1, S2 = 2'd2;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state <= S0;
        data_out <= 1'b0;
    end else begin
        state <= next_state;
        data_out <= (next_state == S2) ? 1'b1 : 1'b0;
    end
end

always @(*) begin
    next_state = state; // default
    case (state)
        S0: begin
            if (data_in == 1'b0) next_state = S0;
            else next_state = S1;
        end
        S1: begin
            if (data_in == 1'b1) next_state = S1;
            else next_state = S2;
        end
        S2: begin
            if (data_in == 1'b1) next_state = S1;
            else next_state = S0;
        end
        default: next_state = S0;
    endcase
end

endmodule
