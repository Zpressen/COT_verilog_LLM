module clau_16(
    input [16:1] A,
    input [16:1] B,
    input Cin,
    output [16:1] S,
    output Cout,
    output GG,
    output PG
);

wire [16:1] G, P;
wire [16:0] C_real, C_gg;

assign G = A & B;
assign P = A ^ B;

assign C_real[0] = Cin;
assign C_gg[0] = 1'b0;

generate
    integer i;
    for (i=1; i<=16; i=i+1) begin : carry_real_gen
        assign C_real[i] = G[i] | (P[i] & C_real[i-1]);
    end
endgenerate

generate
    integer i;
    for (i=1; i<=16; i=i+1) begin : carry_gg_gen
        assign C_gg[i] = G[i] | (P[i] & C_gg[i-1]);
    end
endgenerate

assign Cout = C_real[16];
assign GG = C_gg[16];
assign PG = &P;

generate
    integer i;
    for (i=1; i<=16; i=i+1) begin : sum_gen
        assign S[i] = P[i] ^ C_real[i-1];
    end
endgenerate

endmodule

module adder_32bit(
    input [32:1] A,
    input [32:1] B,
    output [32:1] S,
    output C32
);

wire GG0, PG0, GG1, PG1;
wire C1;

clau_16 u0 (
    .A(A[16:1]),
    .B(B[16:1]),
    .Cin(1'b0),
    .S(S[16:1]),
    .Cout(C1),
    .GG(GG0),
    .PG(PG0)
);

clau_16 u1 (
    .A(A[32:17]),
    .B(B[32:17]),
    .Cin(C1),
    .S(S[32:17]),
    .Cout(C32),
    .GG(GG1),
    .PG(PG1)
);

endmodule
