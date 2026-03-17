
module TopModule(
  input clk,
  input reset,
  input s,
  input w,
  output z
);

  // State definitions
  typedef enum {A, B} state_t;
  state_t current_state, next_state;

  // Output logic
  assign z = (current_state == B && count == 2) ? 1'b1 : 1'b0;

  // State transitions
  always @(posedge clk) begin
    if (reset) begin
      current_state <= A;
      count <= 3'b0;
    end else begin
      case (current_state)
        A: begin
          if (s) next_state = B;
          else next_state = A;
        end
        B: begin
          // Count w pattern over three cycles
          if (count < 2) begin
            if (w) count <= count + 1;
          end
          next_state = B; // Continue checking
        end
      endcase
    end
  end

endmodule

