module cla_16bit(
    input [16:1] A,
    input [16:1] B,
    input Cin,
    output [16:1] S,
    output Cout
);
    wire [16:0] c;
    wire [16:1] g, p;
    
    assign c[0] = Cin;
    
    // Generate propagate and generate signals
    genvar i;
    generate
        for (i = 1; i <= 16; i = i + 1) begin
            assign g[i] = A[i] & B[i];
            assign p[i] = A[i] | B[i];
        end
    endgenerate
    
    // Carry lookahead logic
    generate
        for (i = 1; i <= 16; i = i + 1) begin
            assign c[i] = g[i] | (p[i] & c[i-1]);
        end
    endgenerate
    
    // Sum calculation
    generate
        for (i = 1; i <= 16; i = i + 1) begin
            assign S[i] = A[i] ^ B[i] ^ c[i-1];
        end
    endgenerate
    
    assign Cout = c[16];
endmodule

module adder_32bit(
    input [32:1] A,
    input [32:1] B,
    output [32:1] S,
    output C32
);
    wire carry16;
    
    // Lower 16 bits
    cla_16bit lower_adder(
        .A(A[16:1]),
        .B(B[16:1]),
        .Cin(1'b0),
        .S(S[16:1]),
        .Cout(carry16)
    );
    
    // Upper 16 bits
    cla_16bit upper_adder(
        .A(A[32:17]),
        .B(B[32:17]),
        .Cin(carry16),
        .S(S[32:17]),
        .Cout(C32)
    );
endmodule
