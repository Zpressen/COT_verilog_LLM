
module TopModule(
  input  logic [99:0] in,
  output logic [99:0] out_both,
  output logic [99:0] out_any,
  output logic [99:0] out_different
);

  // out_both: both current and left neighbor are 1
  assign out_both[99] = 1'b0; // no left neighbor for bit 99
  generate
    for (genvar i = 98; i >= 0; i = i - 1) begin
      assign out_both[i] = in[i] & in[i+1];
    end
  endgenerate

  // out_any: either current or right neighbor is 1
  assign out_any[0] = 1'b0; // no right neighbor for bit 0
  generate
    for (genvar i = 99; i >= 1; i = i - 1) begin
      assign out_any[i] = in[i] | in[i-1];
    end
  endgenerate

  // out_different: current bit differs from left neighbor
  assign out_different[99] = in[99] ^ in[0]; // wrapping around
  generate
    for (genvar i = 98; i >= 0; i = i - 1) begin
      assign out_different[i] = in[i] ^ in[i+1];
    end
  endgenerate

endmodule

