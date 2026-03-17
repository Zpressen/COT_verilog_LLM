module cla_16bit (
    input [16:1] A,
    input [16:1] B,
    input Cin,
    output [16:1] S,
    output Cout
);

wire [15:0] g, p;

genvar i;
generate
    for (i = 1; i <= 16; i = i + 1) begin : gen_g_p
        assign g[i-1] = A[i] & B[i];
        assign p[i-1] = A[i] ^ B[i];
    end
endgenerate

wire [16:0] G, P;

assign G[0] = 1'b0;
assign P[0] = 1'b1;

generate
    for (i = 1; i <= 16; i = i + 1) begin : gen_G_P
        assign G[i] = g[i-1] | (p[i-1] & G[i-1]);
        assign P[i] = p[i-1] & P[i-1];
    end
endgenerate

wire [16:0] carry_in;

generate
    for (i = 1; i <= 16; i = i + 1) begin : gen_carry_in
        assign carry_in[i] = G[i] | (P[i] & Cin);
    end
endgenerate

generate
    for (i = 1; i <= 16; i = i + 1) begin : gen_sum
        assign S[i] = A[i] ^ B[i] ^ carry_in[i];
    end
endgenerate

assign Cout = carry_in[16];

endmodule

module adder_32bit (
    input [32:1] A,
    input [32:1] B,
    output [32:1] S,
    output C32
);

wire C16;

cla_16bit lower_block (
    .A(A[16:1]),
    .B(B[16:1]),
    .Cin(1'b0),
    .S(S[16:1]),
    .Cout(C16)
);

cla_16bit upper_block (
    .A(A[32:17]),
    .B(B[32:17]),
    .Cin(C16),
    .S(S[32:17]),
    .Cout(C32)
);

endmodule
