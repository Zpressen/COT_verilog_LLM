module div_16bit (
    input [15:0] A,
    input [7:0] B,
    output reg [15:0] result,
    output reg [15:0] odd
);

    reg [15:0] dividend;
    reg [7:0] divisor;
    reg [8:0] remainder; // 9-bit to handle overflow during subtraction
    integer i;

    always @(*) begin
        dividend = A;
        divisor = B;
        remainder = 9'b0;
        result = 16'b0;

        for (i = 15; i >= 0; i = i - 1) begin
            // Shift remainder and dividend left by 1
            remainder = {remainder[7:0], dividend[i]};
            
            // Compare remainder with divisor
            if (remainder >= {1'b0, divisor}) begin
                remainder = remainder - {1'b0, divisor};
                result[i] = 1'b1;
            end else begin
                result[i] = 1'b0;
            end
        end
        
        // Final remainder is in lower 8 bits
        odd = {8'b0, remainder[7:0]};
    end

endmodule
