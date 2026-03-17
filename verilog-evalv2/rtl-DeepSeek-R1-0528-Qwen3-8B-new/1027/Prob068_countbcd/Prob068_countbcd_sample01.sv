
module TopModule(
  input clk,
  input reset,
  output [2:0] ena,
  output [15:0] q
);

  reg [15:0] q_reg;
  wire [3:0] ones, tens, hundreds, thousands;

  // Extract BCD digits
  assign ones = q_reg[3:0];
  assign tens = q_reg[7:4];
  assign hundreds = q_reg[11:8];
  assign thousands = q_reg[15:12];

  // Generate enable signals for upper digits
  assign ena[2] = (ones == 4'b1001) & (tens != 4'b0000);
  assign ena[1] = (tens == 4'b1001) & (hundreds != 4'b0000);
  assign ena[0] = (hundreds == 4'b1001) & (thousands != 4'b0000);

  // BCD counter logic with carry handling
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      q_reg <= 16'b0;
    end else begin
      q_reg <= q_reg + 1;
      // Handle BCD carry for thousands digit
      if (q_reg == 16'b1111_0000_0000_0000) begin
        q_reg <= 16'b0;
      end
    end
  end

endmodule

