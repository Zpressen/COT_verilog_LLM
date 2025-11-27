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

reg [7:0] saved_dividend;
reg [7:0] saved_divisor;
reg [7:0] abs_dividend;
reg [7:0] abs_divisor;
reg [15:0] SR;
reg [3:0] cnt;
reg start_cnt;
wire [7:0] NEG_DIVISOR;

assign NEG_DIVISOR = -abs_divisor;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        saved_dividend <= 8'b0;
        saved_divisor <= 8'b0;
        abs_dividend <= 8'b0;
        abs_divisor <= 8'b0;
        SR <= 16'b0;
        cnt <= 4'd0;
        start_cnt <= 1'b0;
        res_valid <= 1'b0;
        result <= 16'b0;
    end else begin
        if (opn_valid && !res_valid) begin
            saved_dividend <= dividend;
            saved_divisor <= divisor;
            if (sign) begin
                if (dividend[7]) begin
                    abs_dividend <= ~dividend + 1;
                end else begin
                    abs_dividend <= dividend;
                end
                if (divisor[7]) begin
                    abs_divisor <= ~divisor + 1;
                end else begin
                    abs_divisor <= divisor;
                end
            end else begin
                abs_dividend <= dividend;
                abs_divisor <= divisor;
            end
            SR <= {7'b0, abs_dividend << 1}; // Initialize SR with dividend_abs shifted left by 1
            cnt <= 4'd1;
            start_cnt <= 1'b1;
            res_valid <= 1'b0;
        end else if (start_cnt) begin
            if (cnt < 8) begin
                SR <= (SR << 1) + {{8{1'b0}}, NEG_DIVISOR}; // 16-bit addition with NEG_DIVISOR
                cnt <= cnt + 1;
            end else begin
                start_cnt <= 1'b0;
                // Apply sign adjustments if needed
                if (sign) begin
                    reg [7:0] q_abs, r_abs;
                    reg q_sign, r_sign;
                    q_abs = SR[7:0];
                    r_abs = SR[15:8];
                    q_sign = (saved_dividend[7] ^ saved_divisor[7]);
                    r_sign = saved_dividend[7];
                    if (q_sign) q_abs = ~q_abs + 1;
                    if (r_sign) r_abs = ~r_abs + 1;
                    result <= {r_abs, q_abs};
                end else begin
                    result <= SR;
                end
                res_valid <= 1'b1;
            end
        end
    end
end

endmodule
