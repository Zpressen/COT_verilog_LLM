
module TopModule
(
  input  logic a,
  input  logic b,
  input  logic c,
  input  logic d,
  output logic out
);

  // Combinational logic

  assign out = ~(a & b) | (c & d) | (c & ~d) | (~a & b & c) | (~a & b & ~c) | (a & ~b & c) | (a & ~b & ~c) | (a & b & ~c);

endmodule

