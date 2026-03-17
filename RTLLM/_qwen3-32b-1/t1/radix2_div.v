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

reg [15:0] SR;
reg [3:0] cnt;
reg start_cnt;
reg [7:0] divisor_abs;
reg [7:0] dividend_abs;
reg sign_dividend;
reg sign_divisor;
reg [7:0] quotient;
reg [7:0] remainder;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        SR <= 16'b0;
        cnt <= 4'd0;
        start_cnt <= 1'b0;
        res_valid <= 1'b0;
        divisor_abs <= 8'b0;
        dividend_abs <= 8'b0;
        sign_dividend <= 1'b0;
        sign_divisor <= 1'b0;
        quotient <= 8'b0;
        remainder <= 8'b0;
    end else begin
        if (opn_valid && !res_valid) begin
            if (sign) begin
                sign_dividend = dividend[7];
                sign_divisor = divisor[7];
                dividend_abs = (dividend[7]) ? ~dividend + 1 : dividend;
                divisor_abs = (divisor[7]) ? ~divisor + 1 : divisor;
            end else begin
                sign_dividend = 1'b0;
                sign_divisor = 1'b0;
                dividend_abs = dividend;
                divisor_abs = divisor;
            end
            SR <= {dividend_abs << 1, 7'b0};
            cnt <= 4'd1;
            start_cnt <= 1'b1;
            res_valid <= 1'b0;
        end else if (start_cnt) begin
            if (cnt == 8'd8) begin
                start_cnt <= 1'b0;
                cnt <= 4'd0;
                remainder = SR[15:8];
                quotient = SR[7:0];
                if (sign) begin
                    if (sign_dividend ^ sign_divisor) quotient = -quotient;
                    if (sign_dividend) remainder = -remainder;
                end
                result <= {remainder, quotient};
                res_valid <= 1'b1;
            end else begin
                cnt <= cnt + 1;
                wire [7:0] divisor_abs_16 = {8'b0, divisor_abs};
                wire [16:0] temp_sub = {SR, 1'b0} - {divisor_abs_16, 1'b0};
                wire carry_out = temp_sub[16];
                SR <= {SR[15:1], carry_out};
            end
        end else if (res_valid) begin
            res_valid <= 1'b0;
        end
    end
end

endmodule
