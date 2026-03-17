module cla_16bit (
    input [16:1] A,
    input [16:1] B,
    input Cin,
    output [16:1] S,
    output Cout,
    output GG,
    output GP
);

wire [16:1] g, p;
assign g = A & B;
assign p = A ^ B;

wire [16:0] G, P;
assign G[0] = 1'b0;
assign P[0] = 1'b1;

genvar i;
generate
    for (i = 1; i <= 16; i = i + 1) begin: gen_g_p
        assign G[i] = g[i] | (p[i] & G[i-1]);
        assign P[i] = p[i] & P[i-1];
    end
endgenerate

assign GG = G[16];
assign GP = P[16];
assign Cout = GG | (GP & Cin);

wire [16:0] C;
assign C[0] = Cin;

generate
    for (i = 1; i <= 16; i = i + 1) begin: gen_s
        assign C[i] = G[i] | (P[i] & Cin);
        assign S[i] = A[i] ^ B[i] ^ C[i-1];
    end
endgenerate

endmodule

module adder_32bit(
    input [32:1] A,
    input [32:1] B,
    output [32:1] S,
    output C32
);

wire GG_lower, GP_lower, GG_upper, GP_upper;
wire [16:1] S_lower, S_upper;

cla_16bit lower_block (
    .A(A[16:1]),
    .B(B[16:1]),
    .Cin(1'b0),
    .S(S_lower),
    .Cout(),
    .GG(GG_lower),
    .GP(GP_lower)
);

cla_16bit upper_block (
    .A(A[32:17]),
    .B(B[32:17]),
    .Cin(GG_lower),
    .S(S_upper),
    .Cout(C32),
    .GG(GG_upper),
    .GP(GP_upper)
);

assign S[16:1] = S_lower;
assign S[32:17] = S_upper;

endmodule
