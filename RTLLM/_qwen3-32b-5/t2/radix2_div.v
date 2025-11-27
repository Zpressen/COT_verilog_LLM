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
reg [7:0] dividend_abs;
reg [7:0] divisor_abs;
reg [7:0] saved_dividend;
reg [7:0] saved_divisor;

always @(posedge clk) begin
    if (rst) begin
        SR <= 16'd0;
        cnt <= 4'd0;
        start_cnt <= 1'b0;
        res_valid <= 1'b0;
        dividend_abs <= 8'd0;
        divisor_abs <= 8'd0;
    end else begin
        if (opn_valid && !res_valid) begin
            saved_dividend <= dividend;
            saved_divisor <= divisor;
            if (sign) begin
                if (dividend[7]) dividend_abs <= ~dividend + 1;
                else dividend_abs <= dividend;
                if (divisor[7]) divisor_abs <= ~divisor + 1;
                else divisor_abs <= divisor;
            end else begin
                dividend_abs <= dividend;
                divisor_abs <= divisor;
            end
            SR <= {dividend_abs << 1, 8'd0};
            cnt <= 4'd1;
            start_cnt <= 1'b1;
            res_valid <= 1'b0;
        end else if (start_cnt) begin
            if (cnt == 8) begin
                start_cnt <= 1'b0;
                res_valid <= 1'b1;
                result <= {SR[15:8], SR[7:0]};
            end else begin
                reg [15:0] shifted_left;
                reg [15:0] new_SR;
                reg carry_out;
                shifted_left = {SR[15:1], 1'b0};
                if (shifted_left[15:8] >= divisor_abs) begin
                    new_SR = {shifted_left[15:8] - divisor_abs, shifted_left[7:0] << 1 | 1'b1};
                    carry_out = 1'b1;
                end else begin
                    new_SR = {shifted_left[15:8], shifted_left[7:0] << 1 | 1'b0};
                    carry_out = 1'b0;
                end
                SR <= new_SR;
                cnt <= cnt + 1;
            end
        end
    end
end

always @(posedge clk) begin
    if (res_valid) begin
        if (sign) begin
            reg [7:0] q_sign, r_sign;
            q_sign = saved_dividend[7] ^ saved_divisor[7];
            r_sign = saved_dividend[7];
            if (q_sign) result[7:0] = ~result[7:0] + 1;
            if (r_sign) result[15:8] = ~result[15:8] + 1;
        end
    end
end

endmodule
