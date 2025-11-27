
module TopModule (
  input clk,
  input areset,
  input bump_left,
  input bump_right,
  input ground,
  input dig,
  output walk_left,
  output walk_right,
  output aaah,
  output digging
);

  // State definitions
  typedef enum {WALK_LEFT, WALK_RIGHT, FALL, DIG} state_t;
  state_t state, next_state;

  // State transitions
  always @(posedge clk or posedge areset) begin
    if (areset) begin
      state <= WALK_LEFT;
    end else begin
      case (state)
        WALK_LEFT: begin
          if (ground == 0) next_state = FALL;
          else if (dig) next_state = DIG;
          else if (bump_right) next_state = WALK_RIGHT;
          else next_state = WALK_LEFT;
        end
        WALK_RIGHT: begin
          if (ground == 0) next_state = FALL;
          else if (dig) next_state = DIG;
          else if (bump_left) next_state = WALK_LEFT;
          else next_state = WALK_RIGHT;
        end
        FALL: next_state = FALL;
        DIG: next_state = DIG;
      endcase
      state <= next_state;
    end
  end

  // Output assignments
  assign walk_left = (state == WALK_LEFT);
  assign walk_right = (state == WALK_RIGHT);
  assign aaah = (state == FALL);
  assign digging = (state == DIG);

endmodule

