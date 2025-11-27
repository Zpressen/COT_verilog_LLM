
module TopModule (
  input  clk,
  input  reset,
  input  in,
  output done
);

  // State definitions
  typedef enum logic [2:0] {
    IDLE = 3'b000,
    START = 3'b001,
    DATA = 3'b010,
    STOP = 3'b011,
    IDLE_DONE = 3'b100
  } state_t;

  // State register
  state_t current_state, next_state;

  // Data register for 8 bits
  reg [7:0] data_reg;

  // Counter for data bits
  reg [2:0] cnt;

  // Done signal
  assign done = (current_state == IDLE_DONE) ? 1'b1 : 1'b0;

  // FSM logic
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      current_state <= IDLE;
      cnt <= 3'b000;
      data_reg <= 8'b0;
    end else begin
      current_state <= next_state;
      cnt <= next_cnt;
      data_reg <= next_data_reg;
    end
  end

  // Next state and output logic
  always @(*) begin
    next_state = current_state;
    next_cnt = cnt;
    next_data_reg = data_reg;

    case (current_state)
      IDLE: begin
        if (in == 1'b0) next_state = START;
        else next_state = IDLE;
      end

      START: begin
        next_state = DATA;
      end

      DATA: begin
        next_data_reg = {data_reg[7:1], in}; // Shift right, new bit to LSB
        next_cnt = cnt + 1;
        if (cnt == 3'b111) next_state = STOP;
        else next_state = DATA;
      end

      STOP: begin
        if (in == 1'b1) next_state = IDLE_DONE;
        else next_state = STOP;
      end

      IDLE_DONE: begin
        if (in == 1'b0) next_state = START;
        else next_state = IDLE_DONE;
      end
    endcase
  end

endmodule

