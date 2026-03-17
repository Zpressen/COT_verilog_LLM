
module TopModule(
  input a,
  input b,
  input c,
  output out
);

  assign out = {!a & !b & !c} ? 1'b0 : 1'b1;

endmodule

