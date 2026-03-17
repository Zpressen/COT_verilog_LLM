
module TopModule
(
  input  clk,
  input  reset,
  input  s[2:0],
  output fr2,
  output fr1,
  output fr0,
  output dfr
);

  // State definitions
  typedef enum logic [1:0] {
    STATE_ABOVE,   // Water level above s[2]
    STATE_BETWEEN2, // Between s[2] and s[1]
    STATE_BETWEEN1, // Between s[1] and s[0]
    STATE_BELOW    // Below s[0]
  } state_t;

  // State register
  state_t current_state, next_state;

  // Internal signals
  logic level_rising;

  // State transition logic
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      current_state <= STATE_BELOW;
      level_rising <= 0;
    end else begin
      current_state <= next_state;
      level_rising <= (current_state != next_state) && (next_state > current_state);
    end
  end

  // Next state logic
  always_comb begin
    next_state = current_state;
    case (current_state)
      STATE_ABOVE: begin
        if (s[2] == 0) next_state = STATE_BELOW;
        else next_state = STATE_ABOVE;
      end
      STATE_BETWEEN2: begin
        if (s[1] == 0) next_state = STATE_BELOW;
        else if (s[2] == 1) next_state = STATE_ABOVE;
        else next_state = STATE_BETWEEN2;
      end
      STATE_BETWEEN1: begin
        if (s[0] == 0) next_state = STATE_BELOW;
        else if (s[1] == 1) next_state = STATE_BETWEEN2;
        else next_state = STATE_BETWEEN1;
      end
      STATE_BELOW: begin
        if (s[0] == 1) next_state = STATE_BETWEEN1;
        else next_state = STATE_BELOW;
      end
    endcase
  end

  // Output logic
  assign fr2 = (current_state == STATE_BELOW);
  assign fr1 = (current_state == STATE_BETWEEN1 || current_state == STATE_BELOW);
  assign fr0 = (current_state == STATE_BETWEEN2 || current_state == STATE_BETWEEN1 || current_state == STATE_BELOW);
  assign dfr = level_rising;

endmodule

