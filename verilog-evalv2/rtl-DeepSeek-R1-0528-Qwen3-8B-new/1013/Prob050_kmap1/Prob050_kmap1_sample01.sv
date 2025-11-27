
module TopModule (
  input logic a,
  input logic b,
  input logic c,
  output logic out
);

  // Combinational logic: out is 0 only when all inputs are 0, else 1
  assign out = ~(a & b & c);

endmodule

// VERILOG-EVAL: response did not use <CODE></CODE> correctly

