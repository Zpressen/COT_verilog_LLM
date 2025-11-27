module div_16bit (
    input  wire [15:0] A,
    input  wire [7:0]  B,
    output reg  [15:0] result,
    output reg  [15:0] odd
);

    reg [15:0] a_reg;
    reg [7:0]  b_reg;

    always @* begin
        a_reg = A;
        b_reg = B;
    end

    always @* begin
        reg [7:0] r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12, r13, r14, r15;
        reg q0, q1, q2, q3, q4, q5, q6, q7, q8, q9, q10, q11, q12, q13, q14, q15;

        r0 = 0;

        // Stage 0: next bit is a_reg[15]
        reg [8:0] current_value0 = {r0, a_reg[15]};
        if (current_value0[8:1] >= b_reg) begin
            q0 = 1'b1;
            r1 = current_value0[8:1] - b_reg;
        end else begin
            q0 = 1'b0;
            r1 = current_value0[8:1];
        end

        // Stage 1: next bit is a_reg[14]
        reg [8:0] current_value1 = {r1, a_reg[14]};
        if (current_value1[8:1] >= b_reg) begin
            q1 = 1'b1;
            r2 = current_value1[8:1] - b_reg;
        end else begin
            q1 = 1'b0;
            r2 = current_value1[8:1];
        end

        // Stage 2: next bit is a_reg[13]
        reg [8:0] current_value2 = {r2, a_reg[13]};
        if (current_value2[8:1] >= b_reg) begin
            q2 = 1'b1;
            r3 = current_value2[8:1] - b_reg;
        end else begin
            q2 = 1'b0;
            r3 = current_value2[8:1];
        end

        // Stage 3: next bit is a_reg[12]
        reg [8:0] current_value3 = {r3, a_reg[12]};
        if (current_value3[8:1] >= b_reg) begin
            q3 = 1'b1;
            r4 = current_value3[8:1] - b_reg;
        end else begin
            q3 = 1'b0;
            r4 = current_value3[8:1];
        end

        // Stage 4: next bit is a_reg[11]
        reg [8:0] current_value4 = {r4, a_reg[11]};
        if (current_value4[8:1] >= b_reg) begin
            q4 = 1'b1;
            r5 = current_value4[8:1] - b_reg;
        end else begin
            q4 = 1'b0;
            r5 = current_value4[8:1];
        end

        // Stage 5: next bit is a_reg[10]
        reg [8:0] current_value5 = {r5, a_reg[10]};
        if (current_value5[8:1] >= b_reg) begin
            q5 = 1'b1;
            r6 = current_value5[8:1] - b_reg;
        end else begin
            q5 = 1'b0;
            r6 = current_value5[8:1];
        end

        // Stage 6: next bit is a_reg[9]
        reg [8:0] current_value6 = {r6, a_reg[9]};
        if (current_value6[8:1] >= b_reg) begin
            q6 = 1'b1;
            r7 = current_value6[8:1] - b_reg;
        end else begin
            q6 = 1'b0;
            r7 = current_value6[8:1];
        end

        // Stage 7: next bit is a_reg[8]
        reg [8:0] current_value7 = {r7, a_reg[8]};
        if (current_value7[8:1] >= b_reg) begin
            q7 = 1'b1;
            r8 = current_value7[8:1] - b_reg;
        end else begin
            q7 = 1'b0;
            r8 = current_value7[8:1];
        end

        // Stage 8: next bit is a_reg[7]
        reg [8:0] current_value8 = {r8, a_reg[7]};
        if (current_value8[8:1] >= b_reg) begin
            q8 = 1'b1;
            r9 = current_value8[8:1] - b_reg;
        end else begin
            q8 = 1'b0;
            r9 = current_value8[8:1];
        end

        // Stage 9: next bit is a_reg[6]
        reg [8:0] current_value9 = {r9, a_reg[6]};
        if (current_value9[8:1] >= b_reg) begin
            q9 = 1'b1;
            r10 = current_value9[8:1] - b_reg;
        end else begin
            q9 = 1'b0;
            r10 = current_value9[8:1];
        end

        // Stage 10: next bit is a_reg[5]
        reg [8:0] current_value10 = {r10, a_reg[5]};
        if (current_value10[8:1] >= b_reg) begin
            q10 = 1'b1;
            r11 = current_value10[8:1] - b_reg;
        end else begin
            q10 = 1'b0;
            r11 = current_value10[8:1];
        end

        // Stage 11: next bit is a_reg[4]
        reg [8:0] current_value11 = {r11, a_reg[4]};
        if (current_value11[8:1] >= b_reg) begin
            q11 = 1'b1;
            r12 = current_value11[8:1] - b_reg;
        end else begin
            q11 = 1'b0;
            r12 = current_value11[8:1];
        end

        // Stage 12: next bit is a_reg[3]
        reg [8:0] current_value12 = {r12, a_reg[3]};
        if (current_value12[8:1] >= b_reg) begin
            q12 = 1'b1;
            r13 = current_value12[8:1] - b_reg;
        end else begin
            q12 = 1'b0;
            r13 = current_value12[8:1];
        end

        // Stage 13: next bit is a_reg[2]
        reg [8:0] current_value13 = {r13, a_reg[2]};
        if (current_value13[8:1] >= b_reg) begin
            q13 = 1'b1;
            r14 = current_value13[8:1] - b_reg;
        end else begin
            q13 = 1'b0;
            r14 = current_value13[8:1];
        end

        // Stage 14: next bit is a_reg[1]
        reg [8:0] current_value14 = {r14, a_reg[1]};
        if (current_value14[8:1] >= b_reg) begin
            q14 = 1'b1;
            r15 = current_value14[8:1] - b_reg;
        end else begin
            q14 = 1'b0;
            r15 = current_value14[8:1];
        end

        // Stage 15: next bit is a_reg[0]
        reg [8:0] current_value15 = {r15, a_reg[0]};
        if (current_value15[8:1] >= b_reg) begin
            q15 = 1'b1;
            // r16 is not used
        end else begin
            q15 = 1'b0;
        end

        // Assign the quotient and remainder.
        result = {q0, q1, q2, q3, q4, q5, q6, q7, q8, q9, q10, q11, q12, q13, q14, q15};
        odd = {8'b0, r15};
    end

endmodule
