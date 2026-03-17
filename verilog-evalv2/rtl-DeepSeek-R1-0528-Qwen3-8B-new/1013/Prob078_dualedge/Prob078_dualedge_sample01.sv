
module TopModule
(
  input  logic clk,
  input  logic d,
  output logic q
);

  // Rising-edge flip-flop
  always @(posedge clk) begin
    q <= d;
  end

  // Falling-edge flip-flop
  always @(negedge clk) begin
    q <= d;
  end

endmodule

