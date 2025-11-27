
module TopModule
(
  input  logic clk,
  input  logic reset,
  output logic [3:0] q
);

  // Synchronous reset, positive edge clock
  always_ff @(posedge clk) begin
    if (reset)
      q <= 4'b0000;
    else
      q <= q + 1;
  end

endmodule

