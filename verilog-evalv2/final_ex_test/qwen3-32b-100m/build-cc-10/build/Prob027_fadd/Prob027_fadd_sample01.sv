

module TopModule (
  input a,
  input b,
  input cin,
  output cout,
  output sum
);

  // Combinational logic for full adder
  assign sum = a ^ b ^ cin;
  assign cout = (a & b) | (a & cin) | (b & cin);

endmodule

