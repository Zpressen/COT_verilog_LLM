module cla_16bit (
    input [16:1] A,
    input [16:1] B,
    input Cin,
    output [16:1] S,
    output Cout
);

wire [16:1] P, G;
wire [16:1] P_total, G_total;
wire [16:0] C;

genvar i;

generate
    for (i = 1; i <= 16; i = i + 1) begin : gen_p_g
        assign P[i] = A[i] ^ B[i];
        assign G[i] = A[i] & B[i];
    end
endgenerate

generate
    for (i = 1; i <= 16; i = i + 1) begin : gen_p_total
        if (i == 1) begin
            assign P_total[i] = P[i];
        end else begin
            assign P_total[i] = P_total[i-1] & P[i];
        end
    end
endgenerate

generate
    for (i = 1; i <= 16; i = i + 1) begin : gen_g_total
        if (i == 1) begin
            assign G_total[i] = G[i];
        end else begin
            assign G_total[i] = G[i] | (P[i] & G_total[i-1]);
        end
    end
endgenerate

assign C[0] = Cin;

generate
    for (i = 1; i <= 16; i = i + 1) begin : gen_carry
        assign C[i] = G_total[i] | (P_total[i] & C[0]);
    end
endgenerate

generate
    for (i = 1; i <= 16; i = i + 1) begin : gen_sum
        assign S[i] = P[i] ^ C[i-1];
    end
endgenerate

assign Cout = C[16];

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
