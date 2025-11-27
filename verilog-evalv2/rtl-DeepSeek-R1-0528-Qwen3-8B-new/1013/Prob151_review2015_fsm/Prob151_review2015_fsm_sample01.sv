
module TopModule (
  input  clk,
  input  reset,
  input  data,
  input  done_counting,
  input  ack,
  input  pattern_detected,
  output shift_ena,
  output counting,
  output done
);

  // State definition
  enum logic [3:0] {
    IDLE = 4'b0000,
    SHIFT_0 = 4'b0001,
    SHIFT_1 = 4'b0010,
    SHIFT_2 = 4'b0011,
    SHIFT_3 = 4'b0100,
    WAITING = 4'b0101,
    DONE_NOTIFY = 4'b0110,
    ACK_RECEIVED = 4'b0111
  } state, next_state;

  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      state <= IDLE;
      shift_ena <= 0;
      counting <= 0;
      done <= 0;
    end else begin
      case (state)
        IDLE: begin
          shift_ena <= 0;
          counting <= 0;
          done <= 0;
          if (pattern_detected) 
            next_state = SHIFT_0;
          else
            next_state = IDLE;
        end

        SHIFT_0: begin
          shift_ena <= 1;
          counting <= 0;
          done <= 0;
          next_state = SHIFT_1;
        end

        SHIFT_1: begin
          shift_ena <= 1;
          counting <= 0;
          done <= 0;
          next_state = SHIFT_2;
        end

        SHIFT_2: begin
          shift_ena <= 1;
          counting <= 0;
          done <= 0;
          next_state = SHIFT_3;
        end

        SHIFT_3: begin
          shift_ena <= 1;
          counting <= 0;
          done <= 0;
          next_state = WAITING;
        end

        WAITING: begin
          shift_ena <= 0;
          counting <= 1;
          done <= 0;
          if (done_counting) 
            next_state = DONE_NOTIFY;
          else
            next_state = WAITING;
        end

        DONE_NOTIFY: begin
          shift_ena <= 0;
          counting <= 0;
          done <= 1;
          if (ack) 
            next_state = ACK_RECEIVED;
          else
            next_state = DONE_NOTIFY;
        end

        ACK_RECEIVED: begin
          shift_ena <= 0;
          counting <= 0;
          done <= 0;
          if (ack) 
            next_state = IDLE;
          else
            next_state = ACK_RECEIVED;
        end
      endcase
      state <= next_state;
    end
  end

endmodule

