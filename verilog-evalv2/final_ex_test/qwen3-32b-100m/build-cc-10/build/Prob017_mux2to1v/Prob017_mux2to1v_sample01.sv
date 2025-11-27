

module TopModule (
  input [99:0] a,
  input [99:0] b,
  input sel,
  output [99:0] out
);

  // Combinational logic
  assign out = sel ? b : a;

endmodule

