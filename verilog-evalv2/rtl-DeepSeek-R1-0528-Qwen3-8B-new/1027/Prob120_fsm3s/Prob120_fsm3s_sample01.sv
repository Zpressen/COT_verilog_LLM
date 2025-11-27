
module TopModule(
  input clk,
  input reset,
  input in,
  output out
);

  // State encoding: A=00, B=01, C=10, D=11
  reg [1:0] state, next_state;
  assign out = (state == 2'b11) ? 1'b1 : 1'b0;

  always @(posedge clk) begin
    if (reset)
      state <= 2'b00; // Reset to state A
    else
      state <= next_state;
  end

  always @(*) begin
    case (state)
      2'b00: // A
        if (in == 1'b0) next_state <= 2'b00;
        else next_state <= 2'b01;
      2'b01: // B
        if (in == 1'b0) next_state <= 2'b10;
        else next_state <= 2'b01;
      2'b10: // C
        if (in == 1'b0) next_state <= 2'b00;
        else next_state <= 2'b11;
      2'b11: // D
        if (in == 1'b0) next_state <= 2'b10;
        else next_state <= 2'b01;
    endcase
  end

endmodule

