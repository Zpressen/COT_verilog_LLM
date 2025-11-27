module multi_pipe_4bit (
    input clk,
    input rst_n,
    input [3:0] mul_a,
    input [3:0] mul_b,
    output reg [7:0] mul_out
);

    parameter size = 4;
    
    // Extended inputs (8 bits)
    wire [7:0] a_ext = {4'b0, mul_a};
    wire [7:0] b_ext = {4'b0, mul_b};
    
    // Partial products generation
    wire [7:0] pp [0:3];
    genvar i;
    generate
        for (i = 0; i < size; i = i + 1) begin : pp_gen
            assign pp[i] = b_ext[i] ? (a_ext << i) : 8'd0;
        end
    endgenerate
    
    // Pipeline stage 1 registers (partial sums)
    reg [7:0] sum0, sum1;
    
    // Pipeline stage 2 register (final sum)
    reg [7:0] sum_final;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset all pipeline registers
            sum0 <= 8'd0;
            sum1 <= 8'd0;
            sum_final <= 8'd0;
            mul_out <= 8'd0;
        end
        else begin
            // Pipeline stage 1: add pp0+pp1 and pp2+pp3
            sum0 <= pp[0] + pp[1];
            sum1 <= pp[2] + pp[3];
            
            // Pipeline stage 2: add intermediate sums
            sum_final <= sum0 + sum1;
            
            // Output stage
            mul_out <= sum_final;
        end
    end

endmodule
