
module TopModule (
  input clk,
  input a,
  output q
);

  reg q;
  reg prev_a;

  always @(posedge clk) begin
    prev_a <= a;
    q <= (a && ~prev_a) ? ~q : q;
  end

endmodule

