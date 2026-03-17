
module TopModule
(
  input  logic clk,
  input  logic areset,
  input  logic in,
  output logic out
);

  // State encoding: A=0, B=1
  typedef enum logic [1:0] {A, B} state_t;
  state_t current_state, next_state;

  // State register with asynchronous reset
  always_ff @(posedge clk or posedge areset) begin
    if (areset) begin
      current_state <= B;
    end else begin
      current_state <= next_state;
    end
  end

  // Combinational logic for next state and output
  always_comb begin
    next_state = current_state;
    out = 0;
    case (current_state)
      A: begin
        if (in == 0) next_state = B;
        else next_state = A;
        out = 0;
      end
      B: begin
        if (in == 0) next_state = A;
        else next_state = B;
        out = 1;
      end
    endcase
  end

endmodule

