module multi_pipe_4bit (
    input clk,
    input rst_n,
    input [3:0] mul_a,
    input [3:0] mul_b,
    output reg [7:0] mul_out
);

parameter size = 4;

wire [7:0] extended_mul_a = { {size{1'b0}}, mul_a };

wire [7:0] partial_products [0:size-1];

genvar i;
generate
    for (i=0; i<size; i=i+1) begin
        assign partial_products[i] = (mul_b[i]) ? (extended_mul_a << i) : 8'b0;
    end
endgenerate

wire [7:0] sum1 = partial_products[0] + partial_products[1];
wire [7:0] sum2 = partial_products[2] + partial_products[3];

reg [7:0] stage1, stage2;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        stage1 <= 8'b0;
        stage2 <= 8'b0;
        mul_out <= 8'b0;
    end else begin
        stage1 <= sum1;
        stage2 <= sum2;
        mul_out <= stage1 + stage2;
    end
end

endmodule
