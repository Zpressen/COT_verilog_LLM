
module TopModule (
  input  clk,
  input  a,
  input  b,
  output q,
  output state
);

  reg state;

  // Combinational logic for next_state and q
  assign q = a | b;

  // Next state logic: toggle when a=0 and b=0, else stay
  assign next_state = (state == 0 && a == 0 && b == 0) ? 1'b1 : (state == 1 && a == 0 && b == 0) ? 1'b0 : state;

  // Flip-flop for state
  always @(posedge clk) begin
    state <= next_state;
  end

endmodule

