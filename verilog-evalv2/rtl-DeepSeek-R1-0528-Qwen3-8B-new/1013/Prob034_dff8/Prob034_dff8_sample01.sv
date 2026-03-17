
module TopModule
(
  input  logic clk,
  input  logic [7:0] d,
  output logic [7:0] q
);

  // Synchronous D flip-flop array
  always_ff @(posedge clk) begin
    q <= d;
  end

endmodule

