module div_16bit (
    input [15:0] A,
    input [7:0] B,
    output reg [15:0] result,
    output reg [15:0] odd
);

reg [15:0] dividend;
reg [7:0] divisor;
reg [15:0] remainder;
reg [15:0] quotient;
integer i;

always @(*) begin
    dividend = A;
    divisor = B;
    remainder = 16'b0;
    quotient = 16'b0;

    for (i = 15; i >= 0; i = i - 1) begin
        // Shift remainder left by 1 bit
        remainder = remainder << 1;
        // Bring down the next bit from dividend
        remainder[0] = dividend[i];
        
        // Compare with divisor
        if (remainder[15:8] >= divisor || divisor == 8'b0) begin
            // Subtract divisor from remainder
            remainder[15:8] = remainder[15:8] - divisor;
            // Set quotient bit
            quotient[i] = 1'b1;
        end
    end
    
    result = quotient;
    odd = remainder;
end

endmodule
