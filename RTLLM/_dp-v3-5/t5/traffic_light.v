module traffic_light (
    input rst_n,
    input clk,
    input pass_request,
    output reg [7:0] clock,
    output reg red,
    output reg yellow,
    output reg green
);

    // State encoding
    localparam [1:0] idle      = 2'b00;
    localparam [1:0] s1_red    = 2'b01;
    localparam [1:0] s2_yellow = 2'b10;
    localparam [1:0] s3_green  = 2'b11;

    reg [1:0] state, next_state;
    reg [7:0] next_clock;
    reg p_red, p_yellow, p_green;

    // State transition logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= idle;
        end else begin
            state <= next_state;
        end
    end

    // Next state and counter logic
    always @(*) begin
        case (state)
            idle: begin
                p_red = 0;
                p_yellow = 0;
                p_green = 0;
                next_state = s1_red;
                next_clock = 10;
            end
            
            s1_red: begin
                p_red = 1;
                p_yellow = 0;
                p_green = 0;
                if (clock == 0) begin
                    next_state = s3_green;
                    next_clock = 60;
                end else begin
                    next_state = s1_red;
                    next_clock = clock - 1;
                end
            end
            
            s2_yellow: begin
                p_red = 0;
                p_yellow = 1;
                p_green = 0;
                if (clock == 0) begin
                    next_state = s1_red;
                    next_clock = 10;
                end else begin
                    next_state = s2_yellow;
                    next_clock = clock - 1;
                end
            end
            
            s3_green: begin
                p_red = 0;
                p_yellow = 0;
                p_green = 1;
                if (pass_request && clock > 10) begin
                    next_state = s3_green;
                    next_clock = 10;
                end else if (clock == 0) begin
                    next_state = s2_yellow;
                    next_clock = 5;
                end else begin
                    next_state = s3_green;
                    next_clock = clock - 1;
                end
            end
            
            default: begin
                p_red = 0;
                p_yellow = 0;
                p_green = 0;
                next_state = idle;
                next_clock = 0;
            end
        endcase
    end

    // Counter and output register
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            clock <= 10;
            red <= 0;
            yellow <= 0;
            green <= 0;
        end else begin
            clock <= next_clock;
            red <= p_red;
            yellow <= p_yellow;
            green <= p_green;
        end
    end

endmodule
