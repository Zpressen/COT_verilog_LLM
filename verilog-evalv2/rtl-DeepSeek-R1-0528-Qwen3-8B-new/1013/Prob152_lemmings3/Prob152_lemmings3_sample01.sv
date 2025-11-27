
module TopModule
(
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
  typedef enum logic [1:0] {
    WALK_LEFT,   // Lemming is walking left
    WALK_RIGHT,  // Lemming is walking right
    FALLING,     // Lemming is falling (no ground)
    DIGGING      // Lemming is digging
  } state_t;

  // State register
  state_t state, next_state;

  // Combinational logic for next state and outputs
  always_comb begin
    next_state = state;
    walk_left = 1'b0;
    walk_right = 1'b0;
    aaah = 1'b0;
    digging = 1'b0;

    case (state)
      WALK_LEFT: begin
        // Walking left: check for fall, dig, or direction change
        if (!ground) begin
          next_state = FALLING;
          aaah = 1'b1;
        end else if (dig) begin
          next_state = DIGGING;
          digging = 1'b1;
        end else if (bump_right) begin
          next_state = WALK_RIGHT;
          walk_right = 1'b1;
        end
      end

      WALK_RIGHT: begin
        if (!ground) begin
          next_state = FALLING;
          aaah = 1'b1;
        end else if (dig) begin
          next_state = DIGGING;
          digging = 1'b1;
        end else if (bump_left) begin
          next_state = WALK_LEFT;
          walk_left = 1'b1;
        end
      end

      FALLING: begin
        // Falling: ignore all inputs except ground becoming 1
        if (ground) begin
          next_state = state; // Resume walking in current direction
        end
      end

      DIGGING: begin
        // Digging: continue until ground disappears
        if (!ground) begin
          next_state = FALLING;
          aaah = 1'b1;
        end else if (dig) begin
          // Continue digging if dig remains high
          digging = 1'b1;
        end
      end
    endcase
  end

  // Sequential logic for state register
  always @(posedge clk or posedge areset) begin
    if (areset) begin
      state <= WALK_LEFT;
    end else begin
      state <= next_state;
    end
  end

endmodule

