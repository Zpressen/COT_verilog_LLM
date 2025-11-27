module alu(
    input [31:0] a,
    input [31:0] b,
    input [5:0] aluc,
    output reg [31:0] r,
    output zero,
    output carry,
    output negative,
    output overflow,
    output flag
);

    // Operation codes
    parameter ADD   = 6'b100000;
    parameter ADDU  = 6'b100001;
    parameter SUB   = 6'b100010;
    parameter SUBU  = 6'b100011;
    parameter AND   = 6'b100100;
    parameter OR    = 6'b100101;
    parameter XOR   = 6'b100110;
    parameter NOR   = 6'b100111;
    parameter SLT   = 6'b101010;
    parameter SLTU  = 6'b101011;
    parameter SLL   = 6'b000000;
    parameter SRL   = 6'b000010;
    parameter SRA   = 6'b000011;
    parameter SLLV  = 6'b000100;
    parameter SRLV  = 6'b000110;
    parameter SRAV  = 6'b000111;
    parameter LUI   = 6'b001111;

    // Internal signals
    reg [32:0] res;  // 33-bit to capture carry
    wire signed [31:0] a_signed = a;
    wire signed [31:0] b_signed = b;
    wire [31:0] b_shift = b << 16;  // For LUI
    
    assign zero = (r == 32'b0);
    assign negative = r[31];
    assign carry = res[32];
    
    // Overflow detection for ADD/SUB
    wire add_overflow = (a[31] == b[31]) && (res[31] != a[31]);
    wire sub_overflow = (a[31] != b[31]) && (res[31] != a[31]);
    assign overflow = (aluc == ADD) ? add_overflow : 
                     (aluc == SUB) ? sub_overflow : 1'b0;
    
    // Flag output (for SLT/SLTU)
    assign flag = (aluc == SLT || aluc == SLTU) ? res[0] : 1'bz;

    always @(*) begin
        case (aluc)
            ADD:  res = {a[31], a} + {b[31], b};
            ADDU: res = {1'b0, a} + {1'b0, b};
            SUB:  res = {a[31], a} - {b[31], b};
            SUBU: res = {1'b0, a} - {1'b0, b};
            AND:  res = {1'b0, a & b};
            OR:   res = {1'b0, a | b};
            XOR:  res = {1'b0, a ^ b};
            NOR:  res = {1'b0, ~(a | b)};
            SLT:  res = (a_signed < b_signed) ? 33'b1 : 33'b0;
            SLTU: res = (a < b) ? 33'b1 : 33'b0;
            SLL:  res = {1'b0, b << a[4:0]};
            SRL:  res = {1'b0, b >> a[4:0]};
            SRA:  res = {1'b0, $signed(b) >>> a[4:0]};
            SLLV: res = {1'b0, b << a[4:0]};
            SRLV: res = {1'b0, b >> a[4:0]};
            SRAV: res = {1'b0, $signed(b) >>> a[4:0]};
            LUI:  res = {1'b0, b_shift};
            default: res = 33'bz;
        endcase
        
        r = res[31:0];
    end

endmodule
