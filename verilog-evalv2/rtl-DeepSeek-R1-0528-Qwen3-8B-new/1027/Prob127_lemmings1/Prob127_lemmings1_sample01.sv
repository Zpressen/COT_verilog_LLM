
module TopModule(
  input clk,
  input areset,
  input bump_left,
  input bump_right,
  output walk_left,
  output walk_right
);

  // State definitions
  typedef enum {LEFT, RIGHT} state_t;

  // State register
  reg state_t current_state, next_state;

  // Output assignments
  assign walk_left = (current_state == LEFT);
  assign walk_right = (current_state == RIGHT);

  // State transition logic
  always @(posedge clk or posedge areset) begin
    if (areset) begin
      current_state <= LEFT;
    end else begin
      case (current_state)
        LEFT: begin
          if (bump_left || bump_right) next_state <= RIGHT;
          else next_state <= LEFT;
        end
        RIGHT: begin
          if (bump_left || bump_right) next_state <= LEFT;
          else next_state <= RIGHT;
        end
      endcase
    end
  end

endmodule

