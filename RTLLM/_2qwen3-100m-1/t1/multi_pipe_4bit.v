module multi_pipe_4bit #(
    parameter size = 4
)(
    input clk,
    input rst_n,
    input [size-1:0] mul_a,
    input [size-1:0] mul_b,
    output reg [2*size-1:0] mul_out
);

wire [2*size-1:0] extended_a = { {size{1'b0}}, mul_a };
wire [2*size-1:0] extended_b = { {size{1'b0}}, mul_b };

genvar i;
wire [2*size-1:0] partial_prod [0:size-1];

generate
    for (i = 0; i < size; i = i + 1) begin : gen_partial
        assign partial_prod[i] = (mul_b[i]) ? (extended_a << i) : 0;
    end
endgenerate

wire [2*size-1:0] sum1 = partial_prod[0] + partial_prod[1];
wire [2*size-1:0] sum2 = partial_prod[2] + partial_prod[3];

reg [2*size-1:0] stage1;
reg [2*size-1:0] stage2;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        stage1 <= 0;
        stage2 <= 0;
        mul_out <= 0;
    end else begin
        stage1 <= sum1;
        stage2 <= sum2;
        mul_out <= stage1 + stage2;
    end
end

endmodule
