module traffic_light (
    input rst_n,
    input clk,
    input pass_request,
    output [7:0] clock,
    output red,
    output yellow,
    output green
);

parameter IDLE = 2'b00;
parameter S1_RED = 2'b01;
parameter S2_YELLOW = 2'b10;
parameter S3_GREEN = 2'b11;

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
                if (cnt == 0)
                    state <= S3_GREEN;
                else
                    state <= S1_RED;
            end
            S2_YELLOW: begin
                if (cnt == 0)
                    state <= S1_RED;
                else
                    state <= S2_YELLOW;
            end
            S3_GREEN: begin
                if (cnt == 0)
                    state <= S2_YELLOW;
                else
                    state <= S3_GREEN;
            end
            default: state <= IDLE;
        endcase
    end
end

// Counter logic
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt <= 8'd10;
    end else if (pass_request && green) begin
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

// Output signals logic
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        p_red <= 1'b0;
        p_yellow <= 1'b0;
        p_green <= 1'b0;
    end else begin
        p_red <= red;
        p_yellow <= yellow;
        p_green <= green;
    end
end

// Assign current red/yellow/green based on state
always @(*) begin
    red = (state == S1_RED);
    yellow = (state == S2_YELLOW);
    green = (state == S3_GREEN);
end

assign clock = cnt;

endmodule
