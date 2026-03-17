module multi_booth_8bit (
    input clk,
    input reset,
    input [7:0] a,
    input [7:0] b,
    output reg [15:0] p,
    output reg rdy
);

    reg [15:0] multiplier;
    reg [15:0] multiplicand;
    reg [4:0] ctr;
    reg prev_bit;
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Initialize registers with sign-extended inputs
            multiplier <= {{8{a[7]}}, a};
            multiplicand <= {{8{b[7]}}, b} << 8;
            p <= 16'b0;
            ctr <= 5'b0;
            rdy <= 1'b0;
            prev_bit <= 1'b0;
        end else begin
            if (ctr < 16) begin
                // Booth Radix-4 encoding
                case ({multiplier[1:0], prev_bit})
                    3'b000, 3'b111: ; // No operation
                    3'b001, 3'b010: p <= p + multiplicand;
                    3'b011: p <= p + (multiplicand << 1); // 2*multiplicand
                    3'b100: p <= p - (multiplicand << 1); // -2*multiplicand
                    3'b101, 3'b110: p <= p - multiplicand;
                endcase
                
                // Shift operations
                multiplier <= multiplier >> 2;  // Arithmetic right shift
                multiplicand <= multiplicand << 2;
                
                // Update previous bit and counter
                prev_bit <= multiplier[1];
                ctr <= ctr + 5'd2;  // Increment by 2 for Radix-4
            end else begin
                rdy <= 1'b1;  // Multiplication complete
            end
        end
    end

endmodule
