module multi_booth_8bit (
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
    reg [15:0] product;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Initialize registers on reset
            multiplicand <= {{8{b[7]}}, b};  // Sign-extend multiplier
            multiplier <= {{8{a[7]}}, a};    // Sign-extend multiplicand
            product <= 16'b0;
            ctr <= 5'b0;
            rdy <= 1'b0;
        end
        else begin
            if (ctr < 16) begin
                // Booth algorithm implementation
                case (multiplier[1:0])
                    2'b01: begin
                        // Add multiplicand to product
                        product <= product + multiplicand;
                    end
                    2'b10: begin
                        // Subtract multiplicand from product
                        product <= product - multiplicand;
                    end
                    default: begin
                        // Do nothing for 00 or 11
                        product <= product;
                    end
                endcase

                // Arithmetic right shift of multiplier
                multiplier <= {product[0], multiplier[15:1]};
                
                // Right shift of product (with sign extension)
                product <= {product[15], product[15:1]};
                
                // Increment counter
                ctr <= ctr + 1;
                
                // Clear ready signal during operation
                rdy <= 1'b0;
            end
            else begin
                // Multiplication complete
                p <= product;
                rdy <= 1'b1;
            end
        end
    end

endmodule
