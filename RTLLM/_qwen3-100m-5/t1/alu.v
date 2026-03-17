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

always @(*) begin
    r = 32'bz;
    zero = 1'bz;
    carry = 1'bz;
    negative = 1'bz;
    overflow = 1'bz;
    flag = 1'bz;

    case (aluc)
        6'b100000: begin // ADD
            reg [32:0] sum_with_carry;
            sum_with_carry = a + b;
            r = sum_with_carry[31:0];
            carry = sum_with_carry[32];
            overflow = (a[31] & b[31] & ~r[31]) | (~a[31] & ~b[31] & r[31]);
        end
        6'b100001: begin // ADDU
            reg [32:0] sum_with_carry;
            sum_with_carry = a + b;
            r = sum_with_carry[31:0];
            carry = sum_with_carry[32];
            overflow = 1'b0;
        end
        6'b100010: begin // SUB
            reg [32:0] sub_with_carry;
            sub_with_carry = a + (~b) + 1;
            r = sub_with_carry[31:0];
            carry = sub_with_carry[32];
            overflow = (a[31] != b[31]) && (r[31] == b[31]);
        end
        6'b100011: begin // SUBU
            reg [32:0] sub_with_carry;
            sub_with_carry = a + (~b) + 1;
            r = sub_with_carry[31:0];
            carry = sub_with_carry[32];
            overflow = 1'b0;
        end
        6'b100100: begin // AND
            r = a & b;
        end
        6'b100101: begin // OR
            r = a | b;
        end
        6'b100110: begin // XOR
            r = a ^ b;
        end
        6'b100111: begin // NOR
            r = ~(a | b);
        end
        6'b101010: begin // SLT
            r = (a < b) ? 32'h1 : 32'h0;
            flag = r[0];
        end
        6'b101011: begin // SLTU
            r = (a < b) ? 32'h1 : 32'h0;
            flag = r[0];
        end
        6'b000000: begin // SLL
            r = a << b[4:0];
        end
        6'b000010: begin // SRL
            r = a >> b[4:0];
        end
        6'b000011: begin // SRA
            r = $signed(a) >> b[4:0];
        end
        6'b000100: begin // SLLV
            r = a << a[4:0];
        end
        6'b000110: begin // SRLV
            r = a >> a[4:0];
        end
        6'b000111: begin // SRAV
            r = $signed(a) >> a[4:0];
        end
        6'b001111: begin // LUI
            r = {a[31:16], 16'b0};
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

    if (r !== 32'bz) begin
        zero = (r == 32'h0);
        negative = r[31];
    end
end

endmodule
