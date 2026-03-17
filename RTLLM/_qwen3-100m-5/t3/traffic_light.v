module traffic_light(
    input rst_n,
    input clk,
    input pass_request,
    output reg [7:0] clock,
    output reg red,
    output reg yellow,
    output reg green
);

parameter idle = 2'b00, s1_red = 2'b01, s2_yellow = 2'b10, s3_green = 2'b11;

reg [1:0] state, next_state;
reg [7:0] cnt;
reg p_red, p_yellow, p_green;

// State transition and output logic
always @(*) begin
    next_state = state;
    case (state)
        idle: begin
            next_state = s1_red;
            p_red = 1;
            p_yellow = 0;
            p_green = 0;
        end
        s1_red: begin
            if (cnt == 0) next_state = s3_green;
            else next_state = s1_red;
            p_red = 1;
            p_yellow = 0;
            p_green = 0;
        end
        s3_green: begin
            if (cnt == 0) next_state = s2_yellow;
            else next_state = s3_green;
            p_red = 0;
            p_yellow = 0;
            p_green = 1;
        end
        s2_yellow: begin
            if (cnt == 0) next_state = s1_red;
            else next_state = s2_yellow;
            p_red = 0;
            p_yellow = 1;
            p_green = 0;
        end
        default: next_state = idle;
    endcase
end

// State register
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        state <= idle;
    else
        state <= next_state;
end

// Counter logic
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt <= 8'd10;
    end else begin
        if (pass_request && green && cnt > 10) begin
            cnt <= 8'd10;
        end else if (green && !p_green) begin
            cnt <= 8'd60;
        end else if (yellow && !p_yellow) begin
            cnt <= 8'd5;
        end else if (red && !p_red) begin
            cnt <= 8'd10;
        end else begin
            cnt <= cnt - 1;
        end
    end
end

// Output assignment
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        red <= 0;
        yellow <= 0;
        green <= 0;
    end else begin
        red <= p_red;
        yellow <= p_yellow;
        green <= p_green;
    end
end

assign clock = cnt;

endmodule
