
module TopModule
(
  input  clk,
  input  in,
  output out
);

  DFF dff (
    .clk(clk),
    .d(in ^ out),
    .q(out)
  );

endmodule

// DFF implementation (assuming a basic D flip-flop)
module DFF
(
  input  clk,
  input  d,
  output q
);

  always @(posedge clk) begin
    q <= d;
  end

endmodule

