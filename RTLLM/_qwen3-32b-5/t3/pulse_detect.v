module pulse_detect(
    input clk,
    input rst_n,
    input data_in,
    output reg data_out
);

reg [1:0] state, next_state;

localparam IDLE = 2'b00,
           S1 = 2'b01,
           S2 = 2'b10;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state <= IDLE;
        data_out <= 1'b0;
    end else begin
        case (state)
            IDLE: begin
                if (data_in) begin
                    next_state = S1;
                end else begin
                    next_state = IDLE;
                end
                data_out <= 1'b0;
            end
            S1: begin
                if (data_in == 1'b0) begin
                    next_state = S2;
                    data_out <= 1'b1;
                end else begin
                    next_state = IDLE;
                    data_out <= 1'b0;
                end
            end
            S2: begin
                next_state = IDLE;
                data_out <= 1'b0;
            end
            default: begin
                next_state = IDLE;
                data_out <= 1'b0;
            end
        endcase
        state <= next_state;
    end
end

endmodule
