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
    reg [1:0] prev_bit; // For Radix-4 Booth encoding
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Initialize registers
            multiplicand <= {{8{b[7]}}, b}; // Sign-extend multiplier
            multiplier <= {{8{a[7]}}, a};   // Sign-extend multiplicand
            p <= 16'b0;
            ctr <= 5'b0;
            prev_bit <= 2'b0;
            rdy <= 1'b0;
        end
        else begin
            if (ctr < 8) begin // 8 steps (since we process 2 bits at a time)
                case (multiplier[1:0])
                    2'b00: begin
                        // No operation, just shift
                    end
                    2'b01: begin
                        // Add multiplicand to product
                        p <= p + multiplicand;
                    end
                    2'b10: begin
                        // Subtract multiplicand from product
                        p <= p - multiplicand;
                    end
                    2'b11: begin
                        // No operation (equivalent to 2's complement of 00)
                    end
                endcase
                
                // Arithmetic right shift of multiplier (preserve sign)
                multiplier <= {multiplier[15], multiplier[15:1]};
                
                // Left shift of multiplicand (equivalent to *2)
                multiplicand <= {multiplicand[14:0], 1'b0};
                
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
