module multi_pipe_8bit (
    input clk,
    input rst_n,
    input mul_en_in,
    input [7:0] mul_a,
    input [7:0] mul_b,
    output reg mul_en_out,
    output reg [15:0] mul_out
);

    // Pipeline registers for enable signal
    reg [3:0] enable_pipe;

    // Input registers
    reg [7:0] mul_a_reg;
    reg [7:0] mul_b_reg;

    // Stage 1: Partial products
    reg [7:0] pp0, pp1, pp2, pp3, pp4, pp5, pp6, pp7;

    // Stage 2: First level sums
    reg [8:0] sum01, sum23, sum45, sum67;

    // Stage 3: Second level sums
    reg [9:0] sum0123, sum4567;

    // Stage 4: Final sum
    reg [15:0] final_sum;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset all registers
            enable_pipe <= 4'b0;
            mul_a_reg <= 8'b0;
            mul_b_reg <= 8'b0;
            pp0 <= 8'b0;
            pp1 <= 8'b0;
            pp2 <= 8'b0;
            pp3 <= 8'b0;
            pp4 <= 8'b0;
            pp5 <= 8'b0;
            pp6 <= 8'b0;
            pp7 <= 8'b0;
            sum01 <= 9'b0;
            sum23 <= 9'b0;
            sum45 <= 9'b0;
            sum67 <= 9'b0;
            sum0123 <= 10'b0;
            sum4567 <= 10'b0;
            final_sum <= 16'b0;
            mul_out <= 16'b0;
            mul_en_out <= 1'b0;
        end
        else begin
            // Pipeline the enable signal
            enable_pipe <= {enable_pipe[2:0], mul_en_in};

            // Stage 0: Register inputs
            if (mul_en_in) begin
                mul_a_reg <= mul_a;
                mul_b_reg <= mul_b;
            end

            // Stage 1: Generate partial products (bitwise AND with shifted multiplicand)
            if (enable_pipe[0]) begin
                pp0 <= mul_b_reg[0] ? mul_a_reg : 8'b0;
                pp1 <= mul_b_reg[1] ? {mul_a_reg[6:0], 1'b0} : 8'b0;
                pp2 <= mul_b_reg[2] ? {mul_a_reg[5:0], 2'b0} : 8'b0;
                pp3 <= mul_b_reg[3] ? {mul_a_reg[4:0], 3'b0} : 8'b0;
                pp4 <= mul_b_reg[4] ? {mul_a_reg[3:0], 4'b0} : 8'b0;
                pp5 <= mul_b_reg[5] ? {mul_a_reg[2:0], 5'b0} : 8'b0;
                pp6 <= mul_b_reg[6] ? {mul_a_reg[1:0], 6'b0} : 8'b0;
                pp7 <= mul_b_reg[7] ? {mul_a_reg[0], 7'b0} : 8'b0;
            end

            // Stage 2: First level additions
            if (enable_pipe[1]) begin
                sum01 <= {1'b0, pp0} + {1'b0, pp1};
                sum23 <= {1'b0, pp2} + {1'b0, pp3};
                sum45 <= {1'b0, pp4} + {1'b0, pp5};
                sum67 <= {1'b0, pp6} + {1'b0, pp7};
            end

            // Stage 3: Second level additions
            if (enable_pipe[2]) begin
                sum0123 <= {1'b0, sum01} + {1'b0, sum23};
                sum4567 <= {1'b0, sum45} + {1'b0, sum67};
            end

            // Stage 4: Final addition
            if (enable_pipe[3]) begin
                final_sum <= {6'b0, sum0123} + {sum4567, 6'b0};
            end

            // Output assignment
            mul_en_out <= enable_pipe[3];
            mul_out <= enable_pipe[3] ? final_sum : 16'b0;
        end
    end

endmodule
