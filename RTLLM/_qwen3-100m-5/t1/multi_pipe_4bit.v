module multi_pipe_4bit (
    input clk,
    input rst_n,
    input [3:0] mul_a,
    input [3:0] mul_b,
    output reg [7:0] mul_out
);

parameter size = 4;

wire [7:0] mul_a_ext = {4'b0, mul_a};

genvar i;
generate
    wire [7:0] partial_products [0:size-1];
    for (i = 0; i < size; i = i + 1) begin
        assign partial_products[i] = (mul_b[i]) ? (mul_a_ext << i) : 8'b0;
    end
endgenerate

wire [7:0] sum_partial;
assign sum_partial = partial_products[0] + partial_products[1] + partial_products[2] + partial_products[3];

reg [7:0] reg1;
reg [7:0] reg2;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        reg1 <= 8'b0;
        reg2 <= 8'b0;
        mul_out <= 8'b0;
    end else begin
        reg1 <= sum_partial;
        reg2 <= reg1;
        mul_out <= reg2;
    end
end

endmodule
