
module TopModule(
  input clk,
  input in,
  output out
);

  // XOR gate: XOR of in and out
  assign out = in ^ out;

  // D flip-flop with positive edge triggering
  always @(posedge clk) begin
    out <= out;
  end

endmodule

