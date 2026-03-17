
module TopModule(
  input  clk,
  input  areset,
  input  in,
  output reg out
);

  reg [1:0] current_state;

  // Next state logic
  always @(*) begin
    case (current_state)
      2'b00: // A
        if (in == 0) next_state = 2'b00;
        else next_state = 2'b01;
      2'b01: // B
        if (in == 0) next_state = 2'b10;
        else next_state = 2'b01;
      2'b10: // C
        if (in == 0) next_state = 2'b00;
        else next_state = 2'b11;
      2'b11: // D
        if (in == 0) next_state = 2'b10;
        else next_state = 2'b01;
      default: next_state = 2'b00;
    endcase
  end

  // Output logic
  always @(*) begin
    out = (current_state == 2'b11) ? 1'b1 : 1'b0;
  end

  // State update logic
  always @(posedge clk or posedge areset) begin
    if (areset)
      current_state <= 2'b00;
    else
      current_state <= next_state;
  end

endmodule

