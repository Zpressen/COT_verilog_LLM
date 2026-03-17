

module TopModule (
  input a,
  input b,
  input c,
  input d,
  output q
);

  // Combinational logic
  assign q = (a | b) & (c | d);

endmodule

