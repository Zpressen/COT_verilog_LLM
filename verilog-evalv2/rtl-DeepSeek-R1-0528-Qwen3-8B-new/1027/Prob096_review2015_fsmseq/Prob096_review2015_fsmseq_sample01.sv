
module TopModule(
  input clk,
  input reset,
  input data,
  output start_shifting
);

  // State definitions
  typedef enum logic [1:0] {S0, S1, S2, S3, S4} state_t;
  state_t current_state, next_state;

  // Output logic
  assign start_shifting = (current_state == S4);

  // State transition logic
  always @(posedge clk) begin
    if (reset) begin
      current_state <= S0;
    end else begin
      case (current_state)
        S0: begin
          if (data == 1'b1) next_state = S1;
          else next_state = S0;
        end
        S1: begin
          if (data == 1'b1) next_state = S2;
          else next_state = S0;
        end
        S2: begin
          if (data == 1'b1) next_state = S3;
          else next_state = S0;
        end
        S3: begin
          if (data == 1'b0) next_state = S4;
          else next_state = S0;
        end
        S4: next_state = S4; // Stay in S4 once sequence is found
      endcase
    end
  end

endmodule

