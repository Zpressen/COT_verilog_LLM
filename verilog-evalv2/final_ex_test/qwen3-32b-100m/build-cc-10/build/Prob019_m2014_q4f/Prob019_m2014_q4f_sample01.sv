

module TopModule (
  input in1,
  input in2,
  output logic out
);

  // Combinational logic with inverted in2 input
  assign out = in1 & ~in2;

endmodule

