[EGIN]
module traffic_light (
    input rst_n,
    input clk,
    input pass_request,
    output reg [7:0] clock,
    output reg red,
    output reg yellow,
    output reg green
);

parameter IDLE = 2'd0, S1_RED = 2'd1, S2_YELLOW = 2'd2, S3_GREEN = 2'd3;
reg [1:0] state, next_state;
reg [7:0] cnt;
reg p_red, p_yellow, p_green;

// State transition logic
always @(*) begin
    next_state = state;
    next_p_red = 1'b0;
    next_p_yellow = 1'b0;
    next_p_green = 1'b0;
    case (state)
        IDLE: begin
            next_state = S1_RED;
            next_p_red = 1'b1;
        end
        S1_RED: begin
            if (cnt == 0) begin
                next_state = S3_GREEN;
                next_p_green = 1'b1;
            end else begin
                next_state = S1_RED;
                next_p_red = 1'b1;
            end
        end
        S2_YELLOW: begin
            if (cnt == 0) begin
                next_state = S1_RED;
                next_p_red = 1'b1;
            end else begin
                next_state = S2_YELLOW;
                next_p_yellow = 1'b1;
            end
        end
        S3_GREEN: begin
            if (cnt == 0) begin
                next_state = S2_YELLOW;
                next_p_yellow = 1'b1;
            end else begin
                next_state = S3_GREEN;
                next_p_green = 1'b1;
            end
        end
        default: begin
            next_state = IDLE;
            next_p_red = 1'b0;
            next_p_yellow = 1'b0;
            next_p_green = 1'b0;
        end
    endcase
end

// State and p_* registers
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state <= IDLE;
        p_red <= 1'b0;
        p_yellow <= 1'b0;
        p_green <= 1'b0;
    end else begin
        state <= next_state;
        p_red <= next_p_red;
        p_yellow <= next_p_yellow;
        p_green <= next_p_green;
    end
end

// Counter logic
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt <= 8'd10;
    end else begin
        if (pass_request && green) begin
            cnt <= 8'd10;
        end else if (!green && p_green) begin
            cnt <= 8'd60;
        end else if (!yellow && p_yellow) begin
            cnt <= 8'd5;
        end else if (!red && p_red) begin
            cnt <= 8'd10;
        end else begin
            cnt <= cnt - 1;
        end
    end
end

// Assign clock output
assign clock = cnt;

// Output signals
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        red <= 1'b0;
        yellow <= 1'b0;
        green <= 1'b0;
    end else begin
        red <= p_red;
        yellow <= p_yellow;
        green <= p_green;
    end
end

endmodule
