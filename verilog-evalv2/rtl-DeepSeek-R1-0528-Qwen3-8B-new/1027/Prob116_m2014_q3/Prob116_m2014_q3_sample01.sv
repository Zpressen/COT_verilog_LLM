
module TopModule(
  input  logic [3:0] x,
  output logic f
);

  assign f = (x[3:2] == 2'b11) | (x[3:2] == 2'b10);

endmodule

