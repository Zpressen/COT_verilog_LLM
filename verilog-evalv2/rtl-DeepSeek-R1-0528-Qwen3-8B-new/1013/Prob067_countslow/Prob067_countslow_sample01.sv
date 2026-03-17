
module TopModule (
  input  clk,
  input  reset,
  input  slowena,
  output reg [3:0] q
);

  always @(posedge clk) begin
    if (reset) begin
      q <= 4'b0000;
    end else begin
      if (slowena) begin
        q <= (q + 1) % 10;
      end else begin
        q <= q;
      end
    end
  end

endmodule

