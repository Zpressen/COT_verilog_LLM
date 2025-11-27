
module TopModule
(
  input  logic [7:0] in,
  output logic parity
);

  // Combinational logic for even parity bit

  assign parity = ^in;

endmodule

