
module TopModule (
  input clk,
  input areset,
  input x,
  output z
);

  typedef enum logic {S0, S1} state_t;
  state_t state, next_state;

  always_ff @(posedge clk or posedge areset) begin
    if (areset) begin
      state <= S0;
    end else begin
      state <= next_state;
    end
  end

  always_comb begin
    next_state = state;
    case (state)
      S0: begin
        if (x == 1) next_state = S1;
        else next_state = S0;
      end
      S1: next_state = S1;
      default: next_state = S0;
    endcase
  end

  assign z = (state == S0) ? x : ~x;

endmodule

// VERILOG-EVAL: errant inclusion of module definition


