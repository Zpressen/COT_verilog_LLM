
module TopModule
(
  input  logic y[5:0],  // current state
  input  logic w,
  output logic Y2,
  output logic Y4
);

  // Y2 is the y[1] bit of the next state, which is 1 when next state is D
  assign Y2 = (y[1] & w) | (y[2] & w) | (y[3] & w) | (y[5] & w) | (y[4] & w);

  // Y4 is the y[3] bit of the next state, which is 1 when next state is E
  assign Y4 = (y[4] & ~w);

endmodule

