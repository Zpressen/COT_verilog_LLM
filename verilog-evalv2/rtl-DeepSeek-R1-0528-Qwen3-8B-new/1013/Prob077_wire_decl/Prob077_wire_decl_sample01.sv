
module TopModule
(
  input  logic a,
  input  logic b,
  input  logic c,
  input  logic d,
  output logic out,
  output logic out_n
);

  // Intermediate wires for AND gates
  wire and1 = a & b;
  wire and2 = c & d;

  // OR gate combining the AND results
  assign out = and1 | and2;

  // Inverted output
  assign out_n = ~out;

endmodule

