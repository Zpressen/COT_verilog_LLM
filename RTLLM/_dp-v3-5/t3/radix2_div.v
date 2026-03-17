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

    reg [15:0] SR;          // Shift register (remainder + quotient)
    reg [7:0] NEG_DIVISOR;  // Negative of divisor
    reg [3:0] cnt;          // Counter (0-8)
    reg start_cnt;          // Operation in progress flag
    
    // Absolute value calculation for signed numbers
    wire [7:0] abs_dividend = (sign & dividend[7]) ? -dividend : dividend;
    wire [7:0] abs_divisor = (sign & divisor[7]) ? -divisor : divisor;
    
    // Temporary signals for division operation
    wire [8:0] sub_result = {SR[14:7], SR[15]} + {1'b0, NEG_DIVISOR};
    wire carry_out = sub_result[8];
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            SR <= 16'b0;
            NEG_DIVISOR <= 8'b0;
            cnt <= 4'b0;
            start_cnt <= 1'b0;
            res_valid <= 1'b0;
            result <= 16'b0;
        end else begin
            // Capture inputs when valid and not busy
            if (opn_valid && !res_valid && !start_cnt) begin
                SR <= {8'b0, abs_dividend} << 1;
                NEG_DIVISOR <= -abs_divisor;
                cnt <= 4'b1;
                start_cnt <= 1'b1;
                res_valid <= 1'b0;
            end
            
            // Division operation in progress
            if (start_cnt) begin
                if (cnt[3]) begin  // cnt == 8
                    // Final result handling
                    if (sign) begin
                        // Adjust signs for signed division
                        result[15:8] <= (dividend[7] ^ divisor[7]) ? -SR[14:7] : SR[14:7];
                        result[7:0] <= (dividend[7] ^ divisor[7]) ? -SR[7:0] : SR[7:0];
                    end else begin
                        result[15:8] <= SR[14:7];
                        result[7:0] <= SR[7:0];
                    end
                    
                    res_valid <= 1'b1;
                    start_cnt <= 1'b0;
                    cnt <= 4'b0;
                end else begin
                    // Shift and subtract step
                    SR <= {sub_result[7:0], SR[6:0], ~carry_out};
                    cnt <= cnt + 1;
                end
            end
            
            // Clear valid flag when result is consumed
            if (res_valid && opn_valid) begin
                res_valid <= 1'b0;
            end
        end
    end

endmodule
