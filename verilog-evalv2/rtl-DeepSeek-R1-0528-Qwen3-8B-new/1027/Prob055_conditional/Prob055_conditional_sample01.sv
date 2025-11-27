
module TopModule
(
  input  logic [7:0] a,
  input  logic [7:0] b,
  input  logic [7:0] c,
  input  logic [7:0] d,
  output logic [7:0] min
);

  // Find the minimum of four 8-bit unsigned inputs
  assign min = (a < b) ? a : b;
  assign min = (min < c) ? min : c;
  assign min = (min < d) ? min : d;

endmodule

