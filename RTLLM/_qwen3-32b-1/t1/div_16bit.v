[BEIGN]
module div_16bit (
    input [15:0] A,
    input [7:0] B,
    output reg [15:0] result,
    output reg [15:0] odd
);

reg [15:0] a_reg;
reg [7:0] b_reg;

always @(A or B) begin
    a_reg = A;
    b_reg = B;
end

always @(a_reg or b_reg) begin
    integer i;
    reg [15:0] quotient;
    reg [15:0] remainder;
    reg [15:0] current_val;

    quotient = 0;
    remainder = 0;

    // First step: take higher 8 bits of A
    current_val = a_reg[15:8];
    if (current_val >= b_reg) begin
        quotient[0] = 1;
        remainder = current_val - b_reg;
    end else begin
        quotient[0] = 0;
        remainder = current_val;
    end

    // Remaining steps: take remainder, shift left, add next bit
    for (i=1; i<=8; i=i+1) begin
        remainder = (remainder << 1) | (a_reg[8 - i]);
        if (remainder >= b_reg) begin
            quotient[i] = 1;
            remainder = remainder - b_reg;
        end else begin
            quotient[i] = 0;
        end
    end

    // Pad quotient and remainder to 16 bits
    result = { (16 - 9)'b0, quotient };
    odd = { (16 - 8)'b0, remainder };
end

endmodule
