

module TopModule (
  input clk,
  input [7:0] in,
  input reset,
  output done
);

  typedef enum logic [1:0] { IDLE, S1, S2, S_DONE } state_t;
  state_t current_state, next_state;

  always_ff @(posedge clk) begin
    if (reset) begin
      current_state <= IDLE;
    end else begin
      current_state <= next_state;
    end
  end

  always_comb begin
    next_state = current_state;
    done = 1'b0;

    case (current_state)
      IDLE: begin
        if (in[3]) begin
          next_state = S1;
        end
      end

      S1: begin
        next_state = S2;
      end

      S2: begin
        next_state = S_DONE;
      end

      S_DONE: begin
        next_state = IDLE;
        done = 1'b1;
      end

      default: next_state = IDLE;
    endcase
  end

endmodule

