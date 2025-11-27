
module TopModule
(
  input  logic in,
  input  logic [3:0] state,
  output logic [3:0] next_state,
  output logic out
);

  // State transition logic
  always_comb
  begin
    case (state)
      4'b0001: // A
        if (in) next_state = 4'b0010; // B
        else next_state = 4'b0001; // A
      4'b0010: // B
        if (in) next_state = 4'b0010; // B
        else next_state = 4'b0100; // C
      4'b0100: // C
        if (in) next_state = 4'b1000; // D
        else next_state = 4'b0001; // A
      4'b1000: // D
        if (in) next_state = 4'b0010; // B
        else next_state = 4'b0100; // C
      default: next_state = 4'b0001; // Default to A
    endcase
  end

  // Output logic
  assign out = (state == 4'b1000) ? 1'b1 : 1'b0;

endmodule

