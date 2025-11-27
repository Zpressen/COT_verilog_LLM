module alu (
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

wire [32:0] temp_sum_add = {1'b0, a} + {1'b0, b};
wire [32:0] temp_sum_sub = {1'b0, a} + {1'b1, ~b} + 1;

always @(*) begin
    r = 32'bx;
    zero = 1'bx;
    carry = 1'bx;
    negative = 1'bx;
    overflow = 1'bx;
    flag = 1'bz;

    case (aluc)
        ADD, ADDU: begin
            carry = temp_sum_add[32];
            r = temp_sum_add[31:0];
            negative = r[31];
            if (aluc == ADD) begin
                overflow = (a[31] & b[31] & ~r[31]) | (~a[31] & ~b[31] & r[31]);
            end else begin
                overflow = 1'b0;
            end
            zero = (r == 32'b0);
            flag = 1'bz;
        end
        SUB, SUBU: begin
            carry = temp_sum_sub[32];
            r = temp_sum_sub[31:0];
            negative = r[31];
            if (aluc == SUB) begin
                overflow = (a[31] ^ ~b[31]) ? 1'b0 : (a[31] ^ r[31]);
            end else begin
                overflow = 1'b0;
            end
            zero = (r == 32'b0);
            flag = 1'bz;
        end
        AND: begin
            r = a & b;
            carry = 1'b0;
            overflow = 1'b0;
            negative = r[31];
            zero = (r == 32'b0);
            flag = 1'bz;
        end
        OR: begin
            r = a | b;
            carry = 1'b0;
            overflow = 1'b0;
            negative = r[31];
            zero = (r == 32'b0);
            flag = 1'bz;
        end
        XOR: begin
            r = a ^ b;
            carry = 1'b0;
            overflow = 1'b0;
            negative = r[31];
            zero = (r == 32'b0);
            flag = 1'bz;
        end
        NOR: begin
            r = ~(a | b);
            carry = 1'b0;
            overflow = 1'b0;
            negative = r[31];
            zero = (r == 32'b0);
            flag = 1'bz;
        end
        SLT: begin
            r = ($signed(a) < $signed(b)) ? 32'b1 : 32'b0;
            carry = 1'b0;
            overflow = 1'b0;
            negative = 1'b0;
            zero = (r == 32'b0);
            flag = r[0];
        end
        SLTU: begin
            r = ($unsigned(a) < $unsigned(b)) ? 32'b1 : 32'b0;
            carry = 1'b0;
            overflow = 1'b0;
            negative = 1'b0;
            zero = (r == 32'b0);
            flag = r[0];
        end
        SLL: begin
            r = b << a[4:0];
            carry = 1'b0;
            overflow = 1'b0;
            negative = r[31];
            zero = (r == 32'b0);
            flag = 1'bz;
        end
        SRL: begin
            r = b >> a[4:0];
            carry = 1'b0;
            overflow = 1'b0;
            negative = r[31];
            zero = (r == 32'b0);
            flag = 1'bz;
        end
        SRA: begin
            r = $signed(b) >>> a[4:0];
            carry = 1'b0;
            overflow = 1'b0;
            negative = r[31];
            zero = (r == 32'b0);
            flag = 1'bz;
        end
        SLLV: begin
            r = b << a;
            carry = 1'b0;
            overflow = 1'b0;
            negative = r[31];
            zero = (r == 32'b0);
            flag = 1'bz;
        end
        SRLV: begin
            r = b >> a;
            carry = 1'b0;
            overflow = 1'b0;
            negative = r[31];
            zero = (r == 32'b0);
            flag = 1'bz;
        end
        SRAV: begin
            r = $signed(b) >>> a;
            carry = 1'b0;
            overflow = 1'b0;
            negative = r[31];
            zero = (r == 32'b0);
            flag = 1'bz;
        end
        LUI: begin
            r = {a[15:0], 16'b0};
            carry = 1'b0;
            overflow = 1'b0;
            negative = r[31];
            zero = (r == 32'b0);
            flag = 1'bz;
        end
        default: begin
            r = 32'bx;
            zero = 1'bx;
            carry = 1'bx;
            negative = 1'bx;
            overflow = 1'bx;
            flag = 1'bz;
        end
    endcase
end

endmodule
