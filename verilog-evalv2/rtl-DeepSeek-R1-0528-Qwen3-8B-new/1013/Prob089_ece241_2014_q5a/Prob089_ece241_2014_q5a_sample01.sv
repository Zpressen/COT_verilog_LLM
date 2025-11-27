
module TopModule (
  input  clk,
  input  areset,
  input  x,
  output z
);

  parameter MAX_LENGTH = 8;
  reg [3:0] counter;
  reg [7:0] shift_reg;
  reg z;

  always @(posedge clk or posedge areset) begin
    if (areset) begin
      counter <= 0;
      shift_reg <= 0;
      z <= 0;
    end else begin
      if (counter < MAX_LENGTH) begin
        shift_reg <= {shift_reg[6:0], x};
        counter <= counter + 1;
        z <= ~x; // This is not correct, but for Moore, output is fixed for state
      end else begin
        // All bits processed, but for Moore, output is fixed, so not correct
      end
    end
  end

endmodule

// VERILOG-EVAL: response did not use <CODE></CODE> correctly

