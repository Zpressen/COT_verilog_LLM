module multi_pipe_4bit #(parameter size = 4) (
    input clk,
    input rst_n,
    input [size-1:0] mul_a,
    input [size-1:0] mul_b,
    output reg [2*size-1:0] mul_out
);

    // Extended inputs
    wire [2*size-1:0] ext_a = { {size{1'b0}}, mul_a };
    wire [2*size-1:0] ext_b = { {size{1'b0}}, mul_b };

    // Partial products
    wire [2*size-1:0] pp [0:size-1];
    reg [2*size-1:0] pp_reg [0:size-1];

    // Intermediate sum registers
    reg [2*size-1:0] sum_reg [0:size-2];

    // Generate partial products
    genvar i;
    generate
        for (i = 0; i < size; i = i + 1) begin : gen_pp
            assign pp[i] = ext_b[i] ? (ext_a << i) : 'd0;
        end
    endgenerate

    // Pipeline stage 1: Register partial products
    integer j;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (j = 0; j < size; j = j + 1)
                pp_reg[j] <= 'd0;
        end else begin
            for (j = 0; j < size; j = j + 1)
                pp_reg[j] <= pp[j];
        end
    end

    // Pipeline stage 2: Accumulate sums
    integer k;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (k = 0; k < size-1; k = k + 1)
                sum_reg[k] <= 'd0;
        end else begin
            sum_reg[0] <= pp_reg[0] + pp_reg[1];
            for (k = 1; k < size-1; k = k + 1)
                sum_reg[k] <= sum_reg[k-1] + pp_reg[k+1];
        end
    end

    // Final output
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mul_out <= 'd0;
        end else begin
            mul_out <= sum_reg[size-2];
        end
    end

endmodule
