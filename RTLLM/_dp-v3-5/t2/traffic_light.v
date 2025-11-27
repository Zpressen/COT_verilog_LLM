module traffic_light(
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
    reg [7:0] cnt;
    reg p_red, p_yellow, p_green;

    // State transition logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= idle;
        end
        else begin
            case (state)
                idle: state <= s1_red;
                
                s1_red: begin
                    if (cnt == 8'd1) state <= s3_green;
                    else state <= s1_red;
                end
                
                s2_yellow: begin
                    if (cnt == 8'd1) state <= s1_red;
                    else state <= s2_yellow;
                end
                
                s3_green: begin
                    if (cnt == 8'd1) state <= s2_yellow;
                    else state <= s3_green;
                end
                
                default: state <= idle;
            endcase
        end
    end

    // Counter logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt <= 8'd10; // Initialize to red duration
        end
        else begin
            // Handle pedestrian request during green
            if (pass_request && state == s3_green && cnt > 8'd10) begin
                cnt <= 8'd10;
            end
            // Normal counter decrement
            else if (cnt > 8'd0) begin
                cnt <= cnt - 8'd1;
            end
            // Reload counter based on new state
            else begin
                case (state)
                    s1_red: cnt <= 8'd10;
                    s2_yellow: cnt <= 8'd5;
                    s3_green: cnt <= 8'd60;
                    default: cnt <= 8'd10;
                endcase
            end
        end
    end

    // Next state light values
    always @(*) begin
        case (state)
            s1_red: begin
                p_red = 1'b1;
                p_yellow = 1'b0;
                p_green = 1'b0;
            end
            s2_yellow: begin
                p_red = 1'b0;
                p_yellow = 1'b1;
                p_green = 1'b0;
            end
            s3_green: begin
                p_red = 1'b0;
                p_yellow = 1'b0;
                p_green = 1'b1;
            end
            default: begin
                p_red = 1'b0;
                p_yellow = 1'b0;
                p_green = 1'b0;
            end
        endcase
    end

    // Output generation
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            red <= 1'b0;
            yellow <= 1'b0;
            green <= 1'b0;
            clock <= 8'd0;
        end
        else begin
            red <= p_red;
            yellow <= p_yellow;
            green <= p_green;
            clock <= cnt;
        end
    end

endmodule
