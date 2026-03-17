
module TopModule
(
  input  logic [99:0] in,
  output logic [99:0] out
);

  // Combinational logic for bit reversal
  generate
    for (genvar i = 0; i < 100; i++) begin
      assign out[99 - i] = in[i];
    end
  endgenerate

endmodule

