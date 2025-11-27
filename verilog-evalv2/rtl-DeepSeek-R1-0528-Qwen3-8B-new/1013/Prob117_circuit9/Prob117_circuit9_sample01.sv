
module TopModule
(
  input  logic clk,
  input  logic a,
  output logic [2:0] q
);

  // State register
  logic [2:0] q_reg;

  // Combinational logic for next state
  logic [2:0] q_next;

  assign q_next = (a == 0) ? q_reg + 1 : q_reg;

  // Sequential always block with positive edge detection
  always_ff @(posedge clk) begin
    q_reg <= q_next;
  end

  // Output assignment
  assign q = q_reg;

endmodule

