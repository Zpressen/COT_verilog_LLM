

module TopModule (
  input clk,
  input d,
  output reg q
);

  // Dual-edge behavior simulated with two separate always blocks
  always @(posedge clk) begin
    q <= d;
  end

  always @(negedge clk) begin
    q <= d;
  end

endmodule

