module cla_16bit(
    input [16:1] A,
    input [16:1] B,
    input C0,
    output [16:1] S,
    output G,
    output P,
    output C16
);
    wire [4:1] Pg, Gg;  // Group propagate and generate
    wire [4:1] C;        // Carry between groups
    
    assign C[1] = C0;
    
    // Generate 4-bit CLA blocks
    genvar i;
    generate
        for (i = 1; i <= 4; i = i + 1) begin : cla_blocks
            wire [3:0] p, g;
            wire [3:0] carry;
            wire [3:0] sum;
            
            // Calculate bit-wise p and g
            assign p = A[(i*4)-:4] ^ B[(i*4)-:4];
            assign g = A[(i*4)-:4] & B[(i*4)-:4];
            
            // Calculate group P and G
            assign Pg[i] = &p;
            assign Gg[i] = g[3] | (p[3] & g[2]) | (p[3] & p[2] & g[1]) | (p[3] & p[2] & p[1] & g[0]);
            
            // Calculate carries
            assign carry[0] = C[i-1];
            assign carry[1] = g[0] | (p[0] & carry[0]);
            assign carry[2] = g[1] | (p[1] & g[0]) | (p[1] & p[0] & carry[0]);
            assign carry[3] = g[2] | (p[2] & g[1]) | (p[2] & p[1] & g[0]) | 
                             (p[2] & p[1] & p[0] & carry[0]);
            
            // Calculate sum
            assign sum = p ^ {carry[2:0], carry[0]};
            assign S[(i*4)-:4] = sum;
            
            // Calculate next group carry
            if (i < 4) begin
                assign C[i+1] = Gg[i] | (Pg[i] & C[i]);
            end
        end
    endgenerate
    
    // Final carry out
    assign C16 = C[4];
    assign G = Gg[4];
    assign P = Pg[4];
endmodule

module adder_32bit(
    input [32:1] A,
    input [32:1] B,
    output [32:1] S,
    output C32
);
    wire C0 = 1'b0;  // Initial carry-in
    wire C16;        // Carry between 16-bit blocks
    wire G0, P0;     // Generate/Propagate from first block
    wire G1, P1;     // Generate/Propagate from second block
    
    // First 16-bit CLA (bits 1-16)
    cla_16bit cla0(
        .A(A[16:1]),
        .B(B[16:1]),
        .C0(C0),
        .S(S[16:1]),
        .G(G0),
        .P(P0),
        .C16(C16)
    );
    
    // Second 16-bit CLA (bits 17-32)
    cla_16bit cla1(
        .A(A[32:17]),
        .B(B[32:17]),
        .C0(C16),
        .S(S[32:17]),
        .G(G1),
        .P(P1),
        .C16(C32)
    );
endmodule
