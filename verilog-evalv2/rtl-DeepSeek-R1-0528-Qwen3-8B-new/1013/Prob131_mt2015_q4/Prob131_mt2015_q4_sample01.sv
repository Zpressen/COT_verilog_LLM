
module TopModule (
  input  logic x,
  input  logic y,
  output logic z
);

  // Instantiate first A and B
  A A1 (.x(x), .y(y), .z(A1_out));
  B B1 (.x(x), .y(y), .z(B1_out));

  // Instantiate second A and B
  A A2 (.x(x), .y(y), .z(A2_out));
  B B2 (.x(x), .y(y), .z(B2_out));

  // Connect to OR and AND
  logic OR_out, AND_out;
  assign OR_out = A1_out | B1_out;
  assign AND_out = A2_out & B2_out;

  // XOR to get z
  assign z = OR_out ^ AND_out;

endmodule

module A (
  input  logic x,
  input  logic y,
  output logic z
);
  assign z = (x ^ y) & x;
endmodule

module B (
  input  logic x,
  input  logic y,
  output logic z
);
  assign z = (x == y);
endmodule

