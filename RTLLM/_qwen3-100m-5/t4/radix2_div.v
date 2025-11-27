module radix2_div #(
    parameter WIDTH = 8,
    parameter RESULT_WIDTH = 16
)(
    input  wire clk,
    input  wire rst,
    input  wire sign,
    input  wire [WIDTH-1:0] dividend,
    input  wire [WIDTH-1:0] divisor,
    input  wire opn_valid,
    output reg res_valid,
    output reg [RESULT_WIDTH-1:0] result
);

    // Internal registers
    reg [WIDTH-1:0] saved_dividend;
    reg [WIDTH-1:0] saved_divisor;
    reg [RESULT_WIDTH-1:0] sr;
    reg [3:0] cnt;
    reg start_cnt;
    reg dividend_sign;
    reg divisor_sign;
    wire [RESULT_WIDTH-1:0] neg_divisor;

    // Compute absolute values and signs
    always @* begin
        if (sign) begin
            // Signed operation
            saved_dividend = (dividend[WIDTH-1]) ? -dividend : dividend;
            saved_divisor = (divisor[WIDTH-1]) ? -divisor : divisor;
            dividend_sign = dividend[WIDTH-1];
            divisor_sign = divisor[WIDTH-1];
        end else begin
            // Unsigned operation
            saved_dividend = dividend;
            saved_divisor = divisor;
            dividend_sign = 1'b0;
            divisor_sign = 1'b0;
        end
    end

    // Negated absolute divisor (16-bit)
    assign neg_divisor = {8'hFF, -saved_divisor};

    // Combinational logic for next SR
    wire [RESULT_WIDTH-1:0] sr_next;
    always @* begin
        sr_next = sr;
        if (start_cnt) begin
            reg [RESULT_WIDTH-1:0] sr_upper = sr[RESULT_WIDTH-1:RESULT_WIDTH-WIDTH];
            reg [RESULT_WIDTH-1:0] subtraction_result = sr_upper - neg_divisor;
            reg carry_out = (subtraction_result >= 0) ? 1'b1 : 1'b0;
            reg [RESULT_WIDTH-1:0] sr_next_upper = carry_out ? subtraction_result : sr_upper;
            reg [RESULT_WIDTH-1:0] sr_next_lower = (sr[RESULT_WIDTH-WIDTH-1:0] << 1) | carry_out;
            sr_next = {sr_next_upper, sr_next_lower};
        end
    end

    // Sequential logic
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            saved_dividend <= {WIDTH{1'b0}};
            saved_divisor <= {WIDTH{1'b0}};
            sr <= {RESULT_WIDTH{1'b0}};
            cnt <= 4'd0;
            start_cnt <= 1'b0;
            res_valid <= 1'b0;
            result <= {RESULT_WIDTH{1'b0}};
        end else if (opn_valid && !res_valid) begin
            // Start new operation
            if (sign) begin
                saved_dividend <= (dividend[WIDTH-1]) ? -dividend : dividend;
                saved_divisor <= (divisor[WIDTH-1]) ? -divisor : divisor;
                dividend_sign <= dividend[WIDTH-1];
                divisor_sign <= divisor[WIDTH-1];
            end else begin
                saved_dividend <= dividend;
                saved_divisor <= divisor;
                dividend_sign <= 1'b0;
                divisor_sign <= 1'b0;
            end
            sr <= {saved_dividend << 1, 7'b0}; // Initialize SR with dividend_abs shifted left by one bit
            cnt <= 4'd1;
            start_cnt <= 1'b1;
            res_valid <= 1'b0;
        end else if (start_cnt) begin
            sr <= sr_next;
            if (cnt == 8) begin
                start_cnt <= 1'b0;
                if (sign) begin
                    reg [7:0] quotient = sr[7:0];
                    reg [7:0] remainder = sr[15:8];
                    reg quotient_sign = dividend_sign ^ divisor_sign;
                    reg remainder_sign = dividend_sign;

                    if (quotient_sign) begin
                        quotient = -quotient;
                    end
                    if (remainder_sign) begin
                        remainder = -remainder;
                    end

                    result <= {remainder, quotient};
                end else begin
                    result <= sr;
                end
                res_valid <= 1'b1;
            end else begin
                cnt <= cnt + 1'b1;
            end
        end
    end

endmodule
