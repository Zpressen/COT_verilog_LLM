
module TopModule
(
  input  logic clk,
  input  logic reset,
  output logic [9:0] q
);

  // 10-bit counter register
  logic [9:0] counter;

  // Synchronous reset and counting logic
  always_ff @(posedge clk) begin
    if (reset) begin
      counter <= 0;
    end
    else begin
      counter <= counter + 1;
    end
  end

  assign q = counter;

endmodule

