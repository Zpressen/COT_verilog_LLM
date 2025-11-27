[_BEGIN]
module traffic_light (
    input rst_n,
    input clk,
    input pass_request,
    output reg [7:0] clock,
    output red,
    output yellow,
    output green
);

parameter IDLE = 2'b00,
          S1_RED = 2'b01,
          S2_YELLOW = 2'b10,
          S3_GREEN = 2'b11;

reg [1:0] state;
reg [7:0] cnt;
reg p_red, p_yellow, p_green;

// State transition logic
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state <= IDLE;
    end else begin
        case (state)
            IDLE: begin
                state <= S1_RED;
            end
            S1_RED: begin
                if (cnt == 0) begin
                    state <= S3_GREEN;
                end else begin
                    state <= S1_RED;
                end
            end
            S2_YELLOW: begin
                if (cnt == 0) begin
                    state <= S1_RED;
                end else begin
                    state <= S2_YELLOW;
                end
            end
            S3_GREEN: begin
                if (cnt == 0) begin
                    state <= S2_YELLOW;
                end else begin
                    state <= S3_GREEN;
                end
            end
            default: state <= IDLE;
        endcase
    end
end

// Counter logic
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt <= 8'd10;
    end else begin
        if (pass_request && green && (cnt > 10)) begin
            cnt <= 10;
        end else if (!green && p_green) begin
            cnt <= 60;
        end else if (!yellow && p_yellow) begin
            cnt <= 5;
        end else if (!red && p_red) begin
            cnt <= 10;
        end else begin
            cnt <= cnt - 1;
        end
    end
end

// Output logic
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        p_red <= 1'b0;
        p_yellow <= 1'b0;
        p_green <= 1'b0;
    end else begin
        case (state)
            IDLE: begin
                p_red <= 1'b0;
                p_yellow <= 1'b0;
                p_green <= 1'b0;
            end
            S1_RED: begin
                p_red <= 1'b1;
                p_yellow <= 1'b0;
                p_green <= 1'b0;
            end
            S2_YELLOW: begin
                p_red <= 1'b0;
                p_yellow <= 1'b1;
                p_green <= 1'b0;
            end
            S3_GREEN: begin
                p_red <= 1'b0;
                p_yellow <= 1'b0;
                p_green <= 1'b1;
            end
        endcase
    end
end

// Assign outputs
assign red = p_red;
assign yellow = p_yellow;
assign green = p_green;

// Assign clock output
assign clock = cnt;

endmodule
