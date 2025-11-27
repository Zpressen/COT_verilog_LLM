module div_16bit (
    input  [15:0] A,
    input  [7:0]  B,
    output [15:0] result,
    output [15:0] odd
);

reg [15:0] a_reg;
reg [7:0]  b_reg;
reg [7:0]  rem;
reg [7:0]  quot;

always @* begin
    a_reg = A;
    b_reg = B;
end

always @* begin
    rem = a_reg[15:8];
    quot = 8'b0;
    if (rem >= b_reg) begin
        rem = rem - b_reg;
        quot = quot << 1 | 1'b1;
    end else begin
        rem = rem << 1 | a_reg[7];
        quot = quot << 1 | 1'b0;
    end
    if (rem >= b_reg) begin
        rem = rem - b_reg;
        quot = quot << 1 | 1'b1;
    end else begin
        rem = rem << 1 | a_reg[6];
        quot = quot << 1 | 1'b0;
    end
    if (rem >= b_reg) begin
        rem = rem - b_reg;
        quot = quot << 1 | 1'b1;
    end else begin
        rem = rem << 1 | a_reg[5];
        quot = quot << 1 | 1'b0;
    end
    if (rem >= b_reg) begin
        rem = rem - b_reg;
        quot = quot << 1 | 1'b1;
    end else begin
        rem = rem << 1 | a_reg[4];
        quot = quot << 1 | 1'b0;
    end
    if (rem >= b_reg) begin
        rem = rem - b_reg;
        quot = quot << 1 | 1'b1;
    end else begin
        rem = rem << 1 | a_reg[3];
        quot = quot << 1 | 1'b0;
    end
    if (rem >= b_reg) begin
        rem = rem - b_reg;
        quot = quot << 1 | 1'b1;
    end else begin
        rem = rem << 1 | a_reg[2];
        quot = quot << 1 | 1'b0;
    end
    if (rem >= b_reg) begin
        rem = rem - b_reg;
        quot = quot << 1 | 1'b1;
    end else begin
        rem = rem << 1 | a_reg[1];
        quot = quot << 1 | 1'b0;
    end
    if (rem >= b_reg) begin
        rem = rem - b_reg;
        quot = quot << 1 | 1'b1;
    end else begin
        rem = rem << 1 | a_reg[0];
        quot = quot << 1 | 1'b0;
    end
    result = {quot, 8'b0};
    odd = {rem, 8'b0};
end

endmodule
