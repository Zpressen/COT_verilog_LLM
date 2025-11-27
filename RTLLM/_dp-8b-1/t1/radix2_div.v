module radix2_div (
    input wire clk,
    input wire rst,
    input wire sign,
    input wire [7:0] dividend,
    input wire [7:0] divisor,
    input wire opn_valid,
    output reg res_valid,
    output reg [15:0] result
);

    // Internal registers
    reg [15:0] SR;          // Shift register (8-bit remainder + 8-bit quotient)
    reg [7:0] NEG_DIVISOR;  // Negative of absolute divisor
    reg [3:0] cnt;          // Counter (needs 4 bits to count to 8)
    reg start_cnt;          // Flag to start counting
    
    // Temporary variables for absolute values
    wire [7:0] abs_dividend;
    wire [7:0] abs_divisor;
    
    // Compute absolute values for signed operations
    assign abs_dividend = (sign & dividend[7]) ? -dividend : dividend;
    assign abs_divisor = (sign & divisor[7]) ? -divisor : divisor;
    
    // Subtraction result and carry out
    wire [8:0] sub_result;
    wire carry_out;
    
    assign sub_result = {1'b0, SR[14:7]} + {1'b0, NEG_DIVISOR};
    assign carry_out = ~sub_result[8];  // Carry out is inverted because we subtracted
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // Reset all registers
            SR <= 16'b0;
            NEG_DIVISOR <= 8'b0;
            cnt <= 4'b0;
            start_cnt <= 1'b0;
            res_valid <= 1'b0;
            result <= 16'b0;
        end
        else begin
            if (opn_valid && !res_valid && !start_cnt) begin
                // Operation start
                SR <= {8'b0, abs_dividend} << 1;
                NEG_DIVISOR <= -abs_divisor;
                cnt <= 4'b1;
                start_cnt <= 1'b1;
                res_valid <= 1'b0;
            end
            else if (start_cnt) begin
                if (cnt[3]) begin  // cnt == 8 (1000 in binary)
                    // Division complete
                    start_cnt <= 1'b0;
                    cnt <= 4'b0;
                    
                    // Handle signed results
                    if (sign) begin
                        // Quotient sign
                        reg quotient_sign;
                        quotient_sign = dividend[7] ^ divisor[7];
                        
                        // Remainder sign (same as dividend)
                        reg remainder_sign;
                        remainder_sign = dividend[7];
                        
                        // Final result assembly
                        result <= {remainder_sign ? -SR[15:8] : SR[15:8], 
                                   quotient_sign ? -SR[7:0] : SR[7:0]};
                    end
                    else begin
                        // Unsigned result
                        result <= {SR[15:8], SR[7:0]};
                    end
                    
                    res_valid <= 1'b1;
                end
                else begin
                    // Division step
                    cnt <= cnt + 1;
                    
                    // Update shift register based on carry out
                    if (carry_out) begin
                        SR <= {SR[14:0], 1'b1};
                    end
                    else begin
                        SR <= {SR[14:0], 1'b0};
                    end
                    
                    // Restore value if subtraction was negative
                    if (!carry_out) begin
                        SR[15:8] <= sub_result[7:0];
                    end
                end
            end
            else if (res_valid && opn_valid) begin
                // Result has been consumed, ready for new operation
                res_valid <= 1'b0;
            end
        end
    end

endmodule
