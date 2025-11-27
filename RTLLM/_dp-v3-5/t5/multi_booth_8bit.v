module multi_booth_8bit(
    input clk,
    input reset,
    input [7:0] a,
    input [7:0] b,
    output reg [15:0] p,
    output reg rdy
);

    reg [15:0] multiplicand;
    reg [15:0] multiplier;
    reg [4:0] ctr;
    reg [15:0] accumulator;
    reg [1:0] current_bits;
    reg prev_bit;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Initialize on reset
            multiplicand <= {{8{b[7]}}, b}; // Sign-extend multiplier
            multiplier <= {{8{a[7]}}, a};   // Sign-extend multiplicand
            accumulator <= 16'b0;
            ctr <= 5'b0;
            prev_bit <= 1'b0;
            rdy <= 1'b0;
            p <= 16'b0;
        end
        else begin
            if (ctr < 5) begin
                rdy <= 1'b0;
                // Booth recoding - examine 3 bits (current 2 bits + previous bit)
                current_bits = multiplier[1:0];
                
                case ({current_bits, prev_bit})
                    3'b000, 3'b111: // +0 operation
                        accumulator <= accumulator;
                    3'b001, 3'b010: // +multiplicand
                        accumulator <= accumulator + multiplicand;
                    3'b011:         // +2*multiplicand
                        accumulator <= accumulator + {multiplicand[14:0], 1'b0};
                    3'b100:         // -2*multiplicand
                        accumulator <= accumulator - {multiplicand[14:0], 1'b0};
                    3'b101, 3'b110: // -multiplicand
                        accumulator <= accumulator - multiplicand;
                endcase
                
                // Arithmetic right shift of accumulator and multiplier
                {accumulator, multiplier} <= {accumulator[15], accumulator, multiplier[15:1]};
                prev_bit <= multiplier[0];
                ctr <= ctr + 1;
            end
            else begin
                // Multiplication complete
                p <= accumulator;
                rdy <= 1'b1;
            end
        end
    end

endmodule
