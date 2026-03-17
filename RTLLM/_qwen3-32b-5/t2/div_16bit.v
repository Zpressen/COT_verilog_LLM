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
    reg [15:0] quotient;
    reg [15:0] remainder;
    integer i;

    // Initial step: take upper 8 bits of A
    remainder = a_reg[15:8];
    if (remainder >= b_reg) begin
        remainder = remainder - b_reg;
        quotient = 1;
    end else begin
        quotient = 0;
    end

    // Process remaining 8 bits
    for (i=0; i<8; i=i+1) begin
        reg [15:0] new_remainder;
        new_remainder = (remainder << 1) | (a_reg[7 - i]);
        if (new_remainder >= b_reg) begin
            remainder = new_remainder - b_reg;
            quotient = (quotient << 1) | 1;
        end else begin
            remainder = new_remainder;
            quotient = (quotient << 1) | 0;
        end
    end

    result = quotient;
    odd = remainder;
end

endmodule
