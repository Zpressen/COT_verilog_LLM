module radix2_div (
    input  wire                 clk,
    input  wire                 rst,
    input  wire                 sign,
    input  wire [7:0]           dividend,
    input  wire [7:0]           divisor,
    input  wire                 opn_valid,
    output reg                  res_valid,
    output reg  [15:0]          result
);

    reg [7:0]      dividend_abs;
    reg [7:0]      divisor_abs;
    reg [15:0]     sr;
    reg [3:0]      cnt;
    reg            start_cnt;
    wire [15:0]    sr_next;

    // Combinational logic to compute sr_next
    always @* begin
        sr_next = sr;
        if (start_cnt) begin
            wire [7:0] remainder_upper = sr[15:8];
            wire [7:0] quotient = sr[7:0];
            wire [8:0] diff = {1'b0, remainder_upper} - {divisor_abs};
            wire ge = diff[8] == 1'b0;

            wire [7:0] new_remainder_upper;
            wire new_quotient_bit;

            if (ge) begin
                new_remainder_upper = (remainder_upper << 1) - divisor_abs;
                new_quotient_bit = 1'b1;
            end else begin
                new_remainder_upper = remainder_upper << 1;
                new_quotient_bit = 1'b0;
            end

            sr_next = {new_remainder_upper, quotient << 1 | new_quotient_bit};
        end
    end

    // Sequential logic
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            sr <= 16'b0;
            cnt <= 4'b0;
            start_cnt <= 1'b0;
            res_valid <= 1'b0;
            result <= 16'b0;
            dividend_abs <= 8'b0;
            divisor_abs <= 8'b0;
        end else begin
            if (opn_valid && !res_valid) begin
                // Compute absolute values
                if (sign) begin
                    dividend_abs = dividend[7] ? (~dividend + 1) : dividend;
                    divisor_abs = divisor[7] ? (~divisor + 1) : divisor;
                end else begin
                    dividend_abs = dividend;
                    divisor_abs = divisor;
                end
                // Initialize SR with dividend_abs shifted left by 1, lower 7 bits zero
                sr <= {dividend_abs << 1, 7'b0};
                cnt <= 4'd1;
                start_cnt <= 1'b1;
                res_valid <= 1'b0;
            end else if (start_cnt) begin
                sr <= sr_next;
                cnt <= cnt + 1;
                if (cnt == 8) begin
                    start_cnt <= 1'b0;
                    res_valid <= 1'b1;
                    result <= sr;
                end
            end else begin
                res_valid <= 1'b0;
            end
        end
    end

endmodule
