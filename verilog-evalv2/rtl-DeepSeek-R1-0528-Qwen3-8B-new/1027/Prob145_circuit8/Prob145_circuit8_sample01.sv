
module TopModule(
  input  clock,
  input  a,
  output reg p,
  output reg q
);

  always @(posedge clock) begin
    if (a) begin
      p <= p + 1;
      q <= q + 1;
    end
  end
endmodule

