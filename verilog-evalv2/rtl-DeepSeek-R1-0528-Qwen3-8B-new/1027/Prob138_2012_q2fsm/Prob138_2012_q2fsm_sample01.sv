
module TopModule(
  input clk,
  input reset,
  input w,
  output z
);

  // State encoding
  typedef enum {A=0, B=1, C=2, D=3, E=4, F=5} state_t;
  state_t state, next_state;

  // State transition logic
  always @(posedge clk or posedge reset) begin
    if (reset)
      state <= A;
    else
      state <= next_state;
  end

  // State transition table
  always @(*) begin
    case (state)
      A: next_state = (w == 1) ? B : A;
      B: next_state = (w == 1) ? C : D;
      C: next_state = (w == 1) ? E : D;
      D: next_state = (w == 1) ? F : A;
      E: next_state = (w == 1) ? E : D;
      F: next_state = (w == 1) ? C : D;
      default: next_state = A;
    endcase
  end

  // Output assignment
  assign z = (state == E) ? 1'b1 : 1'b0;

endmodule

