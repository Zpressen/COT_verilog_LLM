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
    reg [1:0] prev_bit; // For storing previous bits in Booth algorithm

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Initialize registers
            multiplicand <= {{8{a[7]}}, a}; // Sign-extended multiplicand
            multiplier <= {{8{b[7]}}, b};   // Sign-extended multiplier
            p <= 16'b0;
            ctr <= 5'b0;
            rdy <= 1'b0;
            prev_bit <= 2'b0;
        end
        else begin
            if (ctr < 16) begin
                case (multiplier[1:0])
                    2'b01: begin
                        // Add multiplicand to product
                        p <= p + multiplicand;
                    end
                    2'b10: begin
                        // Subtract multiplicand from product
                        p <= p - multiplicand;
                    end
                    default: begin
                        // Do nothing for 00 or 11
                        p <= p;
                    end
                endcase

                // Arithmetic right shift multiplier
                multiplier <= {multiplier[15], multiplier[15:1]};

                // Left shift multiplicand
                multiplicand <= multiplicand << 1;

                // Increment counter
                ctr <= ctr + 1;
                rdy <= 1'b0;
            end
            else begin
                // Multiplication complete
                rdy <= 1'b1;
            end
        end
    end

endmodule
