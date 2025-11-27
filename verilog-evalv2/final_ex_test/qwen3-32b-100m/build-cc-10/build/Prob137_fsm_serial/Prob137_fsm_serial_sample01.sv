

module TopModule (
  input clk,
  input in,
  input reset,
  output done
);

typedef enum logic [1:0] {IDLE=2'b00, DATA=2'b01, STOP=2'b10, ERROR=2'b11} state_t;
state_t state, next_state;
logic [2:0] counter, next_counter;

always_ff @(posedge clk or posedge reset) begin
  if (reset) begin
    state <= IDLE;
    counter <= 0;
  end else begin
    state <= next_state;
    counter <= next_counter;
  end
end

always_comb begin
  next_state = state;
  next_counter = counter;
  case (state)
    IDLE: begin
      if (in == 0) begin
        next_state = DATA;
        next_counter = 0;
      end
    end
    DATA: begin
      if (counter == 7) begin
        next_state = STOP;
      end else begin
        next_counter = counter + 1;
      end
    end
    STOP: begin
      if (in == 1) begin
        next_state = IDLE;
      end else begin
        next_state = ERROR;
      end
    end
    ERROR: begin
      if (in == 1) begin
        next_state = IDLE;
      end
    end
    default: next_state = IDLE;
  endcase
end

assign done = (state == STOP) && (in == 1);

endmodule

