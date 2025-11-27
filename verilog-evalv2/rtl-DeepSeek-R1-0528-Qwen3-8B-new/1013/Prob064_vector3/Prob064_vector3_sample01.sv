
module TopModule (
  input  logic [4:0] a,
  input  logic [4:0] b,
  input  logic [4:0] c,
  input  logic [4:0] d,
  input  logic [4:0] e,
  input  logic [4:0] f,
  output logic [7:0] w,
  output logic [7:0] x,
  output logic [7:0] y,
  output logic [7:0] z
);

  wire [31:0] out_concat = {a, b, c, d, e, f, 1'b1, 1'b1};

  assign w = out_concat[31:24];
  assign x = out_concat[23:16];
  assign y = out_concat[15:8];
  assign z = out_concat[7:0];

endmodule

// VERILOG-EVAL: response did not use <CODE></CODE> correctly

