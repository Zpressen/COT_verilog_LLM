module alu(
    input [31:0] a,
    input [31:0] b,
    input [5:0] aluc,
    output reg [31:0] r,
    output reg zero,
    output reg carry,
    output reg negative,
    output reg overflow,
    output reg flag
);

parameter ADD = 6'b100000;
parameter ADDU = 6'b100001;
parameter SUB = 6'b100010;
parameter SUBU = 6'b100011;
parameter AND = 6'b100100;
parameter OR = 6'b100101;
parameter XOR = 6'b100110;
parameter NOR = 6'b100111;
parameter SLT = 6'b101010;
parameter SLTU = 6'b101011;
parameter SLL = 6'b000000;
parameter SRL = 6'b000010;
parameter SRA = 6'b000011;
parameter SLLV = 6'b000100;
parameter SRLV = 6'b000110;
parameter SRAV = 6'b000111;
parameter LUI = 6'b001111;

always @(*) begin
    r = 32'bx;
    zero = 1'b0;
    carry = 1'b0;
    negative = 1'b0;
    overflow = 1'b0;
    flag = 1'bz;

    case (aluc)
        ADD: begin
            r = a + b;
            carry = (a + b) >> 32;
            overflow = (a[31] == b[31]) && (r[31] != a[31]);
            zero = (r == 32'h0);
            negative = r[31];
        end
        ADDU: begin
            r = a + b;
            carry = (a + b) >> 32;
            overflow = 1'b0;
            zero = (r == 32'h0);
            negative = r[31];
        end
        SUB: begin
            r = a - b;
            carry = (a < b) ? 1'b1 : 1'b0;
            overflow = ((a[31] != b[31]) && (r[31] != a[31]));
            zero = (r == 32'h0);
            negative = r[31];
        end
        SUBU: begin
            r = a - b;
            carry = (a < b) ? 1'b1 : 1'b0;
            overflow = 1'b0;
            zero = (r == 32'h0);
            negative = r[31];
        end
        AND: begin
            r = a & b;
            carry = 1'b0;
            overflow = 1'b0;
            zero = (r == 32'h0);
            negative = r[31];
        end
        OR: begin
            r = a | b;
            carry = 1'b0;
            overflow = 1'b0;
            zero = (r == 32'h0);
            negative = r[31];
        end
        XOR: begin
            r = a ^ b;
            carry = 1'b0;
            overflow = 1'b0;
            zero = (r == 32'h0);
            negative = r[31];
        end
        NOR: begin
            r = ~(a | b);
            carry = 1'b0;
            overflow = 1'b0;
            zero = (r == 32'h0);
            negative = r[31];
        end
        SLT: begin
            r = (a < b) ? 1 : 0;
            flag = r[0];
            carry = 1'b0;
            overflow = 1'b0;
            zero = (r == 32'h0);
            negative = r[31];
        end
        SLTU: begin
            r = (a < b) ? 1 : 0;
            flag = r[0];
            carry = 1'b0;
            overflow = 1'b0;
            zero = (r == 32'h0);
            negative = r[31];
        end
        SLL: begin
            r = b << a[4:0];
            carry = 1'b0;
            overflow = 1'b0;
            zero = (r == 32'h0);
            negative = r[31];
        end
        SRL: begin
            r = b >>> a[4:0];
            carry = 1'b0;
            overflow = 1'b0;
            zero = (r == 32'h0);
            negative = r[31];
        end
        SRA: begin
            r = b >> a[4:0];
            carry = 1'b0;
            overflow = 1'b0;
            zero = (r == 32'h0);
            negative = r[31];
        end
        SLLV: begin
            r = b << a[4:0];
            carry = 1'b0;
            overflow = 1'b0;
            zero = (r == 32'h0);
            negative = r[31];
        end
        SRLV: begin
            r = b >>> a[4:0];
            carry = 1'b0;
            overflow = 1'b0;
            zero = (r == 32'h0);
            negative = r[31];
        end
        SRAV: begin
            r = b >> a[4:0];
            carry = 1'b0;
            overflow = 1'b0;
            zero = (r == 32'h0);
            negative = r[31];
        end
        LUI: begin
            r = {a[15:0], 16'b0};
            carry = 1'b0;
            overflow = 1'b0;
            zero = (r == 32'h0);
            negative = r[31];
        end
        default: begin
            r = 32'bx;
            zero = 1'b0;
            carry = 1'b0;
            negative = 1'b0;
            overflow = 1'b0;
            flag = 1'bz;
        end
    endcase
end

endmodule
