
module TopModule (
  input  clk,
  input  reset,
  input  data,
  output reg [3:0] count,
  output reg counting,
  output reg done,
  input  ack
);

  // State definitions
  typedef enum {SEARCH, READ_DELAY, COUNT_DOWN, DONE} state_t;
  state_t state, next_state;

  // Signals for pattern detection in SEARCH
  reg [3:0] pattern_shift_reg;

  // Signals for reading delay bits in READ_DELAY
  reg [3:0] delay_shift_reg;
  reg [3:0] delay_val;

  // Signals for counting in COUNT_DOWN
  reg [3:0] remaining_time;
  reg [3:0] completed_chunks;
  reg [10:0] cycle_counter;

  // State machine always block
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      state <= SEARCH;
      pattern_shift_reg <= 0;
      delay_shift_reg <= 0;
      delay_val <= 0;
      remaining_time <= 0;
      completed_chunks <= 0;
      cycle_counter <= 0;
      counting <= 0;
      done <= 0;
    end else begin
      case (state)
        SEARCH: begin
          pattern_shift_reg <= {pattern_shift_reg[2:0], data};
          if (pattern_shift_reg == 4'b1101) begin
            next_state = READ_DELAY;
          end else begin
            next_state = SEARCH;
          end
        end

        READ_DELAY: begin
          delay_shift_reg <= {delay_shift_reg[2:0], data};
          if (delay_shift_reg == 4'b1111) begin
            delay_val <= delay_shift_reg;
            next_state = COUNT_DOWN;
          end else begin
            next_state = READ_DELAY;
          end
        end

        COUNT_DOWN: begin
          counting <= 1;
          // Initialize remaining_time and completed_chunks
          remaining_time <= delay_val;
          completed_chunks <= 0;
          cycle_counter <= 0;
          // Handle the counting logic
          if (cycle_counter == 999) begin
            cycle_counter <= 0;
            completed_chunks <= completed_chunks + 1;
            remaining_time <= delay_val - completed_chunks;
            if (completed_chunks == delay_val) begin
              done <= 1;
              next_state = DONE;
            end else begin
              next_state = COUNT_DOWN;
            end
          end else begin
            cycle_counter <= cycle_counter +  1;
            next_state = COUNT_DOWN;
          end
        end

        DONE: begin
          counting <= 0;
          if (ack) begin
            next_state = SEARCH;
          end else begin
            next_state = DONE;
          end
        end

        default: next_state = SEARCH;
      endcase
      state <= next_state;
    end
  end

  assign count = remaining_time;

endmodule

