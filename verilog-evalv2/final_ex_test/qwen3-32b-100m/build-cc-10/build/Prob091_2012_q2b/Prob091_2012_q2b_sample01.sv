

module TopModule (
  input [5:0] y,
  input w,
  output Y1,
  output Y3
);

  // Combinational logic for Y1 (next state y[1] for B)
  assign Y1 = y[0] & w;

  // Combinational logic for Y3 (next state y[3] for D)
  assign Y3 = (~w) & (y[1] | y[2] | y[4] | y[5]);

endmodule

