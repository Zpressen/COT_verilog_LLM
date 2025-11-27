
module TopModule
(
  input  logic in,
  input  logic [1:0] state,
  output logic [1:0] next_state,
  output logic out
);

  always_comb begin
    case (state)
      2'b00: // A
        if (in) next_state = 2'b01; // B
        else next_state = 2'b00; // A
        out = 0;
      2'b01: // B
        if (in) next_state = 2'b01; // B
        else next_state = 2'b10; // C
        out = 0;
      2'b10: // C
        if (in) next_state = 2'b11; // D
        else next_state = 2'b00; // A
        out = 0;
      2'b11: // D
        if (in) next_state = 2'b01; // B
        else next_state = 2'b01; // B
        out = 1;
    endcase
  end

endmodule

