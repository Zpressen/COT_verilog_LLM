module cla_16bit (
    input [16:1] A,
    input [16:1] B,
    input Cin,
    output [16:1] S,
    output Cout
);

wire [16:1] P, G;
assign P = A ^ B;
assign G = A & B;

wire GG0 = G[1] | (P[1] & G[2]) | (P[1] & P[2] & G[3]) | (P[1] & P[2] & P[3] & G[4]);
wire GP0 = P[1] & P[2] & P[3] & P[4];
wire C0_out = GG0 | (GP0 & Cin);

wire C1_in = Cin;
wire C2_in = G[1] | (P[1] & C1_in);
wire C3_in = G[2] | (P[2] & C2_in);
wire C4_in = G[3] | (P[3] & C3_in);

wire GG1 = G[5] | (P[5] & G[6]) | (P[5] & P[6] & G[7]) | (P[5] & P[6] & P[7] & G[8]);
wire GP1 = P[5] & P[6] & P[7] & P[8];
wire C1_out = GG1 | (GP1 & C0_out);

wire C5_in = C0_out;
wire C6_in = G[5] | (P[5] & C5_in);
wire C7_in = G[6] | (P[6] & C6_in);
wire C8_in = G[7] | (P[7] & C7_in);

wire GG2 = G[9] | (P[9] & G[10]) | (P[9] & P[10] & G[11]) | (P[9] & P[10] & P[11] & G[12]);
wire GP2 = P[9] & P[10] & P[11] & P[12];
wire C2_out = GG2 | (GP2 & C1_out);

wire C9_in = C1_out;
wire C10_in = G[9] | (P[9] & C9_in);
wire C11_in = G[10] | (P[10] & C10_in);
wire C12_in = G[11] | (P[11] & C11_in);

wire GG3 = G[13] | (P[13] & G[14]) | (P[13] & P[14] & G[15]) | (P[13] & P[14] & P[15] & G[16]);
wire GP3 = P[13] & P[14] & P[15] & P[16];
wire C3_out = GG3 | (GP3 & C2_out);

wire C13_in = C2_out;
wire C14_in = G[13] | (P[13] & C13_in);
wire C15_in = G[14] | (P[14] & C14_in);
wire C16_in = G[15] | (P[15] & C15_in);

assign S[1] = P[1] ^ C1_in;
assign S[2] = P[2] ^ C2_in;
assign S[3] = P[3] ^ C3_in;
assign S[4] = P[4] ^ C4_in;

assign S[5] = P[5] ^ C5_in;
assign S[6] = P[6] ^ C6_in;
assign S[7] = P[7] ^ C7_in;
assign S[8] = P[8] ^ C8_in;

assign S[9] = P[9] ^ C9_in;
assign S[10] = P[10] ^ C10_in;
assign S[11] = P[11] ^ C11_in;
assign S[12] = P[12] ^ C12_in;

assign S[13] = P[13] ^ C13_in;
assign S[14] = P[14] ^ C14_in;
assign S[15] = P[15] ^ C15_in;
assign S[16] = P[16] ^ C16_in;

assign Cout = C3_out;

endmodule

module adder_32bit (
    input [32:1] A,
    input [32:1] B,
    output [32:1] S,
    output C32
);

wire C16;

cla_16bit u1 (
    .A(A[16:1]),
    .B(B[16:1]),
    .Cin(1'b0),
    .S(S[16:1]),
    .Cout(C16)
);

cla_16bit u2 (
    .A(A[32:17]),
    .B(B[32:17]),
    .Cin(C16),
    .S(S[32:17]),
    .Cout(C32)
);

endmodule
