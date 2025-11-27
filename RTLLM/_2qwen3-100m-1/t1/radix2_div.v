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

reg [7:0] dividend_abs, divisor_abs;
reg dividend_sign, divisor_sign;
reg [15:0] SR;
reg [3:0] cnt;
reg start_cnt;

reg [8:0] shifted_remainder;
reg [8:0] NEG_DIVISOR_9;
reg [9:0] temp;
reg carry_out;
reg [8:0] new_remainder_upper_8;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        dividend_abs <= 8'b0;
        divisor_abs <= 8'b0;
        dividend_sign <= 1'b0;
        divisor_sign <= 1'b0;
        SR <= 16'b0;
        cnt <= 4'd0;
        start_cnt <= 1'b0;
        res_valid <= 1'b0;
    end else begin
        if (opn_valid && !res_valid) begin
            if (sign) begin
                dividend_abs <= (dividend[7]) ? -dividend : dividend;
                dividend_sign <= dividend[7];
            end else begin
                dividend_abs <= dividend;
                dividend_sign <= 1'b0;
            end
            if (sign) begin
                divisor_abs <= (divisor[7]) ? -divisor : divisor;
                divisor_sign <= divisor[7];
            end else begin
                divisor_abs <= divisor;
                divisor_sign <= 1'b0;
            end
            SR <= {dividend_abs << 1, 7'b0};
            cnt <= 4'd1;
            start_cnt <= 1'b1;
            res_valid <= 1'b0;
        end else if (start_cnt) begin
            if (cnt == 4'd8) begin
                start_cnt <= 1'b0;
                cnt <= 4'd0;
                if (sign) begin
                    reg [7:0] quotient_abs = SR[7:0];
                    reg [7:0] remainder_abs = SR[15:8];
                    reg [7:0] quotient_sign = dividend_sign ^ divisor_sign;
                    reg [7:0] remainder_sign = dividend_sign;
                    if (quotient_sign) quotient_abs = -quotient_abs;
                    if (remainder_sign) remainder_abs = -remainder_abs;
                    result <= {remainder_abs, quotient_abs};
                end else begin
                    result <= SR;
                end
                res_valid <= 1'b1;
            end else begin
                cnt <= cnt + 1;
                shifted_remainder = {SR[15:8] << 1, 1'b0};
                NEG_DIVISOR_9 = {1'b1, -divisor_abs};
                temp = {1'b0, shifted_remainder} + {1'b0, NEG_DIVISOR_9};
                carry_out = temp[9];
                if (carry_out) begin
                    new_remainder_upper_8 = temp[8:0];
                end else begin
                    new_remainder_upper_8 = shifted_remainder;
                end
                SR <= {new_remainder_upper_8[8:1], (SR[7:0] << 1) | carry_out};
            end
        end
    end
end

endmodule
