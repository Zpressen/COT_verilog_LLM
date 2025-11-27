
module TopModule(
  input clk,
  input a,
  input b,
  output q,
  output state
);

  reg state;

  always @(posedge clk) begin
    state <= a ^ b;
  end

  assign q = (a == 0 && b == 1) || (state == 1);

endmodule

