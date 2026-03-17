module pulse_detect (
    input clk,
    input rst_n,
    input data_in,
    output reg data_out
);

reg [1:0] state, next_state;
parameter S00 = 2'b00, S01 = 2'b01, S10 = 2'b10, S11 = 2'b11;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state <= S00;
        data_out <= 1'b0;
    end else begin
        state <= next_state;
        data_out <= (state == S01 && data_in == 1'b0) ? 1'b1 : 1'b0;
    end
end

always @(*) begin
    next_state = state; // default
    case (state)
        S00: begin
            if (data_in == 1'b0)
                next_state = S00;
            else
                next_state = S01;
        end
        S01: begin
            if (data_in == 1'b0)
                next_state = S10;
            else
                next_state = S11;
        end
        S10: begin
            if (data_in == 1'b0)
                next_state = S00;
            else
                next_state = S01;
        end
        S11: begin
            if (data_in == 1'b0)
                next_state = S10;
            else
                next_state = S11;
        end
        default: next_state = S00;
    endcase
end

endmodule
