module adder_pipe_64bit (
    input clk,
    input rst_n,
    input i_en,
    input [63:0] adda,
    input [63:0] addb,
    output reg [64:0] result,
    output reg o_en
);

reg stage1_en, stage2_en;
reg [31:0] stage1_a, stage1_b;
reg [31:0] stage2_a, stage2_b;
reg stage2_cin;

wire [32:0] stage1_sum_carry;
wire [32:0] stage2_sum_carry;

assign stage1_sum_carry = {1'b0, stage1_a} + {1'b0, stage1_b} + 1'b0;
assign stage2_sum_carry = {1'b0, stage2_a} + {1'b0, stage2_b} + stage2_cin;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        stage1_en <= 1'b0;
        stage2_en <= 1'b0;
        o_en <= 1'b0;
    end else begin
        stage1_en <= i_en;
        stage2_en <= stage1_en;
        o_en <= stage2_en;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        stage1_a <= 32'b0;
        stage1_b <= 32'b0;
    end else if (i_en) begin
        stage1_a <= adda[31:0];
        stage1_b <= addb[31:0];
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        stage2_a <= 32'b0;
        stage2_b <= 32'b0;
        stage2_cin <= 1'b0;
    end else if (stage1_en) begin
        stage2_a <= adda[63:32];
        stage2_b <= addb[63:32];
        stage2_cin <= stage1_sum_carry[32];
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        result <= 65'b0;
    end else if (o_en) begin
        result <= {stage2_sum_carry[32], stage2_sum_carry[31:0], stage1_sum_carry[31:0]};
    end
end

endmodule
