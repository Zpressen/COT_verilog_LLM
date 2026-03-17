module multi_pipe_4bit (
    input clk,
    input rst_n,
    input [3:0] mul_a,
    input [3:0] mul_b,
    output reg [7:0] mul_out
);

parameter size = 4;

// Extended inputs
wire [7:0] ext_a = {4'b0, mul_a};
wire [7:0] ext_b = {4'b0, mul_b};

// Partial products
wire [7:0] pp [0:3];

genvar i;
generate
    for (i = 0; i < size; i = i + 1) begin : pp_gen
        assign pp[i] = ext_b[i] ? (ext_a << i) : 8'd0;
    end
endgenerate

// Pipeline stage 1 registers
reg [7:0] stage1_sum0, stage1_sum1;

// Pipeline stage 2 registers
reg [7:0] stage2_sum;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        stage1_sum0 <= 8'd0;
        stage1_sum1 <= 8'd0;
        stage2_sum <= 8'd0;
        mul_out <= 8'd0;
    end else begin
        // First pipeline stage: sum of first two and last two partial products
        stage1_sum0 <= pp[0] + pp[1];
        stage1_sum1 <= pp[2] + pp[3];
        
        // Second pipeline stage: sum of intermediate results
        stage2_sum <= stage1_sum0 + stage1_sum1;
        
        // Final output
        mul_out <= stage2_sum;
    end
end

endmodule
