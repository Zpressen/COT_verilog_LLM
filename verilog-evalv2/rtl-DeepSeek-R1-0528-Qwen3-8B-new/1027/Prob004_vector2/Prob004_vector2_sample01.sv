
module TopModule
(
  input  logic [31:0] in,
  output logic [31:0] out
);

  // Extract each byte from the input
  logic [7:0] byte0 = in[7:0];
  logic [7:0] byte1 = in[15:8];
  logic [7:0] byte2 = in[23:16];
  logic [7:0] byte3 = in[31:24];

  // Reverse the byte order and assign to output
  assign out[7:0] = byte3;
  assign out[15:8] = byte2;
  assign out[23:16] = byte1;
  assign out[31:24] = byte0;

endmodule

