
module TopModule(
  input  logic in,
  input  logic [3:0] state,
  output logic [3:0] next_state,
  output logic out
);

  // Combinational logic for state transition
  always @(*) begin
    case (state)
      4'b0001: // A
        if (in == 1'b0) next_state = 4'b0001;
        else next_state = 4'b0010;
      4'b0010: // B
        if (in == 1'b0) next_state = 4'b0100;
        else next_state = 4'b0010;
      4'b0100: // C
        if (in == 1'b0) next_state = 4'b0001;
        else next_state = 4'b1000;
      4'b1000: // D
        if (in == 1'b0) next_state = 4'b0100;
        else next_state = 4'b0010;
      default: next_state = 4'b0000; // Default case for safety
    endcase
  end

  // Combinational logic for output
  always @(*) begin
    case (state)
      4'b0001: out = 1'b0;
      4'b0010: out = 1'b0;
      4'b0100: out = 1'b0;
      4'b1000: out = 1'b1;
      default: out = 1'b0; // Default case for safety
    endcase
  end

endmodule

