
module TopModule (
  input  logic clk,
  input  logic areset,
  input  logic bump_left,
  input  logic bump_right,
  input  logic ground,
  input  logic dig,
  output logic walk_left,
  output logic walk_right,
  output logic aaah,
  output logic digging
);

  // State definitions
  typedef enum logic [2:0] {
    WALK_LEFT,
    WALK_RIGHT,
    FALLING,
    DIGGING,
    SPLATTER
  } state_t;

  // State register
  state_t current_state, next_state;

  // Fall counter for splatter detection
  logic [4:0] fall_counter;

  // State transition logic
  always_comb begin
    next_state = current_state;
    walk_left = 1'b0;
    walk_right = 1'b0;
    aaah = 1'b0;
    digging = 1'b0;

    // Reset condition
    if (areset) begin
      next_state = WALK_LEFT;
      walk_left = 1'b1;
    end else begin
      case (current_state)
        WALK_LEFT: begin
          // Check for bump_left or bump_right to switch direction
          if (bump_left) next_state = WALK_RIGHT;
          else if (bump_right) next_state = WALK_LEFT;
          else if (!ground) next_state = FALLING;
          else if (dig) next_state = DIGGING;
          // No action for other inputs
        end

        WALK_RIGHT: begin
          if (bump_left) next_state = WALK_LEFT;
          else if (bump_right) next_state = WALK_RIGHT;
          else if (!ground) next_state = FALLING;
          else if (dig) next_state = DIGGING;
        end

        FALLING: begin
          // Fall continues until ground appears
          if (ground) begin
            // Check fall duration before splatter
            if (fall_counter < 5'b11111) begin
              fall_counter <= fall_counter + 1;
              next_state = WALK_LEFT; // Resume walking in original direction
            end else begin
              next_state = SPLATTER;
            end
          end else begin
            fall_counter <= 5'b0;
          end
        end

        DIGGING: begin
          // Digging continues until ground disappears
          if (!ground) next_state = FALLING;
          else if (dig) next_state = DIGGING; // Continue digging
        end

        SPLATTER: begin
          // No transitions or outputs
        end
      endcase
    end
  end

  // State register and output generation
  always_ff @(posedge clk) begin
    if (areset) begin
      current_state <= WALK_LEFT;
      fall_counter <= 5'b0;
    end else begin
      current_state <= next_state;
      fall_counter <= (current_state == FALLING && ground) ? fall_counter + 1 : fall_counter;
    end
  end

  // Output generation based on current state
  assign walk_left = (current_state == WALK_LEFT) ? 1'b1 : 1'b0;
  assign walk_right = (current_state == WALK_RIGHT) ? 1'b1 : 1'b0;
  assign aaah = (current_state == FALLING) ? 1'b1 : 1'b0;
  assign digging = (current_state == DIGGING) ? 1'b1 : 1'b0;

endmodule

