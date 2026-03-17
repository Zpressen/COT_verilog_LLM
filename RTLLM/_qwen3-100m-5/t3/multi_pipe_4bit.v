module multi_pipe_4bit(
    input clk,
    input rst_n,
    input [3:0] mul_a,
    input [3:0] mul_b,
    output reg [7:0] mul_out
);

parameter size = 4;

wire [7:0] mul_a_ext = {4'b0, mul_a};

genvar i;
wire [7:0] pp [0:size-1];

generate
for (i = 0; i < size; i = i + 1) begin : pp_gen
    assign pp[i] = (mul_b[i]) ? (mul_a_ext << i) : 8'b0;
end
endgenerate

reg [7:0] reg1, reg2;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        reg1 <= 8'b0;
        reg2 <= 8'b0;
    end else begin
        reg1 <= pp[0] + pp[1];
        reg2 <= pp[2] + pp[3];
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        mul_out <= 8'b0;
    end else begin
        mul_out <= reg1 + reg2;
    end
end

endmodule
