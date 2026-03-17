module radix2_div #(
    parameter WIDTH = 8
)(
    input wire clk,
    input wire rst,
    input wire sign,
    input wire [WIDTH-1:0] dividend,
    input wire [WIDTH-1:0] divisor,
    input wire opn_valid,
    output reg res_valid,
    output reg [2*WIDTH-1:0] result
);

// Internal registers
reg [WIDTH-1:0] dividend_abs;
reg [WIDTH-1:0] divisor_abs;
reg sign_dividend;
reg sign_divisor;
reg [2*WIDTH-1:0] sr;
reg [3:0] cnt;
reg start_cnt;
reg busy;

// Combinational logic for sr_next
wire [WIDTH-1:0] sr_upper_shifted = (sr << 1)[2*WIDTH-1:WIDTH];
wire [2*WIDTH-1:0] sr_next;

always @* begin
    sr_next = sr << 1;
    if (sr_upper_shifted >= divisor_abs) begin
        sr_next[2*WIDTH-1:WIDTH] = sr_upper_shifted - divisor_abs;
        sr_next[0] = 1'b1;
    end else begin
        sr_next[0] = 1'b0;
    end
end

// Sequential logic
always @(posedge clk or negedge rst) begin
    if (!rst) begin
        dividend_abs <= {WIDTH{1'b0}};
        divisor_abs <= {WIDTH{1'b0}};
        sign_dividend <= 1'b0;
        sign_divisor <= 1'b0;
        sr <= {2*WIDTH{1'b0}};
        cnt <= 4'd0;
        start_cnt <= 1'b0;
        busy <= 1'b0;
        res_valid <= 1'b0;
        result <= {2*WIDTH{1'b0}};
    end else begin
        res_valid <= 1'b0;
        if (opn_valid && !busy) begin
            // Capture inputs
            dividend_abs <= (sign) ? ((dividend[WIDTH-1]) ? -dividend : dividend) : dividend;
            divisor_abs <= (sign) ? ((divisor[WIDTH-1]) ? -divisor : divisor) : divisor;
            sign_dividend <= sign & dividend[WIDTH-1];
            sign_divisor <= sign & divisor[WIDTH-1];
            sr <= {dividend_abs << 1};
            cnt <= 4'd1;
            start_cnt <= 1'b1;
            busy <= 1'b1;
        end else if (start_cnt) begin
            cnt <= cnt + 1;
            sr <= sr_next;
            if (cnt == (WIDTH)) begin
                start_cnt <= 1'b0;
                busy <= 1'b0;
                // Compute result based on sign
                result <= {
                    (sign) ? ( (sign_dividend) ? -sr[2*WIDTH-1:WIDTH] : sr[2*WIDTH-1:WIDTH] ) : sr[2*WIDTH-1:WIDTH],
                    (sign) ? ( (sign_dividend ^ sign_divisor) ? -sr[WIDTH-1:0] : sr[WIDTH-1:0] ) : sr[WIDTH-1:0]
                };
                res_valid <= 1'b1;
            end
        end
    end
end

endmodule
