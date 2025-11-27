module alu(
    input [31:0] a,
    input [31:0] b,
    input [5:0] aluc,
    output reg [31:0] r,
    output zero,
    output carry,
    output negative,
    output overflow,
    output reg flag
);

    // Operation codes
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

    // Internal signals
    reg [32:0] res;  // 33-bit result for carry detection
    wire signed [31:0] signed_a = a;
    wire signed [31:0] signed_b = b;
    wire [4:0] shift_amount;
    
    // Flag signals
    assign zero = (r == 32'b0);
    assign negative = r[31];
    assign carry = res[32];
    assign overflow = (aluc == ADD || aluc == SUB) ? 
                     ((aluc == ADD) ? ((signed_a[31] == signed_b[31]) && (res[31] != signed_a[31])) :
                                      ((signed_a[31] != signed_b[31]) && (res[31] != signed_a[31]))) : 1'b0;
    
    // Shift amount selection
    assign shift_amount = (aluc == SLL || aluc == SRL || aluc == SRA) ? b[4:0] : a[4:0];
    
    always @(*) begin
        flag = 1'bz;  // Default high-impedance
        res = 33'b0;
        
        case (aluc)
            ADD, ADDU: begin
                res = {1'b0, a} + {1'b0, b};
                r = res[31:0];
            end
            SUB, SUBU: begin
                res = {1'b0, a} - {1'b0, b};
                r = res[31:0];
            end
            AND: r = a & b;
            OR:  r = a | b;
            XOR: r = a ^ b;
            NOR: r = ~(a | b);
            SLT: begin
                flag = (signed_a < signed_b);
                r = flag;
            end
            SLTU: begin
                flag = (a < b);
                r = flag;
            end
            SLL:  r = b << shift_amount;
            SRL:  r = b >> shift_amount;
            SRA:  r = $signed(b) >>> shift_amount;
            SLLV: r = b << shift_amount;
            SRLV: r = b >> shift_amount;
            SRAV: r = $signed(b) >>> shift_amount;
            LUI:  r = {b[15:0], 16'b0};
            default: r = 32'bz;
        endcase
    end
endmodule
