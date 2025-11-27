
module TopModule(
  input  clk,
  input  reset,
  input  [7:0] in,
  output [23:0] out_bytes,
  output done
);

  // State definitions
  typedef enum {IDLE, BYTE1, BYTE2, BYTE3} state_t;
  state_t state, next_state;

  // Registers for byte storage
  reg [7:0] byte1, byte2, byte3;
  reg done_reg;

  // FSM always block
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      state <= IDLE;
      done_reg <= 1'b0;
      byte1 <= 8'b0;
      byte2 <= 8'b0;
      byte3 <= 8'b0;
    end else begin
      state <= next_state;
      done <= done_reg;
    end
  end

  // Combinational logic for next state
  always @(*) begin
    case (state)
      IDLE: begin
        if (in[3]) next_state = BYTE1;
        else next_state = IDLE;
      end
      BYTE1: next_state = BYTE2;
      BYTE2: next_state = BYTE3;
      BYTE3: begin
        done_reg <= 1'b1;
        next_state = IDLE;
      end
      default: next_state = IDLE;
    endcase
  end

  // Datapath for output
  assign out_bytes = {byte1, byte2, byte3};
endmodule

