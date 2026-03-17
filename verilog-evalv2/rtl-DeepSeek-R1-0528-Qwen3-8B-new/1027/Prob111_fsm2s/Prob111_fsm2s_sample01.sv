
module TopModule(
  input clk,
  input reset,
  input j,
  input k,
  output out
);

  // State definitions
  localparam OFF = 0;
  localparam ON = 1;

  reg state;

  // Synchronous reset
  always @(posedge clk) begin
    if (reset)
      state <= OFF;
    else
      state <= next_state;
  end

  // Combinational next state logic
  always @(*) begin
    case (state)
      OFF: next_state = (j == 1) ? ON : OFF;
      ON: next_state = (k == 1) ? OFF : ON;
      default: next_state = OFF; // Safety net
    endcase
  end

  // Output logic
  assign out = state;

endmodule

