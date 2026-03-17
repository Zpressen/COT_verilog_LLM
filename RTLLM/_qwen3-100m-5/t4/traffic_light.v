module traffic_light (
    input rst_n,
    input clk,
    input pass_request,
    output [7:0] clock,
    output red,
    output yellow,
    output green
);

    parameter idle = 2'd0,
              s1_red = 2'd1,
              s2_yellow = 2'd2,
              s3_green = 2'd3;

    reg [1:0] state, next_state;
    reg [7:0] cnt;
    reg p_red, p_yellow, p_green;
    reg red_r, yellow_r, green_r;

    // Next state logic
    always @(*) begin
        next_state = state;
        case (state)
            idle: next_state = s1_red;
            s1_red: if (cnt == 8'd0) next_state = s3_green;
            s2_yellow: if (cnt == 8'd0) next_state = s1_red;
            s3_green: if (cnt == 8'd0) next_state = s2_yellow;
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

    // Combinational output logic
    always @(*) begin
        case (state)
            idle: begin p_red = 1'b0; p_yellow = 1'b0; p_green = 1'b0; end
            s1_red: begin p_red = 1'b1; p_yellow = 1'b0; p_green = 1'b0; end
            s2_yellow: begin p_red = 1'b0; p_yellow = 1'b1; p_green = 1'b0; end
            s3_green: begin p_red = 1'b0; p_yellow = 1'b0; p_green = 1'b1; end
            default: begin p_red = 1'b0; p_yellow = 1'b0; p_green = 1'b0; end
        endcase
    end

    // Output registers
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            red_r <= 1'b0;
            yellow_r <= 1'b0;
            green_r <= 1'b0;
        end else begin
            red_r <= p_red;
            yellow_r <= p_yellow;
            green_r <= p_green;
        end
    end

    // Counter logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt <= 8'd10;
        end else begin
            if (pass_request && (state == s3_green)) begin
                if (cnt > 8'd10)
                    cnt <= 8'd10;
                else
                    cnt <= cnt;
            end else if ((green_r == 1'b0) && (p_green == 1'b1)) begin
                cnt <= 8'd60;
            end else if ((yellow_r == 1'b0) && (p_yellow == 1'b1)) begin
                cnt <= 8'd5;
            end else if ((red_r == 1'b0) && (p_red == 1'b1)) begin
                cnt <= 8'd10;
            end else begin
                cnt <= cnt - 1;
            end
        end
    end

    // Output assignments
    assign clock = cnt;
    assign red = red_r;
    assign yellow = yellow_r;
    assign green = green_r;

endmodule
