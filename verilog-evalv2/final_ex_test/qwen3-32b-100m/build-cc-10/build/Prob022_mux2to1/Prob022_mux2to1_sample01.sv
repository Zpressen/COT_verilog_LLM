

module TopModule (
  input a,
  input b,
  input sel,
  output out
);

  // Combinational logic
  assign out = sel ? b : a;

endmodule

