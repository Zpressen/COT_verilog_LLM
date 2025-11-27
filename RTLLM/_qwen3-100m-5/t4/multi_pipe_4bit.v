module multi_pipe_4bit (
    input clk,
    input rst_n,
    input [3:0] mul_a,
    input [3:0] mul_b,
    output reg [7:0] mul_out
);

parameter size = 4;

wire [7:0] extended_a = {4'b0, mul_a};
wire [7:0] extended_b = {4'b0, mul_b};

wire [7:0] pp0 = (mul_b[0]) ? (extended_a << 0) : 8'b0;
wire [7:0] pp1 = (mul_b[1]) ? (extended_a << 1) : 8'b0;
wire [7:0] pp2 = (mul_b[2]) ? (extended_a << 2) : 8'b0;
wire [7:0] pp3 = (mul_b[3]) ? (extended_a << 3) : 8'b0;

wire [7:0] total_product = pp0 + pp1 + pp2 + pp3;

reg [7:0] sum_reg1;
reg [7:0] sum_reg2;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        sum_reg1 <= 8'b0;
        sum_reg2 <= 8'b0;
    end else begin
        sum_reg1 <= total_product;
        sum_reg2 <= sum_reg1;
    end
end

assign mul_out = sum_reg2;

endmodule
