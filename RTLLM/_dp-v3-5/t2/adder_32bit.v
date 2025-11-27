module cla_4bit(
    input [3:0] A,
    input [3:0] B,
    input Cin,
    output [3:0] S,
    output Pg,
    output Gg
);
    wire [3:0] P, G;
    wire [3:0] C;
    
    assign P = A ^ B;
    assign G = A & B;
    
    assign C[0] = Cin;
    assign C[1] = G[0] | (P[0] & C[0]);
    assign C[2] = G[1] | (P[1] & G[0]) | (P[1] & P[0] & C[0]);
    assign C[3] = G[2] | (P[2] & G[1]) | (P[2] & P[1] & G[0]) | (P[2] & P[1] & P[0] & C[0]);
    
    assign S = P ^ C;
    
    assign Pg = &P;
    assign Gg = G[3] | (P[3] & G[2]) | (P[3] & P[2] & G[1]) | (P[3] & P[2] & P[1] & G[0]);
endmodule

module cla_16bit(
    input [15:0] A,
    input [15:0] B,
    input Cin,
    output [15:0] S,
    output Cout,
    output Pg,
    output Gg
);
    wire [3:0] P, G;
    wire [4:0] C;
    
    assign C[0] = Cin;
    
    cla_4bit cla0(.A(A[3:0]), .B(B[3:0]), .Cin(C[0]), .S(S[3:0]), .Pg(P[0]), .Gg(G[0]));
    cla_4bit cla1(.A(A[7:4]), .B(B[7:4]), .Cin(C[1]), .S(S[7:4]), .Pg(P[1]), .Gg(G[1]));
    cla_4bit cla2(.A(A[11:8]), .B(B[11:8]), .Cin(C[2]), .S(S[11:8]), .Pg(P[2]), .Gg(G[2]));
    cla_4bit cla3(.A(A[15:12]), .B(B[15:12]), .Cin(C[3]), .S(S[15:12]), .Pg(P[3]), .Gg(G[3]));
    
    assign C[1] = G[0] | (P[0] & C[0]);
    assign C[2] = G[1] | (P[1] & G[0]) | (P[1] & P[0] & C[0]);
    assign C[3] = G[2] | (P[2] & G[1]) | (P[2] & P[1] & G[0]) | (P[2] & P[1] & P[0] & C[0]);
    assign C[4] = G[3] | (P[3] & G[2]) | (P[3] & P[2] & G[1]) | (P[3] & P[2] & P[1] & G[0]) | (P[3] & P[2] & P[1] & P[0] & C[0]);
    
    assign Cout = C[4];
    assign Pg = &P;
    assign Gg = G[3] | (P[3] & G[2]) | (P[3] & P[2] & G[1]) | (P[3] & P[2] & P[1] & G[0]);
endmodule

module adder_32bit(
    input [32:1] A,
    input [32:1] B,
    output [32:1] S,
    output C32
);
    wire [15:0] A_low = A[16:1];
    wire [15:0] B_low = B[16:1];
    wire [15:0] A_high = A[32:17];
    wire [15:0] B_high = B[32:17];
    
    wire [15:0] S_low, S_high;
    wire Cout_low, Pg_low, Gg_low;
    wire Cout_high, Pg_high, Gg_high;
    
    cla_16bit low_adder(
        .A(A_low),
        .B(B_low),
        .Cin(1'b0),
        .S(S_low),
        .Cout(Cout_low),
        .Pg(Pg_low),
        .Gg(Gg_low)
    );
    
    cla_16bit high_adder(
        .A(A_high),
        .B(B_high),
        .Cin(Cout_low),
        .S(S_high),
        .Cout(Cout_high),
        .Pg(Pg_high),
        .Gg(Gg_high)
    );
    
    assign S = {S_high, S_low};
    assign C32 = Cout_high;
endmodule
