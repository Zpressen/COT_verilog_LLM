module adder_16bit (
    input [16:1] A,
    input [16:1] B,
    input C_in,
    output [16:1] S,
    output C_out,
    output GG,
    output GP
);

    wire [15:0] g, p;
    reg [15:0] G, P;
    wire [16:0] C;

    genvar i;
    generate
        for (i = 1; i <= 16; i = i + 1) begin : gen_g_p
            assign g[i-1] = A[i] & B[i];
            assign p[i-1] = A[i] ^ B[i];
        end
    endgenerate

    always_comb begin
        G[0] = g[0];
        P[0] = p[0];
        for (int i = 1; i < 16; i = i + 1) begin
            G[i] = g[i] | (p[i] & G[i-1]);
            P[i] = p[i] & P[i-1];
        end
    end

    assign GG = G[15];
    assign GP = P[15];

    assign C[0] = C_in;
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_carries
            assign C[i+1] = G[i] | (P[i] & C_in);
        end
    endgenerate

    generate
        for (i = 1; i <= 16; i = i + 1) begin : gen_sum
            assign S[i] = p[i-1] ^ C[i];
        end
    endgenerate

    assign C_out = C[16];

endmodule

module adder_32bit (
    input [32:1] A,
    input [32:1] B,
    output [32:1] S,
    output C32
);

    wire [16:1] S_low, S_high;
    wire C16;
    wire GG_low, GP_low, GG_high, GP_high;

    adder_16bit u_lower (
        .A(A[16:1]),
        .B(B[16:1]),
        .C_in(1'b0),
        .S(S_low),
        .C_out(C16),
        .GG(GG_low),
        .GP(GP_low)
    );

    adder_16bit u_upper (
        .A(A[32:17]),
        .B(B[32:17]),
        .C_in(C16),
        .S(S_high),
        .C_out(),
        .GG(GG_high),
        .GP(GP_high)
    );

    assign C32 = GG_high | (GP_high & C16);
    assign S[16:1] = S_low;
    assign S[32:17] = S_high;

endmodule
