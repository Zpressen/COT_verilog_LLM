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

    // Internal registers
    reg [15:0] SR;              // Shift register (16-bit)
    reg [7:0] NEG_DIVISOR;      // Negative of divisor (for subtraction)
    reg [3:0] cnt;              // Iteration counter (0-8)
    reg start_cnt;              // Division process active
    reg [7:0] orig_divisor;     // Original divisor (for sign correction)
    reg [7:0] orig_dividend;    // Original dividend (for sign correction)
    reg result_sign;            // Result sign (for signed division)

    wire [8:0] sub_result;      // 9-bit subtraction result (8-bit + carry)
    wire carry_out;             // Carry from subtraction

    // Subtraction logic
    assign sub_result = {1'b0, SR[15:8]} + {1'b0, NEG_DIVISOR};
    assign carry_out = sub_result[8];

    always @(posedge clk) begin
        if (rst) begin
            // Reset all registers
            SR <= 16'b0;
            NEG_DIVISOR <= 8'b0;
            cnt <= 4'b0;
            start_cnt <= 1'b0;
            res_valid <= 1'b0;
            result <= 16'b0;
            orig_divisor <= 8'b0;
            orig_dividend <= 8'b0;
            result_sign <= 1'b0;
        end else begin
            // Handle new operation request
            if (opn_valid && !res_valid && !start_cnt) begin
                // Store original values for sign correction
                orig_divisor <= divisor;
                orig_dividend <= dividend;
                
                // Calculate absolute values and result sign for signed division
                if (sign) begin
                    result_sign <= dividend[7] ^ divisor[7];
                    SR <= {8'b0, (dividend[7] ? -dividend : dividend)};
                    NEG_DIVISOR <= -(divisor[7] ? -divisor : divisor);
                end else begin
                    result_sign <= 1'b0;
                    SR <= {8'b0, dividend};
                    NEG_DIVISOR <= -divisor;
                end
                
                // Initialize shift register (left shift by 1)
                SR <= SR << 1;
                cnt <= 4'b1;
                start_cnt <= 1'b1;
                res_valid <= 1'b0;
            end
            
            // Division process
            if (start_cnt) begin
                if (cnt[3]) begin  // cnt == 8
                    // Division complete
                    start_cnt <= 1'b0;
                    cnt <= 4'b0;
                    
                    // Final adjustment for remainder
                    if (!carry_out) begin
                        SR[15:8] <= SR[15:8] + (~NEG_DIVISOR + 1);
                    end
                    
                    // Apply sign correction if needed
                    if (sign) begin
                        // Quotient sign
                        SR[7:0] <= result_sign ? -SR[7:0] : SR[7:0];
                        // Remainder sign (same as dividend)
                        SR[15:8] <= orig_dividend[7] ? -SR[15:8] : SR[15:8];
                    end
                    
                    // Prepare output
                    result <= {SR[15:8], SR[7:0]};
                    res_valid <= 1'b1;
                end else begin
                    // Perform one division step
                    cnt <= cnt + 1;
                    
                    if (carry_out) begin
                        // Update SR with subtraction result and shift left
                        SR <= {sub_result[7:0], SR[7:0], 1'b1};
                    end else begin
                        // Just shift left
                        SR <= {SR[14:0], 1'b0};
                    end
                end
            end
            
            // Clear valid when result is consumed
            if (res_valid && opn_valid) begin
                res_valid <= 1'b0;
            end
        end
    end

endmodule
