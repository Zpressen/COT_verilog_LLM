module adder_16bit (
    input [16:1] A,
    input [16:1] B,
    input C0,
    output [16:1] S,
    output G,
    output P,
    output C16
);

    wire [16:0] C;
    wire [16:1] G_gen;
    wire [16:1] P_prop;
    
    assign C[0] = C0;
    
    // Generate and Propagate for each bit
    genvar i;
    generate
        for (i = 1; i <= 16; i = i + 1) begin : gen_cla
            assign G_gen[i] = A[i] & B[i];
            assign P_prop[i] = A[i] ^ B[i];
            assign S[i] = P_prop[i] ^ C[i-1];
        end
    endgenerate
    
    // Carry lookahead logic
    assign C[1] = G_gen[1] | (P_prop[1] & C[0]);
    assign C[2] = G_gen[2] | (P_prop[2] & G_gen[1]) | (P_prop[2] & P_prop[1] & C[0]);
    assign C[3] = G_gen[3] | (P_prop[3] & G_gen[2]) | (P_prop[3] & P_prop[2] & G_gen[1]) | (P_prop[3] & P_prop[2] & P_prop[1] & C[0]);
    assign C[4] = G_gen[4] | (P_prop[4] & G_gen[3]) | (P_prop[4] & P_prop[3] & G_gen[2]) | 
                  (P_prop[4] & P_prop[3] & P_prop[2] & G_gen[1]) | (P_prop[4] & P_prop[3] & P_prop[2] & P_prop[1] & C[0]);
    
    // Group Generate and Propagate
    assign G = G_gen[4] | (P_prop[4] & G_gen[3]) | (P_prop[4] & P_prop[3] & G_gen[2]) | 
               (P_prop[4] & P_prop[3] & P_prop[2] & G_gen[1]);
    assign P = P_prop[4] & P_prop[3] & P_prop[2] & P_prop[1];
    
    // Higher bits use the same pattern
    assign C[5] = G_gen[5] | (P_prop[5] & C[4]);
    assign C[6] = G_gen[6] | (P_prop[6] & G_gen[5]) | (P_prop[6] & P_prop[5] & C[4]);
    assign C[7] = G_gen[7] | (P_prop[7] & G_gen[6]) | (P_prop[7] & P_prop[6] & G_gen[5]) | (P_prop[7] & P_prop[6] & P_prop[5] & C[4]);
    assign C[8] = G_gen[8] | (P_prop[8] & G_gen[7]) | (P_prop[8] & P_prop[7] & G_gen[6]) | 
                  (P_prop[8] & P_prop[7] & P_prop[6] & G_gen[5]) | (P_prop[8] & P_prop[7] & P_prop[6] & P_prop[5] & C[4]);
    
    assign C[9] = G_gen[9] | (P_prop[9] & C[8]);
    assign C[10] = G_gen[10] | (P_prop[10] & G_gen[9]) | (P_prop[10] & P_prop[9] & C[8]);
    assign C[11] = G_gen[11] | (P_prop[11] & G_gen[10]) | (P_prop[11] & P_prop[10] & G_gen[9]) | (P_prop[11] & P_prop[10] & P_prop[9] & C[8]);
    assign C[12] = G_gen[12] | (P_prop[12] & G_gen[11]) | (P_prop[12] & P_prop[11] & G_gen[10]) | 
                   (P_prop[12] & P_prop[11] & P_prop[10] & G_gen[9]) | (P_prop[12] & P_prop[11] & P_prop[10] & P_prop[9] & C[8]);
    
    assign C[13] = G_gen[13] | (P_prop[13] & C[12]);
    assign C[14] = G_gen[14] | (P_prop[14] & G_gen[13]) | (P_prop[14] & P_prop[13] & C[12]);
    assign C[15] = G_gen[15] | (P_prop[15] & G_gen[14]) | (P_prop[15] & P_prop[14] & G_gen[13]) | (P_prop[15] & P_prop[14] & P_prop[13] & C[12]);
    assign C[16] = G_gen[16] | (P_prop[16] & G_gen[15]) | (P_prop[16] & P_prop[15] & G_gen[14]) | 
                   (P_prop[16] & P_prop[15] & P_prop[14] & G_gen[13]) | (P_prop[16] & P_prop[15] & P_prop[14] & P_prop[13] & C[12]);
    
    assign C16 = C[16];
    
endmodule

module adder_32bit (
    input [32:1] A,
    input [32:1] B,
    output [32:1] S,
    output C32
);

    wire G0, P0, G1, P1;
    wire C16;
    
    // First 16-bit CLA block
    adder_16bit cla0 (
        .A(A[16:1]),
        .B(B[16:1]),
        .C0(1'b0),
        .S(S[16:1]),
        .G(G0),
        .P(P0),
        .C16(C16)
    );
    
    // Second 16-bit CLA block
    adder_16bit cla1 (
        .A(A[32:17]),
        .B(B[32:17]),
        .C0(C16),
        .S(S[32:17]),
        .G(G1),
        .P(P1),
        .C16(C32)
    );
    
endmodule
