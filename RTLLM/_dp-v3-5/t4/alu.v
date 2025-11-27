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

    // ALU operation codes
    parameter ADD  = 6'b100000;
    parameter ADDU = 6'b100001;
    parameter SUB  = 6'b100010;
    parameter SUBU = 6'b100011;
    parameter AND  = 6'b100100;
    parameter OR   = 6'b100101;
    parameter XOR  = 6'b100110;
    parameter NOR  = 6'b100111;
    parameter SLT  = 6'b101010;
    parameter SLTU = 6'b101011;
    parameter SLL  = 6'b000000;
    parameter SRL  = 6'b000010;
    parameter SRA  = 6'b000011;
    parameter SLLV = 6'b000100;
    parameter SRLV = 6'b000110;
    parameter SRAV = 6'b000111;
    parameter LUI  = 6'b001111;

    wire signed [31:0] signed_a = a;
    wire signed [31:0] signed_b = b;
    reg [32:0] res_ext; // 33-bit for carry/overflow detection
    wire [31:0] res = res_ext[31:0];
    wire res_carry = res_ext[32];
    wire [4:0] shamt = b[4:0]; // shift amount for variable shifts

    // Flag assignments
    assign zero = (res == 32'b0);
    assign negative = res[31];
    assign overflow = (aluc == ADD || aluc == SUB) ? 
                    ((aluc == ADD && (signed_a[31] == signed_b[31]) && (res[31] != signed_a[31])) ||
                     (aluc == SUB && (signed_a[31] != signed_b[31]) && (res[31] != signed_a[31]))) : 1'b0;
    assign carry = (aluc == ADD || aluc == ADDU || aluc == SUB || aluc == SUBU) ? res_carry : 1'b0;
    assign flag = (aluc == SLT) ? (signed_a < signed_b) :
                 (aluc == SLTU) ? (a < b) : 1'bz;

    always @(*) begin
        case (aluc)
            ADD, ADDU: res_ext = {1'b0, a} + {1'b0, b};
            SUB, SUBU: res_ext = {1'b0, a} - {1'b0, b};
            AND: res_ext = {1'b0, a & b};
            OR:  res_ext = {1'b0, a | b};
            XOR: res_ext = {1'b0, a ^ b};
            NOR: res_ext = {1'b0, ~(a | b)};
            SLT: res_ext = {1'b0, (signed_a < signed_b) ? 32'b1 : 32'b0};
            SLTU: res_ext = {1'b0, (a < b) ? 32'b1 : 32'b0};
            SLL: res_ext = {1'b0, b << a[4:0]};
            SRL: res_ext = {1'b0, b >> a[4:0]};
            SRA: res_ext = {1'b0, $signed(b) >>> a[4:0]};
            SLLV: res_ext = {1'b0, b << shamt};
            SRLV: res_ext = {1'b0, b >> shamt};
            SRAV: res_ext = {1'b0, $signed(b) >>> shamt};
            LUI: res_ext = {1'b0, {b[15:0], 16'b0}};
            default: res_ext = {1'b0, 32'bz};
        endcase
        r = res;
    end

endmodule
