

module TopModule (
  input sel,
  input [7:0] a,
  input [7:0] b,
  output [7:0] out
);

  // Fixed combinational logic: output should be wire, not reg
  assign out = (~sel) ? a : b;  // Using ternary operator for cleaner mux logic

endmodule

