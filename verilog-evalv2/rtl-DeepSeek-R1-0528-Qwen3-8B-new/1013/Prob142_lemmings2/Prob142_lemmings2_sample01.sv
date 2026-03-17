
module TopModule
(
  input  logic clk,
  input  logic areset,
  input  logic bump_left,
  input  logic bump_right,
  input  logic ground,
  output logic walk_left,
  output logic walk_right,
  output logic aaah
);

  // State definitions
  typedef enum logic [1:0] {
    WALK_LEFT = 2'b00,
    WALK_RIGHT = 2'b01,
    FALL = 2'b10
  } state_t;

  // State register
  state_t state, next_state;

  // Previous walking direction for resuming after fall
  logic prev_walk_left, prev_walk_right;

  // Combinational logic for state transitions
  always_comb begin
    state = state;
    next_state = state;
    walk_left = 1'b0;
    walk_right = 1'b0;
    aaah = 1'b0;

    case (state)
      WALK_LEFT: begin
        // Check for bump or ground
        if (bump_right || bump_left) begin
          next_state = WALK_RIGHT;
        end else if (!ground) begin
          next_state = FALL;
        end else begin
          next_state = WALK_LEFT;
        end
        walk_left = 1'b1;
      end

      WALK_RIGHT: begin
        // Check for bump or ground
        if (bump_left || bump_right) begin
          next_state = WALK_LEFT;
        end else if (!ground) begin
          next_state = FALL;
        end else begin
          next_state = WALK_RIGHT;
        end
        walk_right = 1'b1;
      end

      FALL: begin
        // Resume previous walking direction when ground returns
        if (ground) begin
          next_state = (prev_walk_left) ? WALK_LEFT : WALK_RIGHT;
        end else begin
          next_state = FALL;
        end
        aaah = 1'b1;
      end
    endcase
  end

  // State register with asynchronous reset
  always_ff @(posedge clk or posedge areset) begin
    if (areset) begin
      state <= WALK_LEFT;
      prev_walk_left <= 1'b1;
      prev_walk_right <= 1'b0;
    end else begin
      state <= next_state;
      if (state == WALK_LEFT || state == WALK_RIGHT) begin
        prev_walk_left <= walk_left;
        prev_walk_right <= walk_right;
      end
    end
  end

endmodule

