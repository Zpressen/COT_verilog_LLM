

module TopModule (
  input clk,
  input reset,
  output [3:1] ena,
  output reg [15:0] q
);

always @(posedge clk) begin
  if (reset) begin
    q <= 16'd0;
    ena <= 3'b0;
  end else begin
    logic [3:0] next_ones, next_tens, next_hundreds, next_thousands;
    logic carry_ones, carry_tens, carry_hundreds;

    // Compute ones digit
    if (q[3:0] == 4'd9) begin
      next_ones = 4'd0;
      carry_ones = 1'b1;
    end else begin
      next_ones = q[3:0] + 1;
      carry_ones = 1'b0;
    end

    // Compute tens digit
    if (carry_ones) begin
      if (q[7:4] == 4'd9) begin
        next_tens = 4'd0;
        carry_tens = 1'b1;
      end else begin
        next_tens = q[7:4] + 1;
        carry_tens = 1'b0;
      end
    end else begin
      next_tens = q[7:4];
      carry_tens = 1'b0;
    end

    // Compute hundreds digit
    if (carry_tens) begin
      if (q[11:8] == 4'd9) begin
        next_hundreds = 4'd0;
        carry_hundreds = 1'b1;
      end else begin
        next_hundreds = q[11:8] + 1;
        carry_hundreds = 1'b0;
      end
    end else begin
      next_hundreds = q[11:8];
      carry_hundreds = 1'b0;
    end

    // Compute thousands digit
    if (carry_hundreds) begin
      if (q[15:12] == 4'd9) begin
        next_thousands = 4'd0;
      end else begin
        next_thousands = q[15:12] + 1;
      end
    end else begin
      next_thousands = q[15:12];
    end

    // Assign next values to q
    q <= {next_thousands, next_hundreds, next_tens, next_ones};

    // Assign ena outputs
    ena[1] = carry_ones;
    ena[2] = carry_tens;
    ena[3] = carry_hundreds;
  end
end

endmodule

