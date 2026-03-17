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

reg [7:0] stored_dividend;
reg [7:0] stored_divisor;
reg [15:0] sr;
reg [4:0] cnt;
reg start_cnt;

wire [15:0] extended_divisor;
wire [16:0] add_result;
wire carry_out;

assign extended_divisor = {8'b0, stored_divisor};
assign add_result = {1'b0, sr} - {1'b0, extended_divisor};
assign carry_out = add_result[16];

always @(posedge clk) begin
    if (rst) begin
        res_valid <= 1'b0;
        stored_dividend <= 8'b0;
        stored_divisor <= 8'b0;
        sr <= 16'b0;
        cnt <= 5'd0;
        start_cnt <= 1'b0;
    end else begin
        if (opn_valid && !res_valid) begin
            if (sign) begin
                if (dividend[7]) begin
                    stored_dividend <= ~dividend + 1;
                end else begin
                    stored_dividend <= dividend;
                end
                if (divisor[7]) begin
                    stored_divisor <= ~divisor + 1;
                end else begin
                    stored_divisor <= divisor;
                end
            end else begin
                stored_dividend <= dividend;
                stored_divisor <= divisor;
            end
            sr <= {7'b0, stored_dividend << 1};
            cnt <= 5'd1;
            start_cnt <= 1'b1;
            res_valid <= 1'b0;
        end else if (start_cnt) begin
            if (cnt < 9) begin
                if (carry_out) begin
                    sr <= (add_result[15:0] << 1) | 1;
                end else begin
                    sr <= (sr << 1) | 0;
                end
                cnt <= cnt + 1;
            end else begin
                start_cnt <= 1'b0;
                res_valid <= 1'b1;
                result <= {sr[15:8], sr[7:0]};
            end
        end else if (res_valid) begin
            if (!opn_valid) begin
                res_valid <= 1'b0;
            end
        end
    end
end

endmodule
