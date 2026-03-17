
module TopModule (
  input  logic a,
  input  logic b,
  input  logic c,
  input  logic d,
  output logic out
);

  // The output is 1 when the number of 1s in the 4-bit input is odd (parity bit)
  assign out = a ^ b ^ c ^ d;

endmodule

// VERILOG-EVAL: response did not use <CODE></CODE> correctly

