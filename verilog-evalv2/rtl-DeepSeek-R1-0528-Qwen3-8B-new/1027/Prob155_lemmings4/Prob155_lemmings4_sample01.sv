
module TopModule(
  input  clk,
  input  areset,
  input  bump_left,
  input  bump_right,
  input  ground,
  input  dig,
  output walk_left,
  output walk_right,
  output aaah,
  output digging
);

  // State definitions
  typedef enum {WALK_LEFT, WALK_RIGHT, FALLING, DIGGING, SPLATTERED} state_t;
  state_t state, next_state;

  // State transitions
  always @(posedge clk or posedge areset) begin
    if (areset) begin
      state <= WALK_LEFT;
    end else begin
      case (state)
        WALK_LEFT: begin
          if (ground == 0) next_state = FALLING;
          else if (dig) next_state = DIGGING;
          else if (bump_left) next_state = WALK_RIGHT;
          else if (bump_right) next_state = WALK_LEFT;
          else next_state = WALK_LEFT;
        end
        WALK_RIGHT: begin
          if (ground == 0) next_state = FALLING;
          else if (dig) next_state = DIGGING;
          else if (bump_left) next_state = WALK_RIGHT;
          else if (bump_right) next_state = WALK_LEFT;
          else next_state = WALK_RIGHT;
        end
        FALLING: begin
          if (ground == 1) next_state = state; // Return to original walking state
          else if (fall_counter > 20) next_state = SPLATTERED;
          else next_state = FALLING;
        end
        DIGGING: begin
          if (ground == 0) next_state = FALLING;
          else next_state = state; // Return to original walking state
        end
        SPLATTERED: next_state = SPLATTERED;
      endcase
    end
  end

  // Output assignments
  assign walk_left = (state == WALK_LEFT);
  assign walk_right = (state == WALK_RIGHT);
  assign aaah = (state == FALLING);
  assign digging = (state == DIGGING);

endmodule

