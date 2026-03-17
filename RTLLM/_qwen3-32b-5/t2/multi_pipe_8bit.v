module multi_pipe_8bit (
    input clk,
    input rst_n,
    input mul_en_in,
    input [7:0] mul_a,
    input [7:0] mul_b,
    output reg mul_en_out,
    output reg [15:0] mul_out
);

reg [7:0] mul_en_out_reg;
reg [7:0] mul_a_reg;
reg [7:0] mul_b_reg;
reg [15:0] sum_reg;

wire [15:0] partial_products [0:7];

genvar i;
generate
    for (i=0; i<8; i=i+1) begin: gen_partial
        assign partial_products[i] = (mul_b_reg[i]) ? (mul_a_reg << i) : 16'b0;
    end
endgenerate

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        mul_en_out_reg <= 8'b0;
        mul_a_reg <= 8'b0;
        mul_b_reg <= 8'b0;
        sum_reg <= 16'b0;
        mul_out <= 16'b0;
    end else begin
        if (mul_en_in) begin
            mul_a_reg <= mul_a;
            mul_b_reg <= mul_b;
        end
        mul_en_out_reg <= {mul_en_out_reg[6:0], mul_en_in};

        case (mul_en_out_reg)
            8'h01: sum_reg <= sum_reg + partial_products[0];
            8'h02: sum_reg <= sum_reg + partial_products[1];
            8'h04: sum_reg <= sum_reg + partial_products[2];
            8'h08: sum_reg <= sum_reg + partial_products[3];
            8'h10: sum_reg <= sum_reg + partial_products[4];
            8'h20: sum_reg <= sum_reg + partial_products[5];
            8'h40: sum_reg <= sum_reg + partial_products[6];
            8'h80: sum_reg <= sum_reg + partial_products[7];
            default: sum_reg <= sum_reg;
        endcase

        if (mul_en_out_reg[7]) begin
            mul_out <= sum_reg;
        end else begin
            mul_out <= 16'b0;
        end
    end
end

assign mul_en_out = mul_en_out_reg[7];

endmodule
