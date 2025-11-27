module width_8to16 (
    input clk,
    input rst_n,
    input valid_in,
    input [7:0] data_in,
    output reg valid_out,
    output reg [15:0] data_out
);

typedef enum logic [1:0] {IDLE = 2'b00, WAIT_SECOND = 2'b01} state_t;
state_t state;

reg [7:0] data_lock;
reg [15:0] data_temp;
reg output_valid_next;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state <= IDLE;
        data_lock <= 8'b0;
        data_temp <= 16'b0;
        output_valid_next <= 1'b0;
        data_out <= 16'b0;
        valid_out <= 1'b0;
    end else begin
        case (state)
            IDLE: begin
                if (valid_in) begin
                    data_lock <= data_in;
                    state <= WAIT_SECOND;
                end else begin
                    state <= IDLE;
                end
            end
            WAIT_SECOND: begin
                if (valid_in) begin
                    data_temp <= {data_lock, data_in};
                    output_valid_next <= 1'b1;
                    state <= IDLE;
                end else begin
                    state <= WAIT_SECOND;
                end
            end
        endcase

        if (output_valid_next) begin
            data_out <= data_temp;
            valid_out <= 1'b1;
            output_valid_next <= 1'b0;
        end else begin
            valid_out <= 1'b0;
        end
    end
end

endmodule
