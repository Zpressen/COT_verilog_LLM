module multi_pipe_4bit (
    input clk,
    input rst_n,
    input [3:0] mul_a,
    input [3:0] mul_b,
    output reg [7:0] mul_out
);

    parameter size = 4;
    wire [7:0] a_ext = {4'b0, mul_a};
    wire [7:0] b_ext = {4'b0, mul_b};
    
    // Partial products
    wire [7:0] pp [0:3];
    
    genvar i;
    generate
        for (i = 0; i < size; i = i + 1) begin : pp_gen
            assign pp[i] = b_ext[i] ? (a_ext << i) : 8'b0;
        end
    endgenerate
    
    // Pipeline stage 1 registers
    reg [8:0] sum_stage1_0;
    reg [8:0] sum_stage1_1;
    
    // Pipeline stage 2 register
    reg [8:0] sum_stage2;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sum_stage1_0 <= 9'b0;
            sum_stage1_1 <= 9'b0;
            sum_stage2 <= 9'b0;
            mul_out <= 8'b0;
        end
        else begin
            // Stage 1: Add partial products 0+1 and 2+3
            sum_stage1_0 <= pp[0] + pp[1];
            sum_stage1_1 <= pp[2] + pp[3];
            
            // Stage 2: Add results from stage 1
            sum_stage2 <= sum_stage1_0 + sum_stage1_1;
            
            // Final output
            mul_out <= sum_stage2[7:0];
        end
    end

endmodule
