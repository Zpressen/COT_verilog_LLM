
module TopModule(
  input  logic [2:0] a,
  input  logic [2:0] b,
  output logic [2:0] out_or_bitwise,
  output logic out_or_logical,
  output logic [5:0] out_not
);

  // Bitwise OR of a and b
  assign out_or_bitwise = a | b;

  // Logical OR of a and b (1 if any bit is set, 0 otherwise)
  assign out_or_logical = (a | b) != 0;

  // Inverse of b in upper half, inverse of a in lower half
  assign out_not = {~b, ~a};

endmodule

