module multi_booth_8bit(
    input clk,
    input reset,
    input [7:0] a,
    input [7:0] b,
    output reg [15:0] p,
    output reg rdy
);

    reg [15:0] multiplicand;  // 16-bit multiplicand (sign extended)
    reg [15:0] multiplier;    // 16-bit multiplier (sign extended)
    reg [2:0] ctr;            // Counter (0-4 iterations)
    reg [1:0] prev_bits;      // Previous bits for Booth encoding
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Initialize on reset
            multiplicand <= {{8{a[7]}}, a};  // Sign-extend multiplicand
            multiplier <= {{8{b[7]}}, b};    // Sign-extend multiplier
            p <= 16'b0;
            ctr <= 3'b0;
            prev_bits <= 2'b0;
            rdy <= 1'b0;
        end
        else begin
            if (ctr < 4) begin
                case (multiplier[1:0] ^ prev_bits)
                    2'b00, 2'b11: // No operation
                        p <= p;
                    2'b01:        // Add multiplicand
                        p <= p + multiplicand;
                    2'b10:        // Subtract multiplicand
                        p <= p - multiplicand;
                endcase
                
                // Shift operations
                multiplicand <= multiplicand << 2;  // Shift left by 2 for next higher bits
                multiplier <= multiplier >> 2;     // Shift right by 2 for next bits
                prev_bits <= multiplier[1:0];      // Save current bits for next iteration
                
                ctr <= ctr + 1;   // Increment counter
                rdy <= 1'b0;      // Not ready yet
            end
            else begin
                rdy <= 1'b1;      // Multiplication complete
            end
        end
    end

endmodule
