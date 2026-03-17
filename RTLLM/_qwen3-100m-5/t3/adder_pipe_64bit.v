module adder_pipe_64bit(
    input clk,
    input rst_n,
    input i_en,
    input [63:0] adda,
    input [63:0] addb,
    output reg [64:0] result,
    output reg o_en
);

wire [31:0] sum1;
wire cout1;
wire [32:0] carry1;

wire [31:0] sum2;
wire cout2;
wire [32:0] carry2;

wire [31:0] sum_32_reg;
wire carry_31_reg;
reg en1, en2;

// Stage 1 adder: lower 32 bits
assign carry1[0] = 1'b0;
genvar i;
generate
    for (i=0; i<32; i=i+1) begin
        assign sum1[i] = adda[i] ^ addb[i] ^ carry1[i];
        assign carry1[i+1] = (adda[i] & addb[i]) | (adda[i] & carry1[i]) | (addb[i] & carry1[i]);
    end
endgenerate
assign cout1 = carry1[32];

// Pipeline registers for stage 1
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        sum_32_reg <= 32'b0;
        carry_31_reg <= 1'b0;
        en1 <= 1'b0;
        en2 <= 1'b0;
        o_en <= 1'b0;
    end else begin
        sum_32_reg <= sum1;
        carry_31_reg <= cout1;
        en1 <= i_en;
        en2 <= en1;
        o_en <= en2;
    end
end

// Stage 2 adder: upper 32 bits
assign carry2[0] = carry_31_reg;
genvar j;
generate
    for (j=0; j<32; j=j+1) begin
        assign sum2[j] = adda[32+j] ^ addb[32+j] ^ carry2[j];
        assign carry2[j+1] = (adda[32+j] & addb[32+j]) | (adda[32+j] & carry2[j]) | (addb[32+j] & carry2[j]);
    end
endgenerate
assign cout2 = carry2[32];

// Assign output result and enable
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        result <= 65'b0;
    end else begin
        result <= {cout2, sum2, sum_32_reg};
    end
end

endmodule
