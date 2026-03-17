
module TopModule (
  input  clk,
  input  reset,
  input  logic [7:0] in,
  output logic done
);

  // State definition
  typedef enum logic [1:0] {
    IDLE = 2'b00,   // State 0: waiting for first byte
    BYTE1 = 2'b01,  // State 1: first byte found
    BYTE2 = 2'b10,  // State 2: second byte found
    BYTE3 = 2'b11   // State 3: third byte found, signal done
  } state_t;

  // State register
  state_t current_state, next_state;

  // Combinational logic for next state
  always_comb begin
    next_state = current_state;
    case (current_state)
      IDLE: begin
        if (in[3]) next_state = BYTE1;
        else next_state = IDLE;
      end
      BYTE1: next_state = BYTE2;
      BYTE2: next_state = BYTE3;
      BYTE3: next_state = IDLE;
      default: next_state = IDLE; // Safety
    endcase
  end

  // Synchronous state update
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      current_state <= IDLE;
    end else begin
      current_state <= next_state;
    end
  end

  // Output logic
  assign done = (current_state == BYTE3);

endmodule

