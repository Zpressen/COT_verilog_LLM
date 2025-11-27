module adder_4bit (
    input [3:0] A,
    input [3:0] B,
    input Cin,
    output [3:0] S,
    output Pg,
    output Gg
);
    wire [3:0] P, G;
    wire [3:0] C;
    
    // Generate P and G for each bit
    assign P = A ^ B;
    assign G = A & B;
    
    // Carry lookahead logic
    assign C[0] = Cin;
    assign C[1] = G[0] | (P[0] & C[0]);
    assign C[2] = G[1] | (P[1] & G[0]) | (P[1] & P[0] & C[0]);
    assign C[3] = G[2] | (P[2] & G[1]) | (P[2] & P[1] & G[0]) | (P[2] & P[1] & P[0] & C[0]);
    
    // Sum calculation
    assign S = P ^ C;
    
    // Group propagate and generate
    assign Pg = &P;
    assign Gg = G[3] | (P[3] & G[2]) | (P[3] & P[2] & G[1]) | (P[3] & P[2] & P[1] & G[0]);
endmodule

module adder_16bit (
    input [15:0] A,
    input [15:0] B,
    input Cin,
    output [15:0] S,
    output Cout
);
    wire [3:0] Pg, Gg;
    wire [3:0] C;
    
    // First level carry signals
    assign C[0] = Cin;
    
    // Instantiate four 4-bit CLA blocks
    adder_4bit cla0 (.A(A[3:0]), .B(B[3:0]), .Cin(C[0]), .S(S[3:0]), .Pg(Pg[0]), .Gg(Gg[0]));
    adder_4bit cla1 (.A(A[7:4]), .B(B[7:4]), .Cin(C[1]), .S(S[7:4]), .Pg(Pg[1]), .Gg(Gg[1]));
    adder_4bit cla2 (.A(A[11:8]), .B(B[11:8]), .Cin(C[2]), .S(S[11:8]), .Pg(Pg[2]), .Gg(Gg[2]));
    adder_4bit cla3 (.A(A[15:12]), .B(B[15:12]), .Cin(C[3]), .S(S[15:12]), .Pg(Pg[3]), .Gg(Gg[3]));
    
    // Carry lookahead for 16-bit level
    assign C[1] = Gg[0] | (Pg[0] & C[0]);
    assign C[2] = Gg[1] | (Pg[1] & Gg[0]) | (Pg[1] & Pg[0] & C[0]);
    assign C[3] = Gg[2] | (Pg[2] & Gg[1]) | (Pg[2] & Pg[1] & Gg[0]) | (Pg[2] & Pg[1] & Pg[0] & C[0]);
    assign Cout = Gg[3] | (Pg[3] & Gg[2]) | (Pg[3] & Pg[2] & Gg[1]) | (Pg[3] & Pg[2] & Pg[1] & Gg[0]) | 
                 (Pg[3] & Pg[2] & Pg[1] & Pg[0] & C[0]);
endmodule

module adder_32bit (
    input [32:1] A,
    input [32:1] B,
    output [32:1] S,
    output C32
);
    wire carry_16;
    
    // Instantiate two 16-bit CLA blocks
    adder_16bit cla0 (.A(A[16:1]), .B(B[16:1]), .Cin(1'b0), .S(S[16:1]), .Cout(carry_16));
    adder_16bit cla1 (.A(A[32:17]), .B(B[32:17]), .Cin(carry_16), .S(S[32:17]), .Cout(C32));
endmodule
