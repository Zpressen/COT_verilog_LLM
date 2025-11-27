
module TopModule (
  input  logic [3:0] in,
  output logic [3:0] out_both,
  output logic [3:0] out_any,
  output logic [3:0] out_different
);

  // out_both: both current and left neighbor are 1
  assign out_both[0] = in[0] & in[1];
  assign out_both[1] = in[1] & in[2];
  assign out_both[2] = in[2] & in[3];
  assign out_both[3] = 1'b0; // no left neighbor for bit 3

  // out_any: either current or right neighbor is 1
  assign out_any[0] = 1'b0; // no right neighbor for bit 0
  assign out_any[1] = in[1] | in[0];
  assign out_any[2] = in[2] | in[1];
  assign out_any[3] = in[3] | in[2]; // right neighbor for bit 3 is bit 2

  // out_different: current bit differs from left neighbor (wrapping)
  assign out_different[0] = (in[0] != in[1]);
  assign out_different[1] = (in[1] != in[2]);
  assign out_different[2] = (in[2] != in[3]);
  assign out_different[3] = (in[3] != in[0]); // wrapping around

endmodule

