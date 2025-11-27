
module TopModule (
  input  logic clk,
  input  logic areset,
  input  logic bump_left,
  input  logic bump_right,
  output logic walk_left,
  output logic walk_right
);

  // State definitions
  typedef enum logic [1:0] {
    LEFT = 2'b00,
    RIGHT = 2'b01
  } state_t;

  // State register
  state_t state, next_state;

  // State transition logic
  always_comb begin
    case (state)
      LEFT: begin
        if (bump_left) next_state = RIGHT;
        else if (bump_right) next_state = RIGHT;
        else next_state = LEFT;
      end
      RIGHT: begin
        if (bump_left) next_state = LEFT;
        else if (bump_right) next_state = LEFT;
        else next_state = RIGHT;
      end
      default: next_state = LEFT;
    endcase
  end

  // State register with asynchronous reset
  always_ff @(posedge clk or posedge areset) begin
    if (areset) begin
      state <= LEFT;
    end else begin
      state <= next_state;
    end
  end

  // Output logic (Moore machine)
  assign walk_left = (state == LEFT);
  assign walk_right = (state == RIGHT);

endmodule

