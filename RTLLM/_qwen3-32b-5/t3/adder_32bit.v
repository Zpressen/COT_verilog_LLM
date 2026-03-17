module full_adder_1bit (
    input A,
    input B,
    input Cin,
    output S,
    output G,
    output P
);
    assign G = A & B;
    assign P = A | B;
    assign S = A ^ B ^ Cin;
endmodule

module cla_4bit (
    input [3:0] A,
    input [3:0] B,
    input Cin,
    output [3:0] S,
    output Cout,
    output GG,
    output PG
);

wire g0 = A[0] & B[0];
wire p0 = A[0] | B[0];
wire g1 = A[1] & B[1];
wire p1 = A[1] | B[1];
wire g2 = A[2] & B[2];
wire p2 = A[2] | B[2];
wire g3 = A[3] & B[3];
wire p3 = A[3] | B[3];

wire c1 = g0 | (p0 & Cin);
wire c2 = g1 | (p1 & g0) | (p1 & p0 & Cin);
wire c3 = g2 | (p2 & g1) | (p2 & p1 & g0) | (p2 & p1 & p0 & Cin);
wire c4 = g3 | (p3 & g2) | (p3 & p2 & g1) | (p3 & p2 & p1 & g0) | (p3 & p2 & p1 & p0 & Cin);

assign S[0] = A[0] ^ B[0] ^ Cin;
assign S[1] = A[1] ^ B[1] ^ c1;
assign S[2] = A[2] ^ B[2] ^ c2;
assign S[3] = A[3] ^ B[3] ^ c3;
assign Cout = c4;

assign PG = p0 & p1 & p2 & p3;
assign GG = g3 | (p3 & g2) | (p3 & p2 & g1) | (p3 & p2 & p1 & g0) | (p3 & p2 & p1 & p0);

endmodule

module cla_16bit (
    input [15:0] A,
    input [15:0] B,
    input Cin,
    output [15:0] S,
    output Cout,
    output GG,
    output PG
);

wire c4, c8, c12;

wire GG0, PG0, GG1, PG1, GG2, PG2, GG3, PG3;

cla_4bit u0 (
    .A(A[3:0]),
    .B(B[3:0]),
    .Cin(Cin),
    .S(S[3:0]),
    .Cout(c4),
    .GG(GG0),
    .PG(PG0)
);

cla_4bit u1 (
    .A(A[7:4]),
    .B(B[7:4]),
    .Cin(c4),
    .S(S[7:4]),
    .Cout(c8),
    .GG(GG1),
    .PG(PG1)
);

cla_4bit u2 (
    .A(A[11:8]),
    .B(B[11:8]),
    .Cin(c8),
    .S(S[11:8]),
    .Cout(c12),
    .GG(GG2),
    .PG(PG2)
);

cla_4bit u3 (
    .A(A[15:12]),
    .B(B[15:12]),
    .Cin(c12),
    .S(S[15:12]),
    .Cout(Cout),
    .GG(GG3),
    .PG(PG3)
);

assign PG = PG0 & PG1 & PG2 & PG3;
assign GG = GG3 | (PG3 & GG2) | (PG3 & PG2 & GG1) | (PG3 & PG2 & PG1 & GG0) | (PG3 & PG2 & PG1 & PG0);

endmodule

module adder_32bit (
    input [32:1] A,
    input [32:1] B,
    output [32:1] S,
    output C32
);

wire C16;

wire [15:0] A_lower = A[16:1];
wire [15:0] B_lower = B[16:1];
wire [15:0] A_upper = A[32:17];
wire [15:0] B_upper = B[32:17];

wire [15:0] S_lower, S_upper;

cla_16bit u0 (
    .A(A_lower),
    .B(B_lower),
    .Cin(1'b0),
    .S(S_lower),
    .Cout(C16),
    .GG(),
    .PG()
);

cla_16bit u1 (
    .A(A_upper),
    .B(B_upper),
    .Cin(C16),
    .S(S_upper),
    .Cout(C32),
    .GG(),
    .PG()
);

assign S[16:1] = {>>{S_lower}};
assign S[32:17] = {>>{S_upper}};

endmodule
