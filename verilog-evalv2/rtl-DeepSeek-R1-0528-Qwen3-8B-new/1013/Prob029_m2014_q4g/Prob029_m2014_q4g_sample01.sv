
module TopModule
(
  input  logic in1,
  input  logic in2,
  input  logic in3,
  output logic out
);

  // Combinational logic

  assign out = (in1 XNOR in2) ^ in3;

endmodule

