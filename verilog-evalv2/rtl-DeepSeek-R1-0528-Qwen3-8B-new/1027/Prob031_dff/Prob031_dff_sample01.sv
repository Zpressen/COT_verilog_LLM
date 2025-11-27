
module TopModule (
  input clk,
  input d,
  input q
);

  always @(posedge clk) begin
    q <= d;
  end

endmodule

