
module TopModule(
  input  logic in,
  input  logic [9:0] state,
  output logic [9:0] next_state,
  output logic out1,
  output logic out2
);

  // Output logic: out2 is 1 only when current state is S7 (state[6] == 1)
  assign out2 = state[6];

  // Next state logic: one-hot encoding of next state based on current state and input
  always @* begin
    case (state)
      10'b0000000001: // S0
        if (in == 1'b0) next_state = 10'b0000000001;
        else next_state = 10'b0000000010;
      10'b0000000010: // S1
        if (in == 1'b0) next_state = 10'b0000000001;
        else next_state = 10'b0000000100;
      10'b0000000100: // S2
        if (in == 1'b0) next_state = 10'b0000000001;
        else next_state = 10'b0000001000;
      10'b0000001000: // S3
        if (in == 1'b0) next_state = 10'b0000000001;
        else next_state = 10'b0000010000;
      10'b0000010000: // S4
        if (in == 1'b0) next_state = 10'b0000000001;
        else next_state = 10'b0000100000;
      10'b0000100000: // S5
        if (in == 1'b0) next_state = 10'b0000000001;
        else next_state = 10'b0001000000;
      10'b0001000000: // S6
        if (in == 1'b0) next_state = 10'b0000000001;
        else next_state = 10'b0010000000;
      10'b0010000000: // S7
        if (in == 1'b0) next_state = 10'b0000000001;
        else next_state = 10'b0010000000;
      10'b0100000000: // S8
        if (in == 1'b0) next_state = 10'b0000000001;
        else next_state = 10'b0000000010;
      10'b1000000000: // S9
        if (in == 1'b0) next_state = 10'b0000000001;
        else next_state = 10'b0000000010;
      default: next_state = 10'b0000000001;
    endcase
  end

endmodule

