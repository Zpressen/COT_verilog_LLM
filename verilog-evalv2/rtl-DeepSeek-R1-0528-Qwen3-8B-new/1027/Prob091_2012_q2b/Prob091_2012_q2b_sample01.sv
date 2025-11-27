
module TopModule
(
  input  logic [5:0] y,
  output logic Y1,
  output logic Y3
);

  assign Y1 = y[1];
  assign Y3 = y[3];

endmodule

