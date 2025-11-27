module pe (
    input wire clk,
    input wire rst,
    input wire signed [31:0] a,
    input wire signed [31:0] b,
    output reg signed [31:0] c
);

    // Internal register for accumulation
    reg signed [31:0] accumulator;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // Reset condition - clear the accumulator
            accumulator <= 32'd0;
        end else begin
            // Accumulate the product of a and b
            accumulator <= accumulator + (a * b);
        end
    end

    // Continuous assignment of accumulator to output
    assign c = accumulator;

endmodule
