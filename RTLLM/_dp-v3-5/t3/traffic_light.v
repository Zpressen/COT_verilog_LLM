module traffic_light (
    input rst_n,
    input clk,
    input pass_request,
    output [7:0] clock,
    output red,
    output yellow,
    output green
);

// State encodings
parameter idle = 2'b00;
parameter s1_red = 2'b01;
parameter s2_yellow = 2'b10;
parameter s3_green = 2'b11;

reg [1:0] state;
reg [7:0] cnt;
reg p_red, p_yellow, p_green;
reg r_red, r_yellow, r_green;

// State transition logic
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state <= idle;
    end
    else begin
        case (state)
            idle: state <= s1_red;
            
            s1_red: begin
                if (cnt == 8'd1) begin
                    state <= s3_green;
                end
                else begin
                    state <= s1_red;
                end
            end
            
            s2_yellow: begin
                if (cnt == 8'd1) begin
                    state <= s1_red;
                end
                else begin
                    state <= s2_yellow;
                end
            end
            
            s3_green: begin
                if (cnt == 8'd1) begin
                    state <= s2_yellow;
                end
                else begin
                    state <= s3_green;
                end
            end
            
            default: state <= idle;
        endcase
    end
end

// Counter management logic
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt <= 8'd10;
    end
    else begin
        // Handle pass_request during green
        if (pass_request && (state == s3_green) && (cnt > 8'd10)) begin
            cnt <= 8'd10;
        end
        // State transition conditions
        else if ((state == s3_green) && (cnt == 8'd1)) begin
            cnt <= 8'd5;  // transition to yellow
        end
        else if ((state == s2_yellow) && (cnt == 8'd1)) begin
            cnt <= 8'd10; // transition to red
        end
        else if ((state == s1_red) && (cnt == 8'd1)) begin
            cnt <= 8'd60; // transition to green
        end
        // Normal countdown
        else if (cnt > 8'd0) begin
            cnt <= cnt - 8'd1;
        end
    end
end

// Next state output logic
always @(*) begin
    p_red = 1'b0;
    p_yellow = 1'b0;
    p_green = 1'b0;
    
    case (state)
        s1_red: p_red = 1'b1;
        s2_yellow: p_yellow = 1'b1;
        s3_green: p_green = 1'b1;
        default: begin
            p_red = 1'b0;
            p_yellow = 1'b0;
            p_green = 1'b0;
        end
    endcase
end

// Output register
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        r_red <= 1'b0;
        r_yellow <= 1'b0;
        r_green <= 1'b0;
    end
    else begin
        r_red <= p_red;
        r_yellow <= p_yellow;
        r_green <= p_green;
    end
end

// Output assignments
assign clock = cnt;
assign red = r_red;
assign yellow = r_yellow;
assign green = r_green;

endmodule
