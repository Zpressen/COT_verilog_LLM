

module TopModule (
  input clk,
  input reset,
  input w,
  output z
);

  logic [2:0] y, next_y;

  // State flip-flops (current state)
  always_ff @(posedge clk) begin
    if (reset)
      y <= 3'b000; // State A
    else
      y <= next_y;
  end

  // Next state logic
  always_comb begin
    case (y)
      3'b000: next_y = (w) ? 3'b001 : 3'b000; // A -> B or A
      3'b001: next_y = (w) ? 3'b010 : 3'b011; // B -> C or D
      3'b010: next_y = (w) ? 3'b100 : 3'b011; // C -> E or D
      3'b011: next_y = (w) ? 3'b101 : 3'b000; // D -> F or A
      3'b100: next_y = (w) ? 3'b100 : 3'b011; // E -> E or D
      3'b101: next_y = (w) ? 3'b010 : 3'b011; // F -> C or D
      default: next_y = 3'b000;
    endcase
  end

  // Output logic
  assign z = (y == 3'b100) || (y == 3'b101);

endmodule

