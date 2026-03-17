

module TopModule (
  input a,
  input b,
  output sum,
  output cout
);

  // Combinational logic
  assign sum = a ^ b;
  assign cout = a & b;

endmodule

