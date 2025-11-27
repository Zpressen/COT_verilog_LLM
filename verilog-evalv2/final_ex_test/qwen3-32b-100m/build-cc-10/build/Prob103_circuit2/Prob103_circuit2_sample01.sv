

module TopModule (
  input a,
  input b,
  input c,
  input d,
  output q
);

  // Combinational logic for even parity generation
  assign q = ~(a ^ b ^ c ^ d);

endmodule

