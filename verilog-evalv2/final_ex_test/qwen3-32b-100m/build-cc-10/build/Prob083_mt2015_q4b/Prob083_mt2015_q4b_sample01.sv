

module TopModule (
  input x,
  input y,
  output z
);

  // Combinational XNOR logic
  assign z = ~(x ^ y);

endmodule

