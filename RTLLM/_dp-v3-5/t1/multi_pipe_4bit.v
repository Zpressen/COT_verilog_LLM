module multi_pipe_4bit (
    input clk,
    input rst_n,
    input [3:0] mul_a,
    input [3:0] mul_b,
    output reg [7:0] mul_out
);

    parameter size = 4;
    reg [7:0] extended_a, extended_b;
    reg [7:0] partial_prod [0:3];
    reg [7:0] sum_stage1 [0:1];
    reg [7:0] sum_stage2;

    // Input extension
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            extended_a <= 8'd0;
            extended_b <= 8'd0;
        end else begin
            extended_a <= {4'b0, mul_a};
            extended_b <= {4'b0, mul_b};
        end
    end

    // Partial product generation
    integer i;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < 4; i = i + 1)
                partial_prod[i] <= 8'd0;
        end else begin
            for (i = 0; i < 4; i = i + 1) begin
                if (extended_b[i])
                    partial_prod[i] <= extended_a << i;
                else
                    partial_prod[i] <= 8'd0;
            end
        end
    end

    // First stage addition (PP0+PP1 and PP2+PP3)
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sum_stage1[0] <= 8'd0;
            sum_stage1[1] <= 8'd0;
        end else begin
            sum_stage1[0] <= partial_prod[0] + partial_prod[1];
            sum_stage1[1] <= partial_prod[2] + partial_prod[3];
        end
    end

    // Second stage addition (sum0 + sum1)
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            sum_stage2 <= 8'd0;
        else
            sum_stage2 <= sum_stage1[0] + sum_stage1[1];
    end

    // Final output
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            mul_out <= 8'd0;
        else
            mul_out <= sum_stage2;
    end

endmodule
