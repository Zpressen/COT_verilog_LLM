
module TopModule(
  input  clk,
  input  areset,
  input  j,
  input  k,
  output out
);

  // State encoding: OFF=0, ON=1
  logic state_reg;

  // State transition logic
  always @(posedge clk or posedge areset) begin
    if (areset) begin
      state_reg <= 0; // Reset to OFF
    end else begin
      case (state_reg)
        0: // OFF
          if (j) state_reg <= 1; // j=1 -> ON
          else state_reg <= 0; // j=0 -> OFF
        1: // ON
          if (k) state_reg <= 0; // k=1 -> OFF
          else state_reg <= 1; // k=0 -> ON
      endcase
    end
  end

  // Output is the current state
  assign out = state_reg;

endmodule

