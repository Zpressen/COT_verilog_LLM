
module TopModule (
  input  d,
  input  done_counting,
  input  ack,
  input  [9:0] state,
  output B3_next,
  output S_next,
  output S1_next,
  output Count_next,
  output Wait_next,
  output done,
  output counting,
  output shift_ena
);

  // State encoding: (S, S1, S11, S110, B0, B1, B2, B3, Count, Wait) = (10'b0000000001, 10'b0000000010, 10'b0000000100, 10'b0000001000, 10'b0000010000, 10'b0000100000, 10'b0001000000, 10'b0010000000, 10'b0100000000, 10'b1000000000)

  // Next-state logic
  always @(*) begin
    case (state)
      10'b0000000001: // S
        if (d == 0) next_state = 10'b0000000001; // S
        else next_state = 10'b0000000010; // S1
      10'b0000000010: // S1
        if (d == 0) next_state = 10'b0000000001; // S
        else next_state = 10'b0000000100; // S11
      10'b0000000100: // S11
        if (d == 0) next_state = 10'b0000000100; // S11
        else next_state = 10'b0000000100; // S11
      10'b0000001000: // S110
        if (d == 0) next_state = 10'b0000000001; // S
        else next_state = 10'b0000010000; // B0
      10'b0000010000: // B0
        next_state = 10'b0000100000; // B1
      10'b0000100000: // B1
        next_state = 10'b0001000000; // B2
      10'b0001000000: // B2
        next_state = 10'b0010000000; // B3
      10'b0010000000: // B3
        next_state = 10'b0100000000; // Count
      10'b0100000000: // Count
        if (done_counting == 0) next_state = 10'b0100000000; // Count
        else next_state = 10'b1000000000; // Wait
      10'b1000000000: // Wait
        if (ack == 0) next_state = 10'b1000000000; // Wait
        else next_state = 10'b0000000001; // S
      default: next_state = 10'b0000000001; // Default to S
    endcase
  end

  // Output logic
  assign B3_next = (state == 10'b0010000000);
  assign S_next = (state == 10'b0000000001);
  assign S1_next = (state == 10'b0000000010);
  assign Count_next = (state == 10'b0100000000);
  assign Wait_next = (state == 10'b1000000000);
  assign done = (state == 10'b1000000000);
  assign counting = (state == 10'b0100000000);
  assign shift_ena = (state == 10'b0000000100) | (state == 10'b0000010000) | (state == 10'b0001000000) | (state == 10'b0010000000);

endmodule

