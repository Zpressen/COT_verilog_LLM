
module TopModule
(
  input  logic [7:0] a,
  input  logic [7:0] b,
  input  logic [7:0] c,
  input  logic [7:0] d,
  output logic [7:0] min
);

  // Find the minimum of four 8-bit unsigned inputs
  assign min = (a < b) ? a : ((c < d) ? c : ((a < c) ? a : ((b < d) ? b : ((a < d) ? a : b))));

endmodule

