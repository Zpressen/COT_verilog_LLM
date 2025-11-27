
module TopModule(
  input  logic in,
  input  logic [1:0] state,
  output logic [1:0] next_state,
  output logic out
);

  // Output logic (Moore machine: output depends only on current state)
  always @(*) begin
    case (state)
      2'b00: out = 0;  // State A
      2'b01: out = 0;  // State B
      2'b10: out = 0;  // State C
      2'b11: out = 1;  // State D
      default: out = 0;
    endcase
  end

  // Next state logic (depends on current state and input)
  always @(*) begin
    case (state)
      2'b00: next_state = (in == 1'b0) ? 2'b00 : 2'b01;  // A -> A or B
      2'b01: next_state = (in == 1'b0) ? 2'b10 : 2'b01;  // B -> C or B
      2'b10: next_state = (in == 1'b0) ? 2'b00 : 2'b11;  // C -> A or D
      2'b11: next_state = (in == 1'b0) ? 2'b10 : 2'b01;  // D -> C or B
      default: next_state = 2'b00;
    endcase
  end
endmodule

