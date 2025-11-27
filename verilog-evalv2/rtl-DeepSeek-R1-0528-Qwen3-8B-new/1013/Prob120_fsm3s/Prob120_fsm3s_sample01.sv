
module TopModule (
  input  clk,
  input  reset,
  input  in,
  output out
);

  // State encoding: A=00, B=01, C=10, D=11
  typedef enum logic [1:0] {A, B, C, D} state_t;

  state_t current_state, next_state;

  // Output is Moore, depends on current state
  assign out = (current_state == D) ? 1'b1 : 1'b0;

  // Next state logic
  always_comb begin
    case (current_state)
      A: begin
        if (in) next_state = B;
        else next_state = A;
      end
      B: begin
        if (in) next_state = B;
        else next_state = C;
      end
      C: begin
        if (in) next_state = D;
        else next_state = A;
      end
      D: begin
        if (in) next_state = B;
        else next_state = C;
      end
      default: next_state = A; // for safety
    endcase
  end

  // State register with synchronous reset
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      current_state <= A;
    end else begin
      current_state <= next_state;
    end
  end

endmodule

