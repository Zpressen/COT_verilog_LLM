
module TopModule (
  input  clk,
  input  x,
  input  y,
  output Y0,
  output z
);

  // State encoding: 3 bits for states 000 to 111
  typedef enum logic [2:0] {
    S0 = 3'b000,
    S1 = 3'b001,
    S2 = 3'b010,
    S3 = 3'b011,
    S4 = 3'b100,
    S5 = 3'b101,
    S6 = 3'b110,
    S7 = 3'b111
  } state_t;

  state_t current_state, next_state;

  // Output logic: z is 1 only for states 011 and 100
  assign z = (current_state == 3'b011 || current_state == 3'b100) ? 1'b1 : 1'b0;

  // Next state logic based on current state and input x
  always_comb begin
    case (current_state)
      S0: next_state = (x == 1'b0) ? S0 : S1;
      S1: next_state = (x == 1'b0) ? S1 : S4;
      S2: next_state = (x == 1'b0) ? S2 : S1;
      S3: next_state = (x == 1'b0) ? S1 : S2;
      S4: next_state = (x == 1'b0) ? S3 : S4;
      S5: next_state = (x == 1'b0) ? S5 : S4;
      S6: next_state = (x == 1'b0) ? S6 : S5;
      S7: next_state = (x == 1'b0) ? S7 : S6;
      default: next_state = current_state;
    endcase
  end

  // State register with clock enable (always enabled)
  always_ff @(posedge clk) begin
    current_state <= next_state;
  end

  // Output Y0 is the least significant bit of the current state
  assign Y0 = current_state[0];

endmodule

// VERILOG-EVAL: response did not use <CODE></CODE> correctly

