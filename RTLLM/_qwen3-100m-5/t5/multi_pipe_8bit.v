module multi_pipe_8bit (
    input clk,
    input rst_n,
    input mul_en_in,
    input [7:0] mul_a,
    input [7:0] mul_b,
    output reg mul_en_out,
    output reg [15:0] mul_out
);

reg [7:0] mul_a_reg, mul_b_reg;
reg [2:0] mul_en_out_reg;
reg [15:0] mul_out_reg;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        mul_a_reg <= 8'b0;
        mul_b_reg <= 8'b0;
        mul_en_out_reg <= 3'b0;
        mul_out_reg <= 16'b0;
    end else begin
        if (mul_en_in) begin
            mul_a_reg <= mul_a;
            mul_b_reg <= mul_b;
            mul_out_reg <= mul_a_reg * mul_b_reg;
        end
        mul_en_out_reg <= {mul_en_out_reg[1:0], mul_en_in};
    end
end

assign mul_en_out = mul_en_out_reg[2];
assign mul_out = mul_en_out ? mul_out_reg : 16'b0;

endmodule
