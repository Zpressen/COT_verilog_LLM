module radix2_div (
    input clk,
    input rst,
    input sign,
    input [7:0] dividend,
    input [7:0] divisor,
    input opn_valid,
    output reg res_valid,
    output reg [15:0] result
);

    reg [7:0] dividend_reg;
    reg [7:0] divisor_reg;
    reg sign_reg;
    reg [15:0] SR; // Shift register: [15:8] remainder, [7:0] quotient
    reg [7:0] NEG_DIVISOR;
    reg [3:0] cnt;
    reg start_cnt;
    reg dividend_sign;
    reg divisor_sign;
    reg result_sign;

    wire [8:0] sub_result = {1'b0, SR[15:8]} + {1'b0, NEG_DIVISOR};
    wire carry_out = sub_result[8];

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            dividend_reg <= 8'b0;
            divisor_reg <= 8'b0;
            SR <= 16'b0;
            NEG_DIVISOR <= 8'b0;
            cnt <= 4'b0;
            start_cnt <= 1'b0;
            res_valid <= 1'b0;
            result <= 16'b0;
            sign_reg <= 1'b0;
            dividend_sign <= 1'b0;
            divisor_sign <= 1'b0;
            result_sign <= 1'b0;
        end
        else begin
            if (opn_valid && !res_valid) begin
                // Store inputs and initialize
                dividend_reg <= (sign && dividend[7]) ? -dividend : dividend;
                divisor_reg <= (sign && divisor[7]) ? -divisor : divisor;
                sign_reg <= sign;
                dividend_sign <= sign && dividend[7];
                divisor_sign <= sign && divisor[7];
                result_sign <= dividend_sign ^ divisor_sign;
                
                SR <= {8'b0, (sign && dividend[7]) ? -dividend : dividend} << 1;
                NEG_DIVISOR <= -((sign && divisor[7]) ? -divisor : divisor);
                cnt <= 4'b1;
                start_cnt <= 1'b1;
                res_valid <= 1'b0;
            end
            else if (start_cnt) begin
                if (cnt[3]) begin // cnt == 8
                    // Division complete
                    start_cnt <= 1'b0;
                    cnt <= 4'b0;
                    
                    // Final remainder adjustment
                    if (SR[15]) begin
                        SR[15:8] <= SR[15:8] + divisor_reg;
                    end
                    
                    // Handle signed result
                    if (sign_reg) begin
                        SR[7:0] <= result_sign ? -SR[7:0] : SR[7:0];
                        SR[15:8] <= dividend_sign ? -SR[15:8] : SR[15:8];
                    end
                    
                    result <= {SR[15:8], SR[7:0]};
                    res_valid <= 1'b1;
                end
                else begin
                    // Perform division step
                    cnt <= cnt + 1;
                    
                    if (carry_out) begin
                        SR <= {sub_result[7:0], SR[7:1], 1'b1};
                    end
                    else begin
                        SR <= {SR[15:8], SR[7:1], 1'b0};
                    end
                end
            end
            
            // Clear res_valid when new operation starts
            if (opn_valid) begin
                res_valid <= 1'b0;
            end
        end
    end

endmodule
