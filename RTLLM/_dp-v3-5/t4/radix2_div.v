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
    reg [16:0] SR;          // Shift register (1 extra bit for carry)
    reg [7:0] NEG_DIVISOR;  // Negative of absolute divisor
    reg [3:0] cnt;          // Counter (needs 4 bits for values 0-8)
    reg start_cnt;
    reg dividend_sign;
    reg divisor_sign;

    always @(posedge clk) begin
        if (rst) begin
            res_valid <= 0;
            result <= 0;
            cnt <= 0;
            start_cnt <= 0;
            SR <= 0;
        end else begin
            if (opn_valid && !res_valid) begin
                // Latch inputs and initialize
                dividend_reg <= (sign && dividend[7]) ? -dividend : dividend;
                divisor_reg <= (sign && divisor[7]) ? -divisor : divisor;
                dividend_sign <= sign && dividend[7];
                divisor_sign <= sign && divisor[7];
                
                SR <= {9'b0, dividend_reg} << 1;
                NEG_DIVISOR <= -divisor_reg;
                cnt <= 1;
                start_cnt <= 1;
                res_valid <= 0;
            end

            if (start_cnt) begin
                if (cnt[3]) begin  // cnt == 8
                    // Final adjustment
                    if (SR[16]) begin
                        SR <= SR + {divisor_reg, 8'b0};
                    end
                    
                    // Handle signed results
                    if (sign) begin
                        SR[7:0] <= (dividend_sign ^ divisor_sign) ? -SR[7:0] : SR[7:0];
                        SR[15:8] <= dividend_sign ? -SR[15:8] : SR[15:8];
                    end
                    
                    result <= {SR[15:8], SR[7:0]};
                    res_valid <= 1;
                    start_cnt <= 0;
                end else begin
                    // Perform subtraction
                    if (SR[16]) begin
                        // If previous result was negative, add divisor
                        SR <= (SR + {divisor_reg, 8'b0}) << 1;
                    end else begin
                        // Otherwise subtract divisor
                        SR <= (SR + {NEG_DIVISOR, 8'b0}) << 1;
                    end
                    
                    // Insert carry-out as LSB
                    SR[0] <= ~SR[16];
                    
                    cnt <= cnt + 1;
                end
            end

            // Clear valid when operation starts
            if (opn_valid) begin
                res_valid <= 0;
            end
        end
    end

endmodule
