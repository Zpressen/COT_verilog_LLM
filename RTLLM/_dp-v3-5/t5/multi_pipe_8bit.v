module multi_pipe_8bit (
    input clk,
    input rst_n,
    input mul_en_in,
    input [7:0] mul_a,
    input [7:0] mul_b,
    output reg mul_en_out,
    output reg [15:0] mul_out
);

    // Pipeline registers
    reg [7:0] mul_a_reg;
    reg [7:0] mul_b_reg;
    reg [7:0] enable_pipe;
    
    // Partial products
    wire [15:0] pp [7:0];
    
    // Intermediate sums
    reg [15:0] sum_stage1 [3:0];
    reg [15:0] sum_stage2 [1:0];
    reg [15:0] sum_final;
    
    // Generate partial products
    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : pp_gen
            assign pp[i] = mul_b_reg[i] ? (mul_a_reg << i) : 16'b0;
        end
    endgenerate
    
    // Pipeline control
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset all pipeline registers
            mul_a_reg <= 8'b0;
            mul_b_reg <= 8'b0;
            enable_pipe <= 8'b0;
            
            // Reset intermediate sums
            sum_stage1[0] <= 16'b0;
            sum_stage1[1] <= 16'b0;
            sum_stage1[2] <= 16'b0;
            sum_stage1[3] <= 16'b0;
            
            sum_stage2[0] <= 16'b0;
            sum_stage2[1] <= 16'b0;
            
            sum_final <= 16'b0;
            
            mul_en_out <= 1'b0;
            mul_out <= 16'b0;
        end
        else begin
            // Input stage
            if (mul_en_in) begin
                mul_a_reg <= mul_a;
                mul_b_reg <= mul_b;
            end
            enable_pipe <= {enable_pipe[6:0], mul_en_in};
            
            // First addition stage (4 additions)
            sum_stage1[0] <= pp[0] + pp[1];
            sum_stage1[1] <= pp[2] + pp[3];
            sum_stage1[2] <= pp[4] + pp[5];
            sum_stage1[3] <= pp[6] + pp[7];
            
            // Second addition stage (2 additions)
            sum_stage2[0] <= sum_stage1[0] + sum_stage1[1];
            sum_stage2[1] <= sum_stage1[2] + sum_stage1[3];
            
            // Final addition stage
            sum_final <= sum_stage2[0] + sum_stage2[1];
            
            // Output stage
            mul_en_out <= enable_pipe[7];
            mul_out <= enable_pipe[7] ? sum_final : 16'b0;
        end
    end

endmodule
