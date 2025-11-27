

module TopModule (
  input clk,
  input in,
  input reset,
  output out
);

  typedef enum logic [1:0] { B = 2'b00, A = 2'b01 } state_t;
  state_t current_state, next_state;

  // State register with synchronous reset
  always_ff @(posedge clk) begin
    if (reset)
      current_state <= B;
    else
      current_state <= next_state;
  end

  // Next state logic
  always_comb begin
    case (current_state)
      B: next_state = (in) ? B : A;
      A: next_state = (in) ? A : B;
      default: next_state = B;
    endcase
  end

  // Output logic (Moore machine)
  assign out = (current_state == B);

endmodule

