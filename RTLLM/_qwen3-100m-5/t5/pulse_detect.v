module pulse_detect(
    input clk,
    input rst_n,
    input data_in,
    output reg data_out
);

reg [1:0] state;
parameter IDLE = 2'b00;
parameter HIGH = 2'b01;
parameter PULSE_DET = 2'b10;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state <= IDLE;
        data_out <= 1'b0;
    end else begin
        case (state)
            IDLE: begin
                if (data_in) begin
                    state <= HIGH;
                end else begin
                    state <= IDLE;
                end
                data_out <= 1'b0;
            end
            HIGH: begin
                if (!data_in) begin
                    state <= PULSE_DET;
                end else begin
                    state <= HIGH;
                end
                data_out <= 1'b0;
            end
            PULSE_DET: begin
                state <= IDLE;
                data_out <= 1'b1;
            end
            default: begin
                state <= IDLE;
                data_out <= 1'b0;
            end
        endcase
    end
end

endmodule
