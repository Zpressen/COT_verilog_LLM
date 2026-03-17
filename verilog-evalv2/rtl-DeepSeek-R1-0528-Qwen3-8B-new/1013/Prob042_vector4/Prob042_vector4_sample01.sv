
module TopModule
(
  input  logic [7:0] in,
  output logic [31:0] out
);

  // Sign-extension logic: replicate sign bit 24 times and concatenate with original 8 bits
  assign out = {24{in[7]}, in};

endmodule

