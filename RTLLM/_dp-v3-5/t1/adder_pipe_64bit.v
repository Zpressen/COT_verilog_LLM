module adder_pipe_64bit (
    input clk,
    input rst_n,
    input i_en,
    input [63:0] adda,
    input [63:0] addb,
    output reg [64:0] result,
    output reg o_en
);

    // Pipeline stage 1 (bits 15:0)
    reg [15:0] a1, b1;
    reg [16:0] sum1;
    reg en1;

    // Pipeline stage 2 (bits 31:16)
    reg [15:0] a2, b2;
    reg [32:0] sum2;
    reg en2;

    // Pipeline stage 3 (bits 47:32)
    reg [15:0] a3, b3;
    reg [48:0] sum3;
    reg en3;

    // Pipeline stage 4 (bits 63:48)
    reg [15:0] a4, b4;
    reg en4;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset all pipeline registers
            a1 <= 16'b0;
            b1 <= 16'b0;
            sum1 <= 17'b0;
            en1 <= 1'b0;
            
            a2 <= 16'b0;
            b2 <= 16'b0;
            sum2 <= 33'b0;
            en2 <= 1'b0;
            
            a3 <= 16'b0;
            b3 <= 16'b0;
            sum3 <= 49'b0;
            en3 <= 1'b0;
            
            a4 <= 16'b0;
            b4 <= 16'b0;
            en4 <= 1'b0;
            
            result <= 65'b0;
            o_en <= 1'b0;
        end else begin
            // Pipeline stage 1
            en1 <= i_en;
            if (i_en) begin
                a1 <= adda[15:0];
                b1 <= addb[15:0];
                sum1 <= {1'b0, a1} + {1'b0, b1};
            end

            // Pipeline stage 2
            en2 <= en1;
            if (en1) begin
                a2 <= adda[31:16];
                b2 <= addb[31:16];
                sum2 <= {sum1[16], a2} + {sum1[16], b2} + sum1[16];
            end

            // Pipeline stage 3
            en3 <= en2;
            if (en2) begin
                a3 <= adda[47:32];
                b3 <= addb[47:32];
                sum3 <= {sum2[32], a3} + {sum2[32], b3} + sum2[32];
            end

            // Pipeline stage 4
            en4 <= en3;
            if (en3) begin
                a4 <= adda[63:48];
                b4 <= addb[63:48];
                // Final result computation
                result <= {1'b0, sum3[48], a4} + {1'b0, sum3[48], b4} + sum3[48];
                result[48:0] <= sum3[48:0];
                o_en <= en4;
            end else begin
                o_en <= 1'b0;
            end
        end
    end

endmodule
