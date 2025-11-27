
module TopModule(
  input a,
  input b,
  input c,
  input d,
  output out,
  output out_n
);

  // Intermediate wires for AND gates
  wire and1, and2;

  // First layer: AND gates
  assign and1 = a & b;
  assign and2 = c & d;

  // Second layer: OR gate and NOT gate
  assign out = and1 | and2;
  assign out_n = ~out;

endmodule

