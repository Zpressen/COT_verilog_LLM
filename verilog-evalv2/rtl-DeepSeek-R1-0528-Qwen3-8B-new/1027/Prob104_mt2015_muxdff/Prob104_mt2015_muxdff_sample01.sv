
module TopModule (
  input clk,
  input L,
  input [2:0] r,
  output reg q
);

  always @(posedge clk) begin
    if (L) begin
      q <= r;
    end else begin
      q <= {q[1] ^ q[2], q[0], q[2]};
    end
  end

endmodule

