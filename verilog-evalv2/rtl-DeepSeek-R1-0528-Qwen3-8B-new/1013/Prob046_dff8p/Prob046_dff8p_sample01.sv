
module TopModule
(
  input  logic clk,
  input  logic reset,
  input  logic [7:0] d,
  output logic [7:0] q
);

  // Synchronous reset with negative edge triggering
  always @(negedge clk) begin
    if (reset) begin
      q <= 8'h34;  // Reset to 0x34
    end else begin
      q <= d;      // Normal operation: output d on negative edge
    end
  end

endmodule

