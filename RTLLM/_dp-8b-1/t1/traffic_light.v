module traffic_light (
    input rst_n,
    input clk,
    input pass_request,
    output [7:0] clock,
    output red,
    output yellow,
    output green
);

// Parameters for state encoding
parameter idle      = 2'b00;
parameter s1_red    = 2'b01;
parameter s2_yellow = 2'b10;
parameter s3_green  = 2'b11;

// Internal registers
reg [7:0] cnt;
reg [1:0] state;
reg p_red, p_yellow, p_green;

// State transition logic
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state <= idle;
    end
    else begin
        case (state)
            idle: begin
                state <= s1_red;
            end
            
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
            
            default: begin
                state <= idle;
            end
        endcase
    end
end

// Counter logic
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt <= 8'd10;
    end
    else begin
        // Handle pedestrian request during green light
        if (pass_request && green && (cnt > 8'd10)) begin
            cnt <= 8'd10;
        end
        // State transition conditions
        else if (state == s3_green && !p_green && green) begin
            cnt <= 8'd60;
        end
        else if (state == s2_yellow && !p_yellow && yellow) begin
            cnt <= 8'd5;
        end
        else if (state == s1_red && !p_red && red) begin
            cnt <= 8'd10;
        end
        // Normal countdown
        else if (cnt > 8'd0) begin
            cnt <= cnt - 8'd1;
        end
    end
end

// Output the counter value
assign clock = cnt;

// Output signal generation
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        p_red    <= 1'b0;
        p_yellow <= 1'b0;
        p_green  <= 1'b0;
    end
    else begin
        p_red    <= (state == s1_red);
        p_yellow <= (state == s2_yellow);
        p_green  <= (state == s3_green);
    end
end

assign red    = p_red;
assign yellow = p_yellow;
assign green  = p_green;

endmodule
