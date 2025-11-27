module alu (
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
    r = 32'hx;
    zero = 1'bx;
    carry = 1'bx;
    negative = 1'bx;
    overflow = 1'bx;
    flag = 1'bx;

    case (aluc)
        ADD: begin
            logic [32:0] sum_33;
            sum_33 = $signed(a) + $signed(b);
            r = sum_33[31:0];
            carry = sum_33[32];
            overflow = (a[31] & b[31] & ~sum_33[31]) | (~a[31] & ~b[31] & sum_33[31]);
            flag = 1'b0;
        end
        ADDU: begin
            logic [32:0] sum_33;
            sum_33 = a + b;
            r = sum_33[31:0];
            carry = sum_33[32];
            overflow = carry;
            flag = 1'b0;
        end
        SUB: begin
            logic [32:0] sum_33;
            sum_33 = $signed(a) - $signed(b);
            r = sum_33[31:0];
            carry = ~sum_33[32];
            overflow = (a[31] & ~b[31] & ~sum_33[31]) | (~a[31] & b[31] & sum_33[31]);
            flag = 1'b0;
        end
        SUBU: begin
            logic [32:0] sum_33;
            sum_33 = a - b;
            r = sum_33[31:0];
            carry = ~sum_33[32];
            overflow = ~carry;
            flag = 1'b0;
        end
        AND: begin
            r = a & b;
            carry = 1'b0;
            overflow = 1'b0;
            flag = 1'b0;
        end
        OR: begin
            r = a | b;
            carry = 1'b0;
            overflow = 1'b0;
            flag = 1'b0;
        end
        XOR: begin
            r = a ^ b;
            carry = 1'b0;
            overflow = 1'b0;
            flag = 1'b0;
        end
        NOR: begin
            r = ~(a | b);
            carry = 1'b0;
            overflow = 1'b0;
            flag = 1'b0;
        end
        SLT: begin
            r = ($signed(a) < $signed(b)) ? 32'h1 : 32'h0;
            carry = 1'b0;
            overflow = 1'b0;
            flag = (a < b) ? 1'b1 : 1'b0;
        end
        SLTU: begin
            r = (a < b) ? 32'h1 : 32'h0;
            carry = 1'b0;
            overflow = 1'b0;
            flag = (a < b) ? 1'b1 : 1'b0;
        end
        SLL: begin
            r = b << a[4:0];
            carry = 1'b0;
            overflow = 1'b0;
            flag = 1'b0;
        end
        SRL: begin
            r = b >>> a[4:0];
            carry = 1'b0;
            overflow = 1'b0;
            flag = 1'b0;
        end
        SRA: begin
            r = $signed(b) >>> a[4:0];
            carry = 1'b0;
            overflow = 1'b0;
            flag = 1'b0;
        end
        SLLV: begin
            r = b << a[4:0];
            carry = 1'b0;
            overflow = 1'b0;
            flag = 1'b0;
        end
        SRLV: begin
            r = b >>> a[4:0];
            carry = 1'b0;
            overflow = 1'b0;
            flag = 1'b0;
        end
        SRAV: begin
            r = $signed(b) >>> a[4:0];
            carry = 1'b0;
            overflow = 1'b0;
            flag = 1'b0;
        end
        LUI: begin
            r = {a[15:0], 16'b0};
            carry = 1'b0;
            overflow = 1'b0;
            flag = 1'b0;
        end
        default: begin
            r = 32'hx;
            zero = 1'bx;
            carry = 1'bx;
            negative = 1'bx;
            overflow = 1'bx;
            flag = 1'bx;
        end
    endcase

    zero = (r == 32'h0) ? 1'b1 : 1'b0;
    negative = r[31];
end

endmodule
