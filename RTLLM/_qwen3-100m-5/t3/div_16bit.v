module div_16bit (
    input  wire [15:0] A,
    input  wire [7:0]  B,
    output reg  [15:0] result,
    output reg  [15:0] odd
);

    reg [15:0] a_reg;
    reg [7:0]  b_reg;

    // First always block to capture inputs
    always @* begin
        a_reg = A;
        b_reg = B;
    end

    // Second always block to perform division
    always @* begin
        reg [15:0] rem;
        reg [15:0] quot;
        integer i;

        rem = 0;
        quot = 0;

        for (i = 0; i < 16; i = i + 1) begin
            rem = (rem << 1) | a_reg[15 - i];
            if (rem >= {8'b0, b_reg}) begin
                rem = rem - {8'b0, b_reg};
                quot = quot << 1 | 1;
            end else begin
                quot = quot << 1 | 0;
            end
        end

        result = quot;
        odd    = rem;
    end

endmodule
