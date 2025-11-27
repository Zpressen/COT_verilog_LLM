module div_16bit (
    input  [15:0] A,
    input  [7:0]  B,
    output [15:0] result,
    output [15:0] odd
);

    reg [15:0] a_reg;
    reg [7:0]  b_reg;

    always @* begin
        a_reg = A;
        b_reg = B;
    end

    reg [7:0]  current_remainder;
    reg [15:0] quotient;
    reg [15:0] remainder;

    always @* begin
        current_remainder = a_reg[15:8];
        quotient = 0;
        remainder = 0;

        // Step 0: Process A[7]
        if (current_remainder >= b_reg) begin
            quotient = {quotient[15:1], 1'b1};
            current_remainder = current_remainder - b_reg;
        end else begin
            quotient = {quotient[15:1], 1'b0};
        end
        current_remainder = {current_remainder[7:1], A[7]};
        remainder = {remainder[15:1], current_remainder[7]};

        // Step 1: Process A[6]
        if (current_remainder >= b_reg) begin
            quotient = {quotient[15:1], 1'b1};
            current_remainder = current_remainder - b_reg;
        end else begin
            quotient = {quotient[15:1], 1'b0};
        end
        current_remainder = {current_remainder[7:1], A[6]};
        remainder = {remainder[15:1], current_remainder[7]};

        // Step 2: Process A[5]
        if (current_remainder >= b_reg) begin
            quotient = {quotient[15:1], 1'b1};
            current_remainder = current_remainder - b_reg;
        end else begin
            quotient = {quotient[15:1], 1'b0};
        end
        current_remainder = {current_remainder[7:1], A[5]};
        remainder = {remainder[15:1], current_remainder[7]};

        // Step 3: Process A[4]
        if (current_remainder >= b_reg) begin
            quotient = {quotient[15:1], 1'b1};
            current_remainder = current_remainder - b_reg;
        end else begin
            quotient = {quotient[15:1], 1'b0};
        end
        current_remainder = {current_remainder[7:1], A[4]};
        remainder = {remainder[15:1], current_remainder[7]};

        // Step 4: Process A[3]
        if (current_remainder >= b_reg) begin
            quotient = {quotient[15:1], 1'b1};
            current_remainder = current_remainder - b_reg;
        end else begin
            quotient = {quotient[15:1], 1'b0};
        end
        current_remainder = {current_remainder[7:1], A[3]};
        remainder = {remainder[15:1], current_remainder[7]};

        // Step 5: Process A[2]
        if (current_remainder >= b_reg) begin
            quotient = {quotient[15:1], 1'b1};
            current_remainder = current_remainder - b_reg;
        end else begin
            quotient = {quotient[15:1], 1'b0};
        end
        current_remainder = {current_remainder[7:1], A[2]};
        remainder = {remainder[15:1], current_remainder[7]};

        // Step 6: Process A[1]
        if (current_remainder >= b_reg) begin
            quotient = {quotient[15:1], 1'b1};
            current_remainder = current_remainder - b_reg;
        end else begin
            quotient = {quotient[15:1], 1'b0};
        end
        current_remainder = {current_remainder[7:1], A[1]};
        remainder = {remainder[15:1], current_remainder[7]};

        // Step 7: Process A[0]
        if (current_remainder >= b_reg) begin
            quotient = {quotient[15:1], 1'b1};
            current_remainder = current_remainder - b_reg;
        end else begin
            quotient = {quotient[15:1], 1'b0};
        end
        current_remainder = {current_remainder[7:1], A[0]};
        remainder = {remainder[15:1], current_remainder[7]};

        // Steps 8-15: No more bits to process, shift in 0
        // Step 8
        if (current_remainder >= b_reg) begin
            quotient = {quotient[15:1], 1'b1};
            current_remainder = current_remainder - b_reg;
        end else begin
            quotient = {quotient[15:1], 1'b0};
        end
        current_remainder = {current_remainder[7:1], 1'b0};
        remainder = {remainder[15:1], current_remainder[7]};

        // Step 9
        if (current_remainder >= b_reg) begin
            quotient = {quotient[15:1], 1'b1};
            current_remainder = current_remainder - b_reg;
        end else begin
            quotient = {quotient[15:1], 1'b0};
        end
        current_remainder = {current_remainder[7:1], 1'b0};
        remainder = {remainder[15:1], current_remainder[7]};

        // Step 10
        if (current_remainder >= b_reg) begin
            quotient = {quotient[15:1], 1'b1};
            current_remainder = current_remainder - b_reg;
        end else begin
            quotient = {quotient[15:1], 1'b0};
        end
        current_remainder = {current_remainder[7:1], 1'b0};
        remainder = {remainder[15:1], current_remainder[7]};

        // Step 11
        if (current_remainder >= b_reg) begin
            quotient = {quotient[15:1], 1'b1};
            current_remainder = current_remainder - b_reg;
        end else begin
            quotient = {quotient[15:1], 1'b0};
        end
        current_remainder = {current_remainder[7:1], 1'b0};
        remainder = {remainder[15:1], current_remainder[7]};

        // Step 12
        if (current_remainder >= b_reg) begin
            quotient = {quotient[15:1], 1'b1};
            current_remainder = current_remainder - b_reg;
        end else begin
            quotient = {quotient[15:1], 1'b0};
        end
        current_remainder = {current_remainder[7:1], 1'b0};
        remainder = {remainder[15:1], current_remainder[7]};

        // Step 13
        if (current_remainder >= b_reg) begin
            quotient = {quotient[15:1], 1'b1};
            current_remainder = current_remainder - b_reg;
        end else begin
            quotient = {quotient[15:1], 1'b0};
        end
        current_remainder = {current_remainder[7:1], 1'b0};
        remainder = {remainder[15:1], current_remainder[7]};

        // Step 14
        if (current_remainder >= b_reg) begin
            quotient = {quotient[15:1], 1'b1};
            current_remainder = current_remainder - b_reg;
        end else begin
            quotient = {quotient[15:1], 1'b0};
        end
        current_remainder = {current_remainder[7:1], 1'b0};
        remainder = {remainder[15:1], current_remainder[7]};

        // Step 15
        if (current_remainder >= b_reg) begin
            quotient = {quotient[15:1], 1'b1};
            current_remainder = current_remainder - b_reg;
        end else begin
            quotient = {quotient[15:1], 1'b0};
        end
        current_remainder = {current_remainder[7:1], 1'b0};
        remainder = {remainder[15:1], current_remainder[7]};

        result = quotient;
        odd = remainder;
    end

endmodule
