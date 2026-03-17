
module TopModule
(
  input  logic x,
  input  logic y,
  output logic z
);

  // Combinational logic for XNOR operation
  assign z = x == y;

endmodule

