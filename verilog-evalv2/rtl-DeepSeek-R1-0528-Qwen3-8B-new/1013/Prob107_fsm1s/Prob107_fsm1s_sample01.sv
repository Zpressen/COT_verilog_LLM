
module TopModule (
  input  logic clk,
  input  logic reset,
  input  logic in,
  output logic out
);

  // State encoding: 0 = A, 1 = B
  logic state;

  // State transition logic
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      state <= 1;  // Reset to state B
    end else begin
      case (state)
        0: begin  // State A
          if (in == 0) state <= 1;  // Transition to B
          else state <= 0;           // Stay in A
        end
        1: begin  // State B
          if (in == 0) state <= 0;  // Transition to A
          else state <= 1;           // Stay in B
        end
      endcase
    end
  end

  // Output logic (Moore machine)
  assign out = state;

endmodule

