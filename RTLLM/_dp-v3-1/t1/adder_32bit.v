module cla_16bit(
    input [16:1] A,
    input [16:1] B,
    input Cin,
    output [16:1] S,
    output P,
    output G,
    output Cout
);
    wire [16:0] c;
    wire [16:1] p, g;
    
    assign c[0] = Cin;
    
    // Generate individual p and g terms
    assign p = A ^ B;
    assign g = A & B;
    
    // Carry lookahead logic
    assign c[1] = g[1] | (p[1] & c[0]);
    assign c[2] = g[2] | (p[2] & g[1]) | (p[2] & p[1] & c[0]);
    assign c[3] = g[3] | (p[3] & g[2]) | (p[3] & p[2] & g[1]) | (p[3] & p[2] & p[1] & c[0]);
    assign c[4] = g[4] | (p[4] & g[3]) | (p[4] & p[3] & g[2]) | (p[4] & p[3] & p[2] & g[1]) | 
                  (p[4] & p[3] & p[2] & p[1] & c[0]);
    
    // Block generate and propagate
    assign G = g[16] | (p[16] & g[15]) | (p[16] & p[15] & g[14]) | (p[16] & p[15] & p[14] & g[13]) |
               (p[16] & p[15] & p[14] & p[13] & g[12]) | (p[16] & p[15] & p[14] & p[13] & p[12] & g[11]) |
               (p[16] & p[15] & p[14] & p[13] & p[12] & p[11] & g[10]) | 
               (p[16] & p[15] & p[14] & p[13] & p[12] & p[11] & p[10] & g[9]) |
               (p[16] & p[15] & p[14] & p[13] & p[12] & p[11] & p[10] & p[9] & g[8]) |
               (p[16] & p[15] & p[14] & p[13] & p[12] & p[11] & p[10] & p[9] & p[8] & g[7]) |
               (p[16] & p[15] & p[14] & p[13] & p[12] & p[11] & p[10] & p[9] & p[8] & p[7] & g[6]) |
               (p[16] & p[15] & p[14] & p[13] & p[12] & p[11] & p[10] & p[9] & p[8] & p[7] & p[6] & g[5]) |
               (p[16] & p[15] & p[14] & p[13] & p[12] & p[11] & p[10] & p[9] & p[8] & p[7] & p[6] & p[5] & g[4]);
    
    assign P = &p;
    
    // Generate remaining carries using hierarchical lookahead
    genvar i;
    generate
        for (i = 5; i <= 16; i = i + 1) begin
            assign c[i] = g[i] | (p[i] & c[i-1]);
        end
    endgenerate
    
    // Generate sum bits
    assign S = p ^ c[15:0];
    assign Cout = c[16];
endmodule

module adder_32bit(
    input [32:1] A,
    input [32:1] B,
    output [32:1] S,
    output C32
);
    wire [16:1] S_low, S_high;
    wire P0, G0, P1, G1;
    wire C16;
    
    // First 16-bit CLA (bits 1-16)
    cla_16bit cla_low (
        .A(A[16:1]),
        .B(B[16:1]),
        .Cin(1'b0),
        .S(S_low),
        .P(P0),
        .G(G0),
        .Cout(C16)
    );
    
    // Second 16-bit CLA (bits 17-32)
    cla_16bit cla_high (
        .A(A[32:17]),
        .B(B[32:17]),
        .Cin(C16),
        .S(S_high),
        .P(P1),
        .G(G1),
        .Cout(C32)
    );
    
    // Combine sum outputs
    assign S = {S_high, S_low};
endmodule
