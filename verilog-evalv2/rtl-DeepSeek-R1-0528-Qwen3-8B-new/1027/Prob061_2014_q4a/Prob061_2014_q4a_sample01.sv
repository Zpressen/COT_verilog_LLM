
module TopModule (
  input  clk,
  input  w,
  input  R,
  input  E,
  input  L,
  output Q
);

  reg Q;

  always @(posedge clk) begin
    if (R) begin
      Q <= 1'b1;
    end else if (E && L) begin
      Q <= 1'b0;
    end else if (E) begin
      Q <= w;
    end
  end

endmodule

