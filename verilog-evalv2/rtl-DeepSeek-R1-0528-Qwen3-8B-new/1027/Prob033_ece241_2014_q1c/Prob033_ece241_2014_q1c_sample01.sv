
module TopModule(
  input  logic [7:0] a,
  input  logic [7:0] b,
  output logic [7:0] s,
  output logic overflow
);

  assign s = a + b;
  assign overflow = (s > 8'd127) | (s < -8'd128);

endmodule

