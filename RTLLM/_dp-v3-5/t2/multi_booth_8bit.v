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
    reg [1:0] prev_bit; // Stores previous bit for Booth encoding
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            multiplicand <= {{8{b[7]}}, b}; // Sign extend to 16 bits
            multiplier <= {{8{a[7]}}, a};   // Sign extend to 16 bits
            p <= 16'b0;
            ctr <= 5'b0;
            prev_bit <= 2'b0;
            rdy <= 1'b0;
        end
        else begin
            if (ctr < 8) begin // Only need 4 iterations (8 bits / 2 bits per iteration)
                case ({multiplier[1:0], prev_bit[0]})
                    3'b000, 3'b111: begin // No operation
                        p <= p;
                    end
                    3'b001: begin // Add multiplicand
                        p <= p + multiplicand;
                    end
                    3'b010: begin // Add multiplicand
                        p <= p + multiplicand;
                    end
                    3'b011: begin // Add 2*multiplicand
                        p <= p + (multiplicand << 1);
                    end
                    3'b100: begin // Subtract 2*multiplicand
                        p <= p - (multiplicand << 1);
                    end
                    3'b101: begin // Subtract multiplicand
                        p <= p - multiplicand;
                    end
                    3'b110: begin // Subtract multiplicand
                        p <= p - multiplicand;
                    end
                endcase
                
                // Arithmetic right shift by 2 bits
                multiplier <= $signed(multiplier) >>> 2;
                prev_bit <= multiplier[1:0];
                ctr <= ctr + 1;
                
                if (ctr == 7) begin
                    rdy <= 1'b1;
                end
            end
            else begin
                rdy <= 1'b1;
            end
        end
    end

endmodule
