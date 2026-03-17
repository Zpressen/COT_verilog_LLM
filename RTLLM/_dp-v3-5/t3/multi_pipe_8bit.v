module multi_pipe_8bit (
    input clk,
    input rst_n,
    input mul_en_in,
    input [7:0] mul_a,
    input [7:0] mul_b,
    output mul_en_out,
    output [15:0] mul_out
);

    // Pipeline registers for enable signals
    reg [2:0] enable_pipe;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            enable_pipe <= 3'b0;
        end else begin
            enable_pipe <= {enable_pipe[1:0], mul_en_in};
        end
    end
    assign mul_en_out = enable_pipe[2];

    // Input registers
    reg [7:0] a_reg, b_reg;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            a_reg <= 8'b0;
            b_reg <= 8'b0;
        end else if (mul_en_in) begin
            a_reg <= mul_a;
            b_reg <= mul_b;
        end
    end

    // Partial products generation
    wire [15:0] pp [7:0];
    generate
        genvar i;
        for (i = 0; i < 8; i = i + 1) begin : PARTIAL_PRODUCTS
            assign pp[i] = b_reg[i] ? (a_reg << i) : 16'b0;
        end
    endgenerate

    // Pipeline stage 1: First level additions
    reg [15:0] sum0, sum1, sum2, sum3;
    reg enable_p1;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sum0 <= 16'b0;
            sum1 <= 16'b0;
            sum2 <= 16'b0;
            sum3 <= 16'b0;
            enable_p1 <= 1'b0;
        end else begin
            sum0 <= pp[0] + pp[1];
            sum1 <= pp[2] + pp[3];
            sum2 <= pp[4] + pp[5];
            sum3 <= pp[6] + pp[7];
            enable_p1 <= enable_pipe[0];
        end
    end

    // Pipeline stage 2: Second level additions
    reg [15:0] sum4, sum5;
    reg enable_p2;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sum4 <= 16'b0;
            sum5 <= 16'b0;
            enable_p2 <= 1'b0;
        end else begin
            sum4 <= sum0 + sum1;
            sum5 <= sum2 + sum3;
            enable_p2 <= enable_p1;
        end
    end

    // Pipeline stage 3: Final addition
    reg [15:0] mul_out_reg;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mul_out_reg <= 16'b0;
        end else if (enable_p2) begin
            mul_out_reg <= sum4 + sum5;
        end
    end

    // Output assignment
    assign mul_out = enable_pipe[2] ? mul_out_reg : 16'b0;

endmodule
