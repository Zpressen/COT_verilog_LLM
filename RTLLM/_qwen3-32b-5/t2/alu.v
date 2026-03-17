module alu #(
    parameter ADD = 6'b100000,
    parameter ADDU = 6'b100001,
    parameter SUB = 6'b100010,
    parameter SUBU = 6'b100011,
    parameter AND = 6'b100100,
    parameter OR = 6'b100101,
    parameter XOR = 6'b100110,
    parameter NOR = 6'b100111,
    parameter SLT = 6'b101010,
    parameter SLTU = 6'b101011,
    parameter SLL = 6'b000000,
    parameter SRL = 6'b000010,
    parameter SRA = 6'b000011,
    parameter SLLV = 6'b000100,
    parameter SRLV = 6'b000110,
    parameter SRAV = 6'b000111,
    parameter LUI = 6'b001111
)(
    input      [31:0] a,
    input      [31:0] b,
    input      [5:0]  aluc,
    output reg [31:0] r,
    output reg        zero,
    output reg        carry,
    output reg        negative,
    output reg        overflow,
    output reg        flag
);

always @(*) begin
    r = 32'bz;
    zero = 1'bz;
    carry = 1'bz;
    negative = 1'bz;
    overflow = 1'bz;
    flag = 1'bz;

    case (aluc)
        ADD: begin
            r = a + b;
            carry = (a + b) < a ? 1'b1 : 1'b0;
            overflow = (a[31] == b[31]) && (r[31] != a[31]);
            negative = r[31];
            zero = (r == 0);
            flag = 1'bz;
        end
        ADDU: begin
            r = a + b;
            carry = (a + b) < a ? 1'b1 : 1'b0;
            overflow = 1'b0;
            negative = r[31];
            zero = (r == 0);
            flag = 1'bz;
        end
        SUB: begin
            r = a - b;
            carry = (a >= b) ? 1'b1 : 1'b0;
            overflow = (a[31] == ~b[31]) ? 1'b0 : (r[31] != a[31]);
            negative = r[31];
            zero = (r == 0);
            flag = 1'bz;
        end
        SUBU: begin
            r = a - b;
            carry = (a >= b) ? 1'b1 : 1'b0;
            overflow = 1'b0;
            negative = r[31];
            zero = (r == 0);
            flag = 1'bz;
        end
        AND: begin
            r = a & b;
            carry = 1'b0;
            overflow = 1'b0;
            negative = r[31];
            zero = (r == 0);
            flag = 1'bz;
        end
        OR: begin
            r = a | b;
            carry = 1'b0;
            overflow = 1'b0;
            negative = r[31];
            zero = (r == 0);
            flag = 1'bz;
        end
        XOR: begin
            r = a ^ b;
            carry = 1'b0;
            overflow = 1'b0;
            negative = r[31];
            zero = (r == 0);
            flag = 1'bz;
        end
        NOR: begin
            r = ~(a | b);
            carry = 1'b0;
            overflow = 1'b0;
            negative = r[31];
            zero = (r == 0);
            flag = 1'bz;
        end
        SLT: begin
            r = ($signed(a) < $signed(b)) ? 1 : 0;
            carry = 1'b0;
            overflow = 1'b0;
            negative = 1'b0;
            zero = (r == 0);
            flag = r;
        end
        SLTU: begin
            r = (a < b) ? 1 : 0;
            carry = 1'b0;
            overflow = 1'b0;
            negative = 1'b0;
            zero = (r == 0);
            flag = r;
        end
        SLL: begin
            r = b << a[4:0];
            carry = 1'b0;
            overflow = 1'b0;
            negative = r[31];
            zero = (r == 0);
            flag = 1'bz;
        end
        SRL: begin
            r = b >> a[4:0];
            carry = 1'b0;
            overflow = 1'b0;
            negative = r[31];
            zero = (r == 0);
            flag = 1'bz;
        end
        SRA: begin
            r = $signed(b) >>> a[4:0];
            carry = 1'b0;
            overflow = 1'b0;
            negative = r[31];
            zero = (r == 0);
            flag = 1'bz;
        end
        SLLV: begin
            r = b << a[4:0];
            carry = 1'b0;
            overflow = 1'b0;
            negative = r[31];
            zero = (r == 0);
            flag = 1'bz;
        end
        SRLV: begin
            r = b >> a[4:0];
            carry = 1'b0;
            overflow = 1'b0;
            negative = r[31];
            zero = (r == 0);
            flag = 1'bz;
        end
        SRAV: begin
            r = $signed(b) >>> a[4:0];
            carry = 1'b0;
            overflow = 1'b0;
            negative = r[31];
            zero = (r == 0);
            flag = 1'bz;
        end
        LUI: begin
            r = {a[31:16], 16'b0};
            carry = 1'b0;
            overflow = 1'b0;
            negative = r[31];
            zero = (r == 0);
            flag = 1'bz;
        end
        default: begin
            r = 32'bz;
            zero = 1'bz;
            carry = 1'bz;
            negative = 1'bz;
            overflow = 1'bz;
            flag = 1'bz;
        end
    endcase
end

endmodule
