

module TopModule (
  input clk,
  input j,
  input k,
  input reset,
  output out
);

  typedef enum logic [1:0] {OFF=2'b00, ON=2'b01} state_t;
  state_t current_state, next_state;

  // State register with synchronous reset
  always_ff @(posedge clk) begin
    if (reset)
      current_state <= OFF;
    else
      current_state <= next_state;
  end

  // Next state logic
  always_comb begin
    case (current_state)
      OFF: next_state = (j) ? ON : OFF;
      ON: next_state = (k) ? OFF : ON;
      default: next_state = OFF;
    endcase
  end

  // Output logic (Moore machine)
  assign out = (current_state == ON);

endmodule

