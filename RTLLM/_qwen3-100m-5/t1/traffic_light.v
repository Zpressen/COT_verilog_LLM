module traffic_light (
    input rst_n,
    input clk,
    input pass_request,
    output [7:0] clock,
    output red,
    output yellow,
    output green
);

parameter idle = 2'b00,
          s1_red = 2'b01,
          s2_yellow = 2'b10,
          s3_green = 2'b11;

reg [1:0] state, prev_state;
reg [7:0] cnt;
reg p_red, p_yellow, p_green;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state <= idle;
        p_red <= 0;
        p_yellow <= 0;
        p_green <= 0;
    end else begin
        case(state)
            idle: begin
                state <= s1_red;
                p_red <= 1;
                p_yellow <= 0;
                p_green <= 0;
            end
            s1_red: begin
                if (cnt == 0) begin
                    state <= s3_green;
                    p_red <= 0;
                    p_yellow <= 0;
                    p_green <= 1;
                end else begin
                    state <= s1_red;
                    p_red <= 1;
                    p_yellow <= 0;
                    p_green <= 0;
                end
            end
            s2_yellow: begin
                if (cnt == 0) begin
                    state <= s1_red;
                    p_red <= 1;
                    p_yellow <= 0;
                    p_green <= 0;
                end else begin
                    state <= s2_yellow;
                    p_red <= 0;
                    p_yellow <= 1;
                    p_green <= 0;
                end
            end
            s3_green: begin
                if (cnt == 0) begin
                    state <= s2_yellow;
                    p_red <= 0;
                    p_yellow <= 1;
                    p_green <= 0;
                end else begin
                    state <= s3_green;
                    p_red <= 0;
                    p_yellow <= 0;
                    p_green <= 1;
                end
            end
            default: begin
                state <= idle;
                p_red <= 0;
                p_yellow <= 0;
                p_green <= 0;
            end
        endcase
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        prev_state <= idle;
    end else begin
        prev_state <= state;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt <= 8'd10;
    end else begin
        if (pass_request && (state == s3_green) && cnt > 8'd10) begin
            cnt <= 8'd10;
        end else if (state == s3_green && prev_state != s3_green) begin
            cnt <= 8'd60;
        end else if (state == s2_yellow && prev_state != s2_yellow) begin
            cnt <= 8'd5;
        end else if (state == s1_red && prev_state != s1_red) begin
            cnt <= 8'd10;
        end else begin
            cnt <= cnt - 1;
        end
    end
end

assign clock = cnt;

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

endmodule
