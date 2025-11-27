

module TopModule (
  input [255:0] in,
  input [7:0] sel,
  output  out
);

  // Combinational logic
  assign out = in[sel];

endmodule

