

module TopModule (
  input clk,
  input j,
  input k,
  input areset,
  output out
);

typedef enum logic {OFF, ON} state_t;
state_t current_state, next_state;

always_ff @(posedge clk, posedge areset) begin
  if (areset) begin
    current_state <= OFF;
  end else begin
    current_state <= next_state;
  end
end

always_comb begin
  case (current_state)
    OFF: next_state = (j) ? ON : OFF;
    ON: next_state = (k) ? OFF : ON;
    default: next_state = OFF;
  endcase
end

assign out = (current_state == ON);

endmodule

