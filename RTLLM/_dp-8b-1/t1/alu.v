module alu(
    input [31:0] a,
    input [31:0] b,
    input [5:0] aluc,
    output reg [31:0] r,
    output zero,
    output reg carry,
    output negative,
    output reg overflow,
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
    reg [32:0] res;  // 33-bit to capture carry
    wire signed [31:0] a_signed = a;
    wire signed [31:0] b_signed = b;

    // Zero flag
    assign zero = (r == 32'b0);
    
    // Negative flag
    assign negative = r[31];

    always @(*) begin
        carry = 0;
        overflow = 0;
        flag = 1'bz;  // Default high-impedance
        
        case (aluc)
            ADD: begin
                res = {a_signed[31], a_signed} + {b_signed[31], b_signed};
                r = res[31:0];
                carry = res[32];
                overflow = (a_signed[31] == b_signed[31]) && (res[31] != a_signed[31]);
            end
            
            ADDU: begin
                res = {1'b0, a} + {1'b0, b};
                r = res[31:0];
                carry = res[32];
            end
            
            SUB: begin
                res = {a_signed[31], a_signed} - {b_signed[31], b_signed};
                r = res[31:0];
                carry = res[32];
                overflow = (a_signed[31] != b_signed[31]) && (res[31] != a_signed[31]);
            end
            
            SUBU: begin
                res = {1'b0, a} - {1'b0, b};
                r = res[31:0];
                carry = res[32];
            end
            
            AND: begin
                r = a & b;
            end
            
            OR: begin
                r = a | b;
            end
            
            XOR: begin
                r = a ^ b;
            end
            
            NOR: begin
                r = ~(a | b);
            end
            
            SLT: begin
                flag = (a_signed < b_signed);
                r = {31'b0, flag};
            end
            
            SLTU: begin
                flag = (a < b);
                r = {31'b0, flag};
            end
            
            SLL: begin
                r = b << a[4:0];
            end
            
            SRL: begin
                r = b >> a[4:0];
            end
            
            SRA: begin
                r = $signed(b) >>> a[4:0];
            end
            
            SLLV: begin
                r = b << a[4:0];
            end
            
            SRLV: begin
                r = b >> a[4:0];
            end
            
            SRAV: begin
                r = $signed(b) >>> a[4:0];
            end
            
            LUI: begin
                r = {b[15:0], 16'b0};
            end
            
            default: begin
                r = 32'bz;
            end
        endcase
    end

endmodule
