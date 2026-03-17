module cla_4bit (
    input [4:1] A,
    input [4:1] B,
    input C0,
    output [4:1] S,
    output C4,
    output GG,
    output GP
);

wire [4:1] G, P;
assign G = A & B;
assign P = A ^ B;

wire C1, C2, C3;

assign C1 = G[1] | (P[1] & C0);
assign C2 = G[2] | (P[2] & (G[1] | (P[1] & C0)));
assign C3 = G[3] | (P[3] & (G[2] | (P[2] & (G[1] | (P[1] & C0)))));
assign C4 = G[4] | (P[4] & (G[3] | (P[3] & (G[2] | (P[2] & (G[1] | (P[1] & C0)))))));

assign S[1] = P[1] ^ C0;
assign S[2] = P[2] ^ C1;
assign S[3] = P[3] ^ C2;
assign S[4] = P[4] ^ C3;

assign GG = G[4] | (P[4] & G[3]) | (P[4] & P[3] & G[2]) | (P[4] & P[3] & P[2] & G[1]);
assign GP = P[1] & P[2] & P[3] & P[4];

endmodule

module cla_16bit (
    input [16:1] A,
    input [16:1] B,
    input C0,
    output [16:1] S,
    output C16,
    output GG,
    output GP
);

wire [4:1] S1, S2, S3, S4;
wire C4, C8, C12;
wire GG1, GP1, GG2, GP2, GG3, GP3, GG4, GP4;

cla_4bit u1 (
    .A(A[4:1]),
    .B(B[4:1]),
    .C0(C0),
    .S(S1),
    .C4(C4),
    .GG(GG1),
    .GP(GP1)
);

cla_4bit u2 (
    .A(A[8:5]),
    .B(B[8:5]),
    .C0(C4),
    .S(S2),
    .C4(C8),
    .GG(GG2),
    .GP(GP2)
);

cla_4bit u3 (
    .A(A[12:9]),
    .B(B[12:9]),
    .C0(C8),
    .S(S3),
    .C4(C12),
    .GG(GG3),
    .GP(GP3)
);

cla_4bit u4 (
    .A(A[16:13]),
    .B(B[16:13]),
    .C0(C12),
    .S(S4),
    .C4(C16),
    .GG(GG4),
    .GP(GP4)
);

assign S[4:1] = S1;
assign S[8:5] = S2;
assign S[12:9] = S3;
assign S[16:13] = S4;

assign GG = GG1 | (GP1 & GG2) | (GP1 & GP2 & GG3) | (GP1 & GP2 & GP3 & GG4);
assign GP = GP1 & GP2 & GP3 & GP4;

endmodule

module adder_32bit (
    input [32:1] A,
    input [32:1] B,
    output [32:1] S,
    output C32
);

wire C16;

cla_16bit lower (
    .A(A[16:1]),
    .B(B[16:1]),
    .C0(1'b0),
    .S(S[16:1]),
    .C16(C16),
    .GG(),
    .GP()
);

cla_16bit upper (
    .A(A[32:17]),
    .B(B[32:17]),
    .C0(C16),
    .S(S[32:17]),
    .C16(C32),
    .GG(),
    .GP()
);

endmodule
