
module TopModule(
  input  clk,
  input  areset,
  input  bump_left,
  input  bump_right,
  input  ground,
  output walk_left,
  output walk_right,
  output aaah
);

  // State definitions
  typedef enum {WALK_LEFT, WALK_RIGHT, FALLING} state_t;
  state_t current_state, next_state;

  // State transitions
  always @(posedge clk or posedge areset) begin
    if (areset) begin
      current_state <= WALK_LEFT;
    end else begin
      case (current_state)
        WALK_LEFT: begin
          if (bump_left) next_state <= WALK_RIGHT;
          else if (bump_right) next_state <= WALK_LEFT;
          else if (!ground) next_state <= FALLING;
          else next_state <= WALK_LEFT;
        end
        WALK_RIGHT: begin
          if (bump_left) next_state <= WALK_LEFT;
          else if (bump_right) next_state <= WALK_RIGHT;
          else if (!ground) next_state <= FALLING;
          else next_state <= WALK_RIGHT;
        end
        FALLING: begin
          if (ground) next_state <= (current_state == WALK_LEFT) ? WALK_LEFT : WALK_RIGHT;
          else next_state <= FALLING;
        end
      endcase
    end
  end

  // Output assignments
  assign walk_left = (current_state == WALK_LEFT);
  assign walk_right = (current_state == WALK_RIGHT);
  assign aaah = (current_state == FALLING);

endmodule

