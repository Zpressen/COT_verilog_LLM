module adder_16bit (
    input [16:1] A,
    input [16:1] B,
    input Cin,
    output [16:1] S,
    output Cout,
    output G,
    output P
);

    wire [15:0] g, p;
    assign g = A & B;
    assign p = A ^ B;
    
    wire [16:0] c;
    assign c[0] = Cin;
    
    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : carry_gen
            assign c[i+1] = g[i] | (p[i] & c[i]);
        end
    endgenerate
    
    assign Cout = c[16];
    assign S = A ^ B ^ {16{Cin}} ^ {c[1:16]};
    assign P = &p;
    assign G = |g;
endmodule

module adder_32bit(
    input [32:1] A,
    input [32:1] B,
    output [32:1] S,
    output C32
);

    wire C16;
    wire G0, P0, G1, P1;

    adder_16bit u0 (
        .A(A[16:1]),
        .B(B[16:1]),
        .Cin(1'b0),
        .S(S[16:1]),
        .Cout(C16),
        .G(G0),
        .P(P0)
    );

    adder_16bit u1 (
        .A(A[32:17]),
        .B(B[32:17]),
        .Cin(C16),
        .S(S[32:17]),
        .Cout(C32),
        .G(G1),
        .P(P1)
    );

endmodule
