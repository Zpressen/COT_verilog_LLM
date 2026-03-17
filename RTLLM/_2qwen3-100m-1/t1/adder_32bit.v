module adder_4bit_cla (
    input [4:1] A,
    input [4:1] B,
    input Cin,
    output [4:1] S,
    output Cout,
    output G,
    output P
);

wire [4:1] g = A & B;
wire [4:1] p = A ^ B;

wire c1 = g[1] | (p[1] & Cin);
wire c2 = g[2] | (p[2] & g[1]) | (p[2] & p[1] & Cin);
wire c3 = g[3] | (p[3] & g[2]) | (p[3] & p[2] & g[1]) | (p[3] & p[2] & p[1] & Cin);
wire c4 = g[4] | (p[4] & g[3]) | (p[4] & p[3] & g[2]) | (p[4] & p[3] & p[2] & g[1]) | (p[4] & p[3] & p[2] & p[1] & Cin);

assign S[1] = p[1] ^ Cin;
assign S[2] = p[2] ^ c1;
assign S[3] = p[3] ^ c2;
assign S[4] = p[4] ^ c3;

assign Cout = c4;
assign G = g[4] | (p[4] & g[3]) | (p[4] & p[3] & g[2]) | (p[4] & p[3] & p[2] & g[1]);
assign P = p[4] & p[3] & p[2] & p[1];

endmodule

module adder_16bit_cla (
    input [16:1] A,
    input [16:1] B,
    input Cin,
    output [16:1] S,
    output Cout
);

wire [4:1] A1 = A[4:1];
wire [4:1] A2 = A[8:5];
wire [4:1] A3 = A[12:9];
wire [4:1] A4 = A[16:13];

wire [4:1] B1 = B[4:1];
wire [4:1] B2 = B[8:5];
wire [4:1] B3 = B[12:9];
wire [4:1] B4 = B[16:13];

wire [4:1] S1, S2, S3, S4;
wire C1, C2, C3, C4;
wire G1, P1, G2, P2, G3, P3, G4, P4;

adder_4bit_cla u1 (
    .A(A1),
    .B(B1),
    .Cin(Cin),
    .S(S1),
    .Cout(C1),
    .G(G1),
    .P(P1)
);

adder_4bit_cla u2 (
    .A(A2),
    .B(B2),
    .Cin(C1),
    .S(S2),
    .Cout(C2),
    .G(G2),
    .P(P2)
);

adder_4bit_cla u3 (
    .A(A3),
    .B(B3),
    .Cin(C2),
    .S(S3),
    .Cout(C3),
    .G(G3),
    .P(P3)
);

adder_4bit_cla u4 (
    .A(A4),
    .B(B4),
    .Cin(C3),
    .S(S4),
    .Cout(C4),
    .G(G4),
    .P(P4)
);

assign S[4:1] = S1;
assign S[8:5] = S2;
assign S[12:9] = S3;
assign S[16:13] = S4;
assign Cout = C4;

endmodule

module adder_32bit (
    input [32:1] A,
    input [32:1] B,
    output [32:1] S,
    output C32
);

wire C16;

adder_16bit_cla u1 (
    .A(A[16:1]),
    .B(B[16:1]),
    .Cin(1'b0),
    .S(S[16:1]),
    .Cout(C16)
);

adder_16bit_cla u2 (
    .A(A[32:17]),
    .B(B[32:17]),
    .Cin(C16),
    .S(S[32:17]),
    .Cout(C32)
);

endmodule
