module radix2_div (
    input  wire                    clk,
    input  wire                    rst,
    input  wire                    sign,
    input  wire [7:0]              dividend,
    input  wire [7:0]              divisor,
    input  wire                    opn_valid,
    output reg                     res_valid,
    output reg [15:0]              result
);

    reg [7:0]      dividend_abs_reg;
    reg [7:0]      divisor_abs_reg;
    reg            dividend_sign_reg;
    reg            divisor_sign_reg;
    reg [15:0]     sr;
    reg [3:0]      cnt;
    reg            start_cnt;

    wire [7:0]     upper_shifted;
    wire [15:0]    sr_shifted;
    wire [15:0]    sr_next;

    // Combinational logic for sr_next
    always @* begin
        sr_shifted = sr << 1;
        upper_shifted = sr_shifted[15:8];
        sr_next = sr_shifted;
        if (start_cnt) begin
            if (upper_shifted >= divisor_abs_reg) begin
                sr_next[15:8] = upper_shifted - divisor_abs_reg;
                sr_next[0] = 1'b1;
            end else begin
                sr_next[15:8] = upper_shifted + divisor_abs_reg;
                sr_next[0] = 1'b0;
            end
        end
    end

    // Sequential logic
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            dividend_abs_reg <= 8'b0;
            divisor_abs_reg <= 8'b0;
            dividend_sign_reg <= 1'b0;
            divisor_sign_reg <= 1'b0;
            sr <= 16'b0;
            cnt <= 4'b0;
            start_cnt <= 1'b0;
            res_valid <= 1'b0;
        end else begin
            if (opn_valid && !res_valid) begin
                if (sign) begin
                    if (dividend[7]) begin
                        dividend_abs_reg <= ~dividend + 1;
                    end else begin
                        dividend_abs_reg <= dividend;
                    end
                    dividend_sign_reg <= dividend[7];
                end else begin
                    dividend_abs_reg <= dividend;
                    dividend_sign_reg <= 1'b0;
                end
                if (sign) begin
                    if (divisor[7]) begin
                        divisor_abs_reg <= ~divisor + 1;
                    end else begin
                        divisor_abs_reg <= divisor;
                    end
                    divisor_sign_reg <= divisor[7];
                end else begin
                    divisor_abs_reg <= divisor;
                    divisor_sign_reg <= 1'b0;
                end
                sr <= {7'b0, {1'b0, dividend_abs_reg} << 1};
                cnt <= 4'b0001;
                start_cnt <= 1'b1;
                res_valid <= 1'b0;
            end else if (start_cnt) begin
                sr <= sr_next;
                cnt <= cnt + 1;
                if (cnt == 8) begin
                    start_cnt <= 1'b0;
                    res_valid <= 1'b1;
                end
            end else begin
                // No change
            end
        end
    end

    // Result calculation with sign adjustment
    wire [7:0] quotient = sr[7:0];
    wire [7:0] remainder = sr[15:8];
    wire quotient_sign = dividend_sign_reg ^ divisor_sign_reg;
    wire remainder_sign = dividend_sign_reg;

    wire [7:0] final_quotient;
    wire [7:0] final_remainder;

    assign final_quotient = sign ? (quotient_sign ? -quotient : quotient) : quotient;
    assign final_remainder = sign ? (remainder_sign ? -remainder : remainder) : remainder;

    assign result = {final_remainder, final_quotient};

endmodule
