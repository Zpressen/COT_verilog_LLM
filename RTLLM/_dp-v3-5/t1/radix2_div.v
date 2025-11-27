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
    reg [8:0] NEG_DIVISOR;  // 9-bit to handle negation
    reg [16:0] SR;          // 17-bit shift register (1 extra for carry)
    reg [3:0] cnt;
    reg start_cnt;
    reg [1:0] sign_result;  // [1]: quotient sign, [0]: remainder sign
    
    wire [8:0] sub_result = SR[16:8] + NEG_DIVISOR;
    wire carry = ~sub_result[8];  // Carry is inverse of sign bit
    
    always @(posedge clk) begin
        if (rst) begin
            res_valid <= 0;
            result <= 0;
            cnt <= 0;
            start_cnt <= 0;
            SR <= 0;
            sign_result <= 0;
        end
        else begin
            // Latch inputs when operation is valid
            if (opn_valid && !res_valid && !start_cnt) begin
                dividend_reg <= dividend;
                divisor_reg <= divisor;
                sign_reg <= sign;
                res_valid <= 0;
                
                // Handle signed division
                if (sign) begin
                    // Calculate absolute values and result signs
                    sign_result[1] <= dividend[7] ^ divisor[7];  // Quotient sign
                    sign_result[0] <= dividend[7];               // Remainder sign
                    
                    // Store absolute values
                    dividend_reg <= dividend[7] ? -dividend : dividend;
                    divisor_reg <= divisor[7] ? -divisor : divisor;
                end
                else begin
                    sign_result <= 0;
                end
                
                // Initialize shift register and negative divisor
                SR <= {9'b0, (sign ? (dividend[7] ? -dividend : dividend) : dividend), 1'b0};
                NEG_DIVISOR <= {1'b0, (sign ? (divisor[7] ? -divisor : divisor) : divisor)} ^ 9'b1_1111_1111 + 1;
                cnt <= 1;
                start_cnt <= 1;
            end
            
            // Division process
            if (start_cnt) begin
                if (cnt[3]) begin  // cnt == 8
                    // Final result
                    start_cnt <= 0;
                    cnt <= 0;
                    
                    // Handle final remainder adjustment if negative
                    if (SR[16]) begin
                        SR[16:8] <= SR[16:8] + {1'b0, divisor_reg};
                    end
                    
                    // Apply signs if signed operation
                    if (sign_reg) begin
                        SR[7:0] <= sign_result[1] ? -SR[7:0] : SR[7:0];  // Quotient
                        SR[16:9] <= sign_result[0] ? -SR[16:9] : SR[16:9]; // Remainder
                    end
                    
                    result <= {SR[16:9], SR[7:0]};
                    res_valid <= 1;
                end
                else begin
                    // Shift and update
                    SR <= carry ? 
                          {sub_result[7:0], SR[7:0], 1'b1} : 
                          {SR[15:0], 1'b0};
                    cnt <= cnt + 1;
                end
            end
            
            // Clear valid when new operation starts
            if (opn_valid) begin
                res_valid <= 0;
            end
        end
    end

endmodule
