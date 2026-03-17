
module TopModule
(
  input  logic in,
  input  logic [9:0] state,
  output logic [9:0] next_state,
  output logic out1,
  output logic out2
);

  // State transition logic
  always_comb begin
    case (state)
      10'b0000000001: // S0
        if (in) next_state = 10'b0000000010; // S1
        else next_state = 10'b0000000001; // S0
      10'b0000000010: // S1
        if (in) next_state = 10'b0000000100; // S2
        else next_state = 10'b0000000001; // S0
      10'b0000000100: // S2
        if (in) next_state = 10'b0000001000; // S3
        else next_state = 10'b0000000001; // S0
      10'b0000001000: // S3
        if (in) next_state = 10'b0000010000; // S4
        else next_state = 10'b0000000001; // S0
      10'b0000010000: // S4
        if (in) next_state = 10'b0000100000; // S5
        else next_state = 10'b0000000001; // S0
      10'b0000100000: // S5
        if (in) next_state = 10'b0001000000; // S6
        else next_state = 10'b0000000001; // S0
      10'b0001000000: // S6
        if (in) next_state = 10'b0010000000; // S7
        else next_state = 10'b0000000001; // S0
      10'b0010000000: // S7
        if (in) next_state = 10'b0010000000; // S7 (self-loop)
        else next_state = 10'b0000000001; // S0
      10'b0100000000: // S8
        if (in) next_state = 10'b0000000010; // S1
        else next_state = 10'b0000000001; // S0
      10'b1000000000: // S9
        if (in) next_state = 10'b0000000010; // S1
        else next_state = 10'b0000000001; // S0
      default: next_state = 10'b0000000001; // Default to S0
    endcase
  end

  // Output logic
  assign out1 = (state == 10'b0100000000) | (state == 10'b1000000000); // S8 or S9
  assign out2 = (state == 10'b0010000000); // S7

endmodule

