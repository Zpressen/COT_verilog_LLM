module multi_pipe_4bit (
    input clk,
    input rst_n,
    input [3:0] mul_a,
    input [3:0] mul_b,
    output reg [7:0] mul_out
);

parameter size = 4;

wire [7:0] mul_a_ext = {4'b0, mul_a};
wire [7:0] mul_b_ext = {4'b0, mul_b};

wire [7:0] pp [0:size-1];

genvar i;
generate
for (i=0; i<size; i=i+1) begin : gen_pp
    assign pp[i] = (mul_b[i]) ? (mul_a_ext << i) : 8'b0;
end
endgenerate

reg [7:0] stage1;
reg [7:0] stage2;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        stage1 <= 8'b0;
        stage2 <= 8'b0;
    end else begin
        stage1 <= pp[0] + pp[1];
        stage2 <= pp[2] + pp[3];
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        mul_out <= 8'b0;
    else
        mul_out <= stage1 + stage2;
end

endmodule
