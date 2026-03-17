module multi_pipe_4bit #(
    parameter size = 4
) (
    input wire clk,
    input wire rst_n,
    input wire [size-1:0] mul_a,
    input wire [size-1:0] mul_b,
    output reg [2*size-1:0] mul_out
);

    // Extended inputs with size zeros at MSB
    wire [2*size-1:0] ext_a = {{size{1'b0}}, mul_a};
    wire [2*size-1:0] ext_b = {{size{1'b0}}, mul_b};

    // Partial products
    wire [2*size-1:0] pp [size-1:0];

    // Generate partial products
    genvar i;
    generate
        for (i = 0; i < size; i = i + 1) begin : gen_partial_products
            assign pp[i] = ext_b[i] ? (ext_a << i) : 'd0;
        end
    endgenerate

    // First level registers (store intermediate sums)
    reg [2*size-1:0] sum_stage1 [size/2-1:0];

    // Second level registers (store intermediate sums)
    reg [2*size-1:0] sum_stage2;

    // Pipeline stage 1: Add first half of partial products
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (integer j = 0; j < size/2; j = j + 1) begin
                sum_stage1[j] <= 'd0;
            end
        end else begin
            sum_stage1[0] <= pp[0] + pp[1];
            sum_stage1[1] <= pp[2] + pp[3];
        end
    end

    // Pipeline stage 2: Add results from stage 1
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sum_stage2 <= 'd0;
        end else begin
            sum_stage2 <= sum_stage1[0] + sum_stage1[1];
        end
    end

    // Final output
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mul_out <= 'd0;
        end else begin
            mul_out <= sum_stage2;
        end
    end

endmodule
