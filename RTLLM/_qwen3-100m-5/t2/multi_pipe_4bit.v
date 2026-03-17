module multi_pipe_4bit (
    input clk,
    input rst_n,
    input [3:0] mul_a,
    input [3:0] mul_b,
    output reg [7:0] mul_out
);

parameter size = 4;

wire [7:0] mul_a_8 = {4'b0, mul_a};
wire [7:0] mul_b_8 = {4'b0, mul_b};

wire [7:0] partial_product [0:3];
genvar i;
generate
    for (i=0; i<size; i=i+1) begin
        assign partial_product[i] = (mul_b[i]) ? (mul_a_8 << i) : 8'b0;
    end
endgenerate

reg [7:0] reg1;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        reg1 <= 8'b0;
        mul_out <= 8'b0;
    end else begin
        reg1 <= partial_product[0] + partial_product[1];
        mul_out <= reg1 + partial_product[2] + partial_product[3];
    end
end

endmodule
