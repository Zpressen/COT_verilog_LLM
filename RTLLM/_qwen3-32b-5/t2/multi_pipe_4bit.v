module multi_pipe_4bit (
    input clk,
    input rst_n,
    input [3:0] mul_a,
    input [3:0] mul_b,
    output reg [7:0] mul_out
);

parameter size = 4;

wire [7:0] extended_a = { {size{1'b0}}, mul_a };
wire [7:0] pp0, pp1, pp2, pp3;

genvar i;
generate
for (i=0; i<size; i=i+1) begin: gen_pp
    if (i == 0) begin
        assign pp0 = (mul_b[i]) ? (extended_a << i) : 8'b0;
    end else if (i == 1) begin
        assign pp1 = (mul_b[i]) ? (extended_a << i) : 8'b0;
    end else if (i == 2) begin
        assign pp2 = (mul_b[i]) ? (extended_a << i) : 8'b0;
    end else if (i == 3) begin
        assign pp3 = (mul_b[i]) ? (extended_a << i) : 8'b0;
    end
end
endgenerate

reg [7:0] reg_stage1;
reg [7:0] reg_stage2;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        reg_stage1 <= 8'b0;
        reg_stage2 <= 8'b0;
    end else begin
        reg_stage1 <= pp0 + pp1;
        reg_stage2 <= pp2 + pp3;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        mul_out <= 8'b0;
    end else begin
        mul_out <= reg_stage1 + reg_stage2;
    end
end

endmodule
