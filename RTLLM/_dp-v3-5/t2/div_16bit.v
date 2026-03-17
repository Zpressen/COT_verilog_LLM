module div_16bit (
    input [15:0] A,
    input [7:0] B,
    output reg [15:0] result,
    output reg [15:0] odd
);

    reg [16:0] working_reg; // 17-bit working register (16+1)
    integer i;

    always @(*) begin
        working_reg = {1'b0, A}; // Initialize with dividend (0 extended)
        result = 16'b0;           // Initialize quotient

        for (i = 0; i < 16; i = i + 1) begin
            // Shift left 1 bit
            working_reg = {working_reg[15:0], 1'b0};
            
            // Compare upper 8 bits with divisor
            if (working_reg[16:9] >= B) begin
                // Subtract divisor from upper bits
                working_reg[16:9] = working_reg[16:9] - B;
                // Set quotient bit
                result[15-i] = 1'b1;
            end else begin
                result[15-i] = 1'b0;
            end
        end
        
        // Remainder is in upper 8 bits, but we output 16-bit
        odd = {8'b0, working_reg[16:9]};
    end

endmodule
