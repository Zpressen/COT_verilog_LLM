module traffic_light(
    input rst_n,
    input clk,
    input pass_request,
    output reg [7:0] clock,
    output red,
    output yellow,
    output green
);

parameter idle = 2'b00,
          s1_red = 2'b01,
          s2_yellow = 2'b10,
          s3_green = 2'b11;

reg [1:0] state, next_state;
reg [7:0] cnt;
reg p_red, p_yellow, p_green;

// State transition logic
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state <= idle;
        p_red <= 1'b0;
        p_yellow <= 1'b0;
        p_green <= 1'b0;
    end else begin
        case (state)
            idle: begin
                state <= s1_red;
                p_red <= 1'b0;
                p_yellow <= 1'b0;
                p_green <= 1'b0;
            end
            s1_red: begin
                if (cnt == 0) begin
                    state <= s3_green;
                    p_red <= 1'b0;
                    p_yellow <= 1'b0;
                    p_green <= 1'b1;
                end else begin
                    state <= s1_red;
                    p_red <= 1'b1;
                    p_yellow <= 1'b0;
                    p_green <= 1'b0;
                end
            end
            s2_yellow: begin
                if (cnt == 0) begin
                    state <= s1_red;
                    p_red <= 1'b1;
                    p_yellow <= 1'b0;
                    p_green <= 1'b0;
                end else begin
                    state <= s2_yellow;
                    p_red <= 1'b0;
                    p_yellow <= 1'b1;
                    p_green <= 1'b0;
                end
            end
            s3_green: begin
                if (cnt == 0) begin
                    state <= s2_yellow;
                    p_red <= 1'b0;
                    p_yellow <= 1'b1;
                    p_green <= 1'b0;
                end else begin
                    state <= s3_green;
                    p_red <= 1'b0;
                    p_yellow <= 1'b0;
                    p_green <= 1'b1;
                end
            end
        endcase
    end
end

// Counter logic
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt <= 8'd10;
    end else begin
        if (pass_request && p_green) begin
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

// Output logic
assign clock = cnt;

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
