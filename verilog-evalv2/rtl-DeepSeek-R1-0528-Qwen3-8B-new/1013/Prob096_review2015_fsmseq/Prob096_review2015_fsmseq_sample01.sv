
module TopModule (
  input  logic clk,
  input  logic reset,
  input  logic data,
  output logic start_shifting
);

  // State encoding: 4 bits for 5 states (0-4)
  typedef enum logic [3:0] {
    S0 = 4'b0000,  // Start or reset state
    S1 = 4'b0001,  // First '1' in sequence
    S2 = 4'b0010,  // Second '1' in sequence
    S3 = 4'b0011,  // '0' in sequence
    S4 = 4'b0100   // '1' completes sequence
  } state_t;

  state_t current_state, next_state;

  // Combinational logic for next state
  always_comb begin
    next_state = current_state;
    case (current_state)
      S0: begin
        if (data) next_state = S1;
        else next_state = S0;
      end
      S1: begin
        if (data) next_state = S2;
        else next_state = S0;
      end
      S2: begin
        if (~data) next_state = S3;
        else next_state = S0;
      end
      S3: begin
        if (data) next_state = S4;
        else next_state = S0;
      end
      S4: next_state = S4; // Stay in S4 until reset
    endcase
  end

  // State register and output
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      current_state <= S0;
      start_shifting <= 0;
    end else begin
      current_state <= next_state;
      start_shifting <= (current_state == S4);
    end
  end

endmodule

// VERILOG-EVAL: response did not use <CODE></CODE> correctly

