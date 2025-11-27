module traffic_light (
    input rst_n,
    input clk,
    input pass_request,
    output reg [7:0] clock,
    output reg red,
    output reg yellow,
    output reg green
);

// State definitions
parameter idle = 2'b00;
parameter s1_red = 2'b01;
parameter s2_yellow = 2'b10;
parameter s3_green = 2'b11;

reg [1:0] state;
reg [1:0] next_state;
reg [7:0] cnt;
wire [7:0] next_cnt;

// State transition logic
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state <= idle;
        cnt <= 10;
    end else begin
        state <= next_state;
        cnt <= next_cnt;
    end
end

// Next state logic
always @(*) begin
    case (state)
        idle: begin
            next_state = s1_red;
        end
        s1_red: begin
            next_state = (cnt == 1) ? s3_green : s1_red;
        end
        s2_yellow: begin
            next_state = (cnt == 1) ? s1_red : s2_yellow;
        end
        s3_green: begin
            next_state = (cnt == 1) ? s2_yellow : s3_green;
        end
        default: next_state = idle;
    endcase
end

// Counter logic
assign next_cnt = 
    (!rst_n) ? 10 :
    ((state == s3_green) && pass_request && (cnt > 10)) ? 10 :
    (state == s1_red && next_state == s3_green) ? 60 :
    (state == s3_green && next_state == s2_yellow) ? 5 :
    (state == s2_yellow && next_state == s1_red) ? 10 :
    cnt - 1;

// Output logic
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        red <= 0;
        yellow <= 0;
        green <= 0;
        clock <= 0;
    end else begin
        case (state)
            s1_red: begin
                red <= 1;
                yellow <= 0;
                green <= 0;
            end
            s2_yellow: begin
                red <= 0;
                yellow <= 1;
                green <= 0;
            end
            s3_green: begin
                red <= 0;
                yellow <= 0;
                green <= 1;
            end
            default: begin
                red <= 0;
                yellow <= 0;
                green <= 0;
            end
        endcase
        clock <= cnt;
    end
end

endmodule
