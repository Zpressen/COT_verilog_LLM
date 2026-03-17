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
reg dividend_sign;
reg divisor_sign;
reg [15:0] SR; // Shift register: [15:8] = remainder, [7:0] = quotient
reg [7:0] neg_divisor;
reg [3:0] cnt;
reg start_cnt;
wire [8:0] sub_result;
wire carry_out;

// Subtraction result and carry out
assign sub_result = SR[15:8] + neg_divisor;
assign carry_out = sub_result[8];

always @(posedge clk or posedge rst) begin
    if (rst) begin
        res_valid <= 1'b0;
        result <= 16'b0;
        cnt <= 4'b0;
        start_cnt <= 1'b0;
        SR <= 16'b0;
    end else begin
        if (opn_valid && !res_valid) begin
            // Latch inputs and compute signs for signed operations
            dividend_reg <= sign ? (dividend[7] ? -dividend : dividend) : dividend;
            divisor_reg <= sign ? (divisor[7] ? -divisor : divisor) : divisor;
            dividend_sign <= sign & dividend[7];
            divisor_sign <= sign & divisor[7];
            
            // Initialize shift register with dividend left shifted by 1
            SR <= {8'b0, dividend_reg} << 1;
            neg_divisor <= -divisor_reg;
            cnt <= 4'b1;
            start_cnt <= 1'b1;
            res_valid <= 1'b0;
        end
        
        if (start_cnt) begin
            if (cnt[3]) begin // cnt == 8
                // Division complete
                start_cnt <= 1'b0;
                cnt <= 4'b0;
                
                // Final remainder is in upper 8 bits of SR
                // Final quotient is in lower 8 bits of SR
                if (sign) begin
                    // Adjust signs for signed division
                    SR[15:8] <= (dividend_sign != divisor_sign) ? -SR[7:0] : SR[7:0];
                    SR[7:0] <= dividend_sign ? -SR[15:8] : SR[15:8];
                end
                
                result <= {SR[15:8], SR[7:0]};
                res_valid <= 1'b1;
            end else begin
                // Perform division step
                if (carry_out) begin
                    SR <= {sub_result[7:0], SR[7:1], 1'b1};
                end else begin
                    SR <= {SR[15:8], SR[7:1], 1'b0};
                end
                cnt <= cnt + 1;
            end
        end
        
        // Clear res_valid when opn_valid is asserted
        if (opn_valid) begin
            res_valid <= 1'b0;
        end
    end
end

endmodule
