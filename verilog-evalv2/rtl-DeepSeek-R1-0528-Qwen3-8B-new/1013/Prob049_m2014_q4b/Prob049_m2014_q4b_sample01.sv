
module TopModule
(
  input  logic clk,
  input  logic ar,
  input  logic d,
  output logic q
);

  // Asynchronous reset logic
  assign q = ar ? 1'b0 : d;

  // Clock edge detection with non-blocking assignment
  always @(posedge clk) begin
    q <= d;
  end

endmodule

