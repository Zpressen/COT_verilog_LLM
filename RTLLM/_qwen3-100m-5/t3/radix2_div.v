module radix2_div (
    input  wire clk,
    input  wire rst,
    input  wire sign,
    input  wire [7:0] dividend,
    input  wire [7:0] divisor,
    input  wire opn_valid,
    output reg res_valid,
    output reg [15:0] result
);

reg [7:0] dividend_abs;
reg [7:0] divisor_abs;
reg dividend_sign;
reg divisor_sign;
reg [15:0] sr;
reg [3:0] cnt;
reg start_cnt;
reg busy;
reg [15:0] sr_next;
reg [7:0] quotient_abs;
reg [7:0] remainder_abs;
reg remainder_sign;
reg quotient_sign;

// Combinational logic for sr_next
always @* begin
    sr_next = sr << 1;
    if (busy) begin
        if (sr[15:8] >= divisor_abs) begin
            sr_next[15:8] = sr[15:8] - divisor_abs;
            sr_next[0] = 1'b1;
        end else begin
            sr_next[0] = 1'b0;
        end
    end
end

// Sequential logic
always @(posedge clk or negedge rst) begin
    if (!rst) begin
        dividend_abs <= 8'b0;
        divisor_abs <= 8'b0;
        dividend_sign <= 1'b0;
        divisor_sign <= 1'b0;
        sr <= 16'b0;
        cnt <= 4'd0;
        start_cnt <= 1'b0;
        busy <= 1'b0;
        res_valid <= 1'b0;
        result <= 16'b0;
    end else begin
        if (opn_valid && !res_valid) begin
            if (sign) begin
                dividend_sign <= dividend[7];
                divisor_sign <= divisor[7];
                dividend_abs <= (dividend_sign) ? -dividend : dividend;
                divisor_abs <= (divisor_sign) ? -divisor : divisor;
            end else begin
                dividend_abs <= dividend;
                divisor_abs <= divisor;
                dividend_sign <= 1'b0;
                divisor_sign <= 1'b0;
            end
            sr <= {dividend_abs << 1, 7'b0};
            cnt <= 4'd1;
            start_cnt <= 1'b1;
            busy <= 1'b1;
            res_valid <= 1'b0;
        end else if (busy) begin
            sr <= sr_next;
            cnt <= cnt + 1;
            if (cnt == 8) begin
                busy <= 1'b0;
                start_cnt <= 1'b0;
                quotient_abs = sr[7:0];
                remainder_abs = sr[15:8];
                if (sign) begin
                    remainder_sign = dividend_sign;
                    quotient_sign = dividend_sign ^ divisor_sign;
                    if (remainder_sign) remainder_abs = -remainder_abs;
                    if (quotient_sign) quotient_abs = -quotient_abs;
                end
                result <= {remainder_abs, quotient_abs};
                res_valid <= 1'b1;
            end else begin
                res_valid <= 1'b0;
            end
        end
    end
end

endmodule
