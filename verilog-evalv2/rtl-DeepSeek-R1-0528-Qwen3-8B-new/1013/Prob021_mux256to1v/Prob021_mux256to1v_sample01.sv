
module TopModule (
  input  logic [1023:0] in,
  input  logic [7:0] sel,
  output logic [3:0] out
);

  // Combinational logic: extract the 4-bit word based on sel
  assign out = in[sel*4 +: 4];

endmodule

