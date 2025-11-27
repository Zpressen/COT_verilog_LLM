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
    reg [15:0] pp [7:0];  // Partial products
    reg [15:0] stage1_sum [3:0];
    reg [15:0] stage2_sum [1:0];
    reg [15:0] stage3_sum;
    
    // Enable signal pipeline
    reg [3:0] en_pipeline;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset all registers
            mul_a_reg <= 8'b0;
            mul_b_reg <= 8'b0;
            for (integer i = 0; i < 8; i = i + 1) pp[i] <= 16'b0;
            for (integer i = 0; i < 4; i = i + 1) stage1_sum[i] <= 16'b0;
            for (integer i = 0; i < 2; i = i + 1) stage2_sum[i] <= 16'b0;
            stage3_sum <= 16'b0;
            en_pipeline <= 4'b0;
            mul_out <= 16'b0;
            mul_en_out <= 1'b0;
        end
        else begin
            // Pipeline stage 0: Input registration
            if (mul_en_in) begin
                mul_a_reg <= mul_a;
                mul_b_reg <= mul_b;
            end
            
            // Generate partial products (stage 0)
            for (integer i = 0; i < 8; i = i + 1) begin
                pp[i] <= mul_b_reg[i] ? (mul_a_reg << i) : 16'b0;
            end
            
            // Pipeline stage 1: First level addition
            stage1_sum[0] <= pp[0] + pp[1];
            stage1_sum[1] <= pp[2] + pp[3];
            stage1_sum[2] <= pp[4] + pp[5];
            stage1_sum[3] <= pp[6] + pp[7];
            
            // Pipeline stage 2: Second level addition
            stage2_sum[0] <= stage1_sum[0] + stage1_sum[1];
            stage2_sum[1] <= stage1_sum[2] + stage1_sum[3];
            
            // Pipeline stage 3: Final addition
            stage3_sum <= stage2_sum[0] + stage2_sum[1];
            
            // Output stage
            mul_out <= stage3_sum;
            
            // Enable signal pipeline
            en_pipeline <= {en_pipeline[2:0], mul_en_in};
            mul_en_out <= en_pipeline[3];
        end
    end

endmodule
