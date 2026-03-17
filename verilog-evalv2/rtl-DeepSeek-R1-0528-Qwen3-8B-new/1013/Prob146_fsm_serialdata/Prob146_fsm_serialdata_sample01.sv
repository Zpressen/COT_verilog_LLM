
module TopModule (
  input  clk,
  input  reset,
  input  in,
  output logic [7:0] out_byte,
  output logic done
);

  // State definitions
  typedef enum logic [3:0] {
    IDLE,
    START,
    DATA0,
    DATA1,
    DATA2,
    DATA3,
    DATA4,
    DATA5,
    DATA6,
    DATA7,
    STOP,
    DONE
  } state_t;

  // State register
  state_t current_state, next_state;

  // FSM logic
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      current_state <= IDLE;
      out_byte <= 0;
      done <= 0;
    end else begin
      current_state <= next_state;
      if (current_state == DONE) begin
        out_byte <= 0; // Reset output on new byte
        done <= 0;
      end
    end
  end

  // Next state logic
  always_comb begin
    next_state = current_state;
    out_byte = out_byte;
    done = 0;

    case (current_state)
      IDLE: begin
        if (in == 0) begin // Start bit detected
          next_state = START;
        end else begin
          next_state = IDLE;
        end
      end

      START: begin
        next_state = DATA0;
      end

      DATA0: begin
        out_byte = {in, out_byte[7:1]}; // Shift in LSB first
        next_state = DATA1;
      end

      DATA1: begin
        out_byte = {in, out_byte[7:1]};
        next_state = DATA2;
      end

      DATA2: begin
        out_byte = {in, out_byte[7:1]};
        next_state = DATA3;
      end

      DATA3: begin
        out_byte = {in, out_byte[7:1]};
        next_state = DATA4;
      end

      DATA4: begin
        out_byte = {in, out_byte[7:1]};
        next_state = DATA5;
      end

      DATA5: begin
        out_byte = {in, out_byte[7:1]};
        next_state = DATA6;
      end

      DATA6: begin
        out_byte = {in, out_byte[7:1]};
        next_state = DATA7;
      end

      DATA7: begin
        next_state = STOP;
      end

      STOP: begin
        if (in == 1) begin // Valid stop bit
          next_state = DONE;
          done = 1;
        end else begin
          next_state = STOP; // Wait for stop bit
        end
      end

      DONE: begin
        next_state = IDLE;
      end
    endcase
  end

endmodule

// VERILOG-EVAL: response did not use <CODE></CODE> correctly

