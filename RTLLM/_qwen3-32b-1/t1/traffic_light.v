module traffic_light (
    input rst_n,
    input clk,
    input pass_request,
    output reg [7:0] clock,
    output reg red,
    output reg yellow,
    output reg green
);

parameter IDLE = 2'b00,
          S1_RED = 2'b01,
          S2_YELLOW = 2'b10,
          S3_GREEN = 2'b11;

reg [1:0] state, next_state;
reg [7:0] cnt;
reg p_red, p_yellow, p_green;

// State transition and output logic
always @(*) begin
    next_state = state;
    p_red = 1'b0;
    p_yellow = 1'b0;
    p_green = 1'b0;

    case (state)
        IDLE: begin
            next_state = S1_RED;
            p_red = 1'b1;
        end

        S1_RED: begin
            if (cnt == 0) next_state = S3_GREEN;
            p_red = 1'b1;
        end

        S2_YELLOW: begin
            if (cnt == 0) next_state = S1_RED;
            p_yellow = 1'b1;
        end

        S3_GREEN: begin
            if (cnt == 0) next_state = S2_YELLOW;
            p_green = 1'b1;
        end

        default: next_state = IDLE;
    endcase
end

// State flip-flops
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        state <= IDLE;
    else
        state <= next_state;
end

// Counter logic
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt <= 8'd10;
        clock <= 8'd10;
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
        clock <= cnt;
    end
end

// Output logic
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
