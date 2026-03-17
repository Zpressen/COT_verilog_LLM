module div_16bit (
    input  wire [15:0] A,
    input  wire [7:0]  B,
    output reg  [15:0] result,
    output reg  [15:0] odd
);

    reg [7:0] a_reg;
    reg [7:0] b_reg;

    reg [7:0] remainder_0;
    reg [15:0] quotient_0;
    reg [7:0] remainder_1;
    reg [15:0] quotient_1;
    reg [7:0] remainder_2;
    reg [15:0] quotient_2;
    reg [7:0] remainder_3;
    reg [15:0] quotient_3;
    reg [7:0] remainder_4;
    reg [15:0] quotient_4;
    reg [7:0] remainder_5;
    reg [15:0] quotient_5;
    reg [7:0] remainder_6;
    reg [15:0] quotient_6;
    reg [7:0] remainder_7;
    reg [15:0] quotient_7;
    reg [7:0] remainder_8;
    reg [15:0] quotient_8;

    always @* begin
        a_reg = A[15:8];
        b_reg = B;
    end

    always @* begin
        // Step 0: Initial values
        remainder_0 = a_reg;
        quotient_0 = 16'b0;

        // Step 1
        remainder_1 = {remainder_0[7:1], A[7]};
        if (remainder_1 >= b_reg) begin
            quotient_1 = quotient_0 << 1 | 1;
            remainder_1 = remainder_1 - b_reg;
        end else begin
            quotient_1 = quotient_0 << 1 | 0;
            remainder_1 = remainder_1;
        end

        // Step 2
        remainder_2 = {remainder_1[7:1], A[6]};
        if (remainder_2 >= b_reg) begin
            quotient_2 = quotient_1 << 1 | 1;
            remainder_2 = remainder_2 - b_reg;
        end else begin
            quotient_2 = quotient_1 << 1 | 0;
            remainder_2 = remainder_2;
        end

        // Step 3
        remainder_3 = {remainder_2[7:1], A[5]};
        if (remainder_3 >= b_reg) begin
            quotient_3 = quotient_2 << 1 | 1;
            remainder_3 = remainder_3 - b_reg;
        end else begin
            quotient_3 = quotient_2 << 1 | 0;
            remainder_3 = remainder_3;
        end

        // Step 4
        remainder_4 = {remainder_3[7:1], A[4]};
        if (remainder_4 >= b_reg) begin
            quotient_4 = quotient_3 << 1 | 1;
            remainder_4 = remainder_4 - b_reg;
        end else begin
            quotient_4 = quotient_3 << 1 | 0;
            remainder_4 = remainder_4;
        end

        // Step 5
        remainder_5 = {remainder_4[7:1], A[3]};
        if (remainder_5 >= b_reg) begin
            quotient_5 = quotient_4 << 1 | 1;
            remainder_5 = remainder_5 - b_reg;
        end else begin
            quotient_5 = quotient_4 << 1 | 0;
            remainder_5 = remainder_5;
        end

        // Step 6
        remainder_6 = {remainder_5[7:1], A[2]};
        if (remainder_6 >= b_reg) begin
            quotient_6 = quotient_5 << 1 | 1;
            remainder_6 = remainder_6 - b_reg;
        end else begin
            quotient_6 = quotient_5 << 1 | 0;
            remainder_6 = remainder_6;
        end

        // Step 7
        remainder_7 = {remainder_6[7:1], A[1]};
        if (remainder_7 >= b_reg) begin
            quotient_7 = quotient_6 << 1 | 1;
            remainder_7 = remainder_7 - b_reg;
        end else begin
            quotient_7 = quotient_6 << 1 | 0;
            remainder_7 = remainder_7;
        end

        // Step 8
        remainder_8 = {remainder_7[7:1], A[0]};
        if (remainder_8 >= b_reg) begin
            quotient_8 = quotient_7 << 1 | 1;
            remainder_8 = remainder_8 - b_reg;
        end else begin
            quotient_8 = quotient_7 << 1 | 0;
            remainder_8 = remainder_8;
        end

        result = {quotient_8, 8'b0};
        odd = {remainder_8, 8'b0};
    end

endmodule
