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
    reg [2:0] en_pipeline;
    reg [7:0] a_pipeline [2:0];
    reg [7:0] b_pipeline [2:0];
    
    // Partial products
    wire [15:0] pp [7:0];
    
    // Intermediate sums
    reg [15:0] sum_stage1_0, sum_stage1_1, sum_stage1_2;
    reg [15:0] sum_stage2_0, sum_stage2_1;
    reg [15:0] sum_stage3;
    
    // Generate partial products
    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : pp_gen
            assign pp[i] = b_pipeline[0][i] ? (a_pipeline[0] << i) : 16'b0;
        end
    endgenerate
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset all pipeline registers
            en_pipeline <= 3'b0;
            a_pipeline[0] <= 8'b0;
            a_pipeline[1] <= 8'b0;
            a_pipeline[2] <= 8'b0;
            b_pipeline[0] <= 8'b0;
            b_pipeline[1] <= 8'b0;
            b_pipeline[2] <= 8'b0;
            
            // Reset intermediate sums
            sum_stage1_0 <= 16'b0;
            sum_stage1_1 <= 16'b0;
            sum_stage1_2 <= 16'b0;
            sum_stage2_0 <= 16'b0;
            sum_stage2_1 <= 16'b0;
            sum_stage3 <= 16'b0;
            
            // Reset outputs
            mul_en_out <= 1'b0;
            mul_out <= 16'b0;
        end
        else begin
            // Stage 1: Register inputs
            en_pipeline[0] <= mul_en_in;
            if (mul_en_in) begin
                a_pipeline[0] <= mul_a;
                b_pipeline[0] <= mul_b;
            end
            
            // Stage 2: First level of additions
            en_pipeline[1] <= en_pipeline[0];
            a_pipeline[1] <= a_pipeline[0];
            b_pipeline[1] <= b_pipeline[0];
            
            sum_stage1_0 <= pp[0] + pp[1];
            sum_stage1_1 <= pp[2] + pp[3];
            sum_stage1_2 <= pp[4] + pp[5];
            
            // Stage 3: Second level of additions
            en_pipeline[2] <= en_pipeline[1];
            a_pipeline[2] <= a_pipeline[1];
            b_pipeline[2] <= b_pipeline[1];
            
            sum_stage2_0 <= sum_stage1_0 + sum_stage1_1;
            sum_stage2_1 <= sum_stage1_2 + pp[6];
            
            // Stage 4: Final addition and output
            mul_en_out <= en_pipeline[2];
            sum_stage3 <= sum_stage2_0 + sum_stage2_1 + pp[7];
            
            if (en_pipeline[2])
                mul_out <= sum_stage3;
            else
                mul_out <= 16'b0;
        end
    end

endmodule
