

module TopModule (
  input clk,
  input a,
  output reg q
);

  always_ff @(posedge clk) begin
    q <= ~a;
  end

endmodule

