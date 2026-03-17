module multi_pipe_8bit (
    input clk,
    input rst_n,
    input mul_en_in,
    input [7:0] mul_a,
    input [7:0] mul_b,
    output reg mul_en_out,
    output reg [15:0] mul_out
);

    // Pipeline stage 1 registers
    reg [7:0] a_reg, b_reg;
    reg en_reg1;
    reg [15:0] partial_products [7:0];

    // Pipeline stage 2 registers
    reg en_reg2;
    reg [15:0] sum0, sum1, sum2, sum3;

    // Pipeline stage 3 registers
    reg en_reg3;
    reg [15:0] sum_final;

    // Generate partial products (combinational)
    always @* begin
        if (en_reg1) begin
            for (integer i = 0; i < 8; i = i + 1) begin
                partial_products[i] = b_reg[i] ? {8'b0, a_reg} << i : 16'b0;
            end
        end else begin
            for (integer i = 0; i < 8; i = i + 1) begin
                partial_products[i] = 16'b0;
            end
        end
    end

    // Pipeline stage 1: Register inputs and enable
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            a_reg <= 8'b0;
            b_reg <= 8'b0;
            en_reg1 <= 1'b0;
        end else begin
            if (mul_en_in) begin
                a_reg <= mul_a;
                b_reg <= mul_b;
            end
            en_reg1 <= mul_en_in;
        end
    end

    // Pipeline stage 2: First level of addition
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sum0 <= 16'b0;
            sum1 <= 16'b0;
            sum2 <= 16'b0;
            sum3 <= 16'b0;
            en_reg2 <= 1'b0;
        end else begin
            sum0 <= partial_products[0] + partial_products[1];
            sum1 <= partial_products[2] + partial_products[3];
            sum2 <= partial_products[4] + partial_products[5];
            sum3 <= partial_products[6] + partial_products[7];
            en_reg2 <= en_reg1;
        end
    end

    // Pipeline stage 3: Second level of addition
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sum_final <= 16'b0;
            en_reg3 <= 1'b0;
        end else begin
            sum_final <= (sum0 + sum1) + (sum2 + sum3);
            en_reg3 <= en_reg2;
        end
    end

    // Output stage
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mul_out <= 16'b0;
            mul_en_out <= 1'b0;
        end else begin
            mul_out <= en_reg3 ? sum_final : 16'b0;
            mul_en_out <= en_reg3;
        end
    end

endmodule
