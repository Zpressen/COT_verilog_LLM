module multi_pipe_8bit (
    input clk,
    input rst_n,
    input mul_en_in,
    input [7:0] mul_a,
    input [7:0] mul_b,
    output wire mul_en_out,
    output wire [15:0] mul_out
);

reg [2:0] mul_en_out_reg;
reg [7:0] mul_a_reg, mul_b_reg;
reg [15:0] sum_reg, mul_out_reg;

wire [15:0] temp0, temp1, temp2, temp3, temp4, temp5, temp6, temp7;

assign temp0 = (mul_b_reg[0]) ? (mul_a_reg << 0) : 16'b0;
assign temp1 = (mul_b_reg[1]) ? (mul_a_reg << 1) : 16'b0;
assign temp2 = (mul_b_reg[2]) ? (mul_a_reg << 2) : 16'b0;
assign temp3 = (mul_b_reg[3]) ? (mul_a_reg << 3) : 16'b0;
assign temp4 = (mul_b_reg[4]) ? (mul_a_reg << 4) : 16'b0;
assign temp5 = (mul_b_reg[5]) ? (mul_a_reg << 5) : 16'b0;
assign temp6 = (mul_b_reg[6]) ? (mul_a_reg << 6) : 16'b0;
assign temp7 = (mul_b_reg[7]) ? (mul_a_reg << 7) : 16'b0;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        mul_en_out_reg <= 3'b0;
    else
        mul_en_out_reg <= {mul_en_out_reg[1:0], mul_en_in};
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        mul_a_reg <= 8'b0;
        mul_b_reg <= 8'b0;
    end else if (mul_en_in) begin
        mul_a_reg <= mul_a;
        mul_b_reg <= mul_b;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        sum_reg <= 16'b0;
    else if (mul_en_out_reg[1])
        sum_reg <= temp0 + temp1 + temp2 + temp3 + temp4 + temp5 + temp6 + temp7;
    else
        sum_reg <= sum_reg;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        mul_out_reg <= 16'b0;
    else if (mul_en_out_reg[2])
        mul_out_reg <= sum_reg;
    else
        mul_out_reg <= mul_out_reg;
end

assign mul_en_out = mul_en_out_reg[2];
assign mul_out = (mul_en_out) ? mul_out_reg : 16'b0;

endmodule
