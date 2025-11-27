module width_8to16 (
    input clk,
    input rst_n,
    input valid_in,
    input [7:0] data_in,
    output reg valid_out,
    output reg [15:0] data_out
);

typedef enum logic {IDLE, WAITING} state_t;
state_t state, next_state;
reg [7:0] data_lock;
reg [15:0] next_data_out;
reg next_valid_out;

always @(*) begin
    next_state = state;
    next_valid_out = 0;
    next_data_out = 0;
    case (state)
        IDLE: begin
            if (valid_in) begin
                next_state = WAITING;
                next_valid_out = 0;
                next_data_out = 0;
            end
        end
        WAITING: begin
            if (valid_in) begin
                next_state = IDLE;
                next_valid_out = 1;
                next_data_out = {data_lock, data_in};
            end else begin
                next_valid_out = 0;
                next_data_out = 0;
            end
        end
    endcase
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state <= IDLE;
        data_lock <= 0;
        data_out <= 0;
        valid_out <= 0;
        next_data_out <= 0;
        next_valid_out <= 0;
    end else begin
        state <= next_state;
        case (state)
            IDLE: begin
                if (valid_in) data_lock <= data_in;
            end
            default: data_lock <= data_lock;
        endcase
        data_out <= next_data_out;
        valid_out <= next_valid_out;
    end
end

endmodule
