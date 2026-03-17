module multi_pipe_8bit (
    input wire clk,
    input wire rst_n,
    input wire mul_en_in,
    input wire [7:0] mul_a,
    input wire [7:0] mul_b,
    output wire mul_en_out,
    output wire [15:0] mul_out
);

    // Pipeline registers
    reg [7:0] mul_a_reg;
    reg [7:0] mul_b_reg;
    reg [1:0] mul_en_out_reg;
    
    // Partial product generation
    wire [15:0] temp [7:0];
    
    // Partial sum registers
    reg [15:0] sum [3:0];
    
    // Final product register
    reg [15:0] mul_out_reg;
    
    // Generate partial products
    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : pp_gen
            assign temp[i] = mul_b_reg[i] ? (mul_a_reg << i) : 16'b0;
        end
    endgenerate
    
    // Pipeline processing
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset all registers
            mul_a_reg <= 8'b0;
            mul_b_reg <= 8'b0;
            mul_en_out_reg <= 2'b0;
            
            for (integer j = 0; j < 4; j = j + 1) begin
                sum[j] <= 16'b0;
            end
            
            mul_out_reg <= 16'b0;
        end
        else begin
            // Stage 1: Input sampling
            if (mul_en_in) begin
                mul_a_reg <= mul_a;
                mul_b_reg <= mul_b;
            end
            
            // Pipeline the enable signal
            mul_en_out_reg <= {mul_en_out_reg[0], mul_en_in};
            
            // Stage 2: First level of partial sums
            sum[0] <= temp[0] + temp[1];
            sum[1] <= temp[2] + temp[3];
            sum[2] <= temp[4] + temp[5];
            sum[3] <= temp[6] + temp[7];
            
            // Stage 3: Final sum
            mul_out_reg <= sum[0] + sum[1] + sum[2] + sum[3];
        end
    end
    
    // Output assignments
    assign mul_en_out = mul_en_out_reg[1];
    assign mul_out = mul_en_out ? mul_out_reg : 16'b0;

endmodule
