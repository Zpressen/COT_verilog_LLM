
module TopModule
(
  input  logic a,
  input  logic b,
  input  logic c,
  input  logic d,
  output logic q
);

  // Combinational logic: q is the logical OR of c and d
  assign q = c | d;

endmodule

