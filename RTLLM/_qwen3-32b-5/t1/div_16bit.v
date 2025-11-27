module div_16bit (
    input [15:0] A,
    input [7:0] B,
    output reg [15:0] result,
    output reg [15:0] odd
);

reg [15:0] a_reg;
reg [7:0] b_reg;

always @(*) begin
    a_reg = A;
    b_reg = B;
end

always @(*) begin
    integer i;
    reg [15:0] quotient;
    reg [15:0] remainder;

    quotient = 0;
    remainder = 0;

    for (i = 0; i < 16; i = i + 1) begin
        remainder = (remainder << 1) | (a_reg[15 - i]);
        if (remainder >= b_reg) begin
            remainder = remainder - b_reg;
            quotient = (quotient << 1) | 1;
        end else begin
            quotient = (quotient << 1) | 0;
        end
    end

    result = quotient;
    odd = remainder;
end

endmodule
