

module TopModule (
  input clk,
  input in,
  input areset,
  output out
);

  reg current_state;

  always @(posedge clk or posedge areset) begin
    if (areset) begin
      current_state <= 1'b1; // Reset to state B
    end else begin
      current_state <= in ^ ~current_state;
    end
  end

  assign out = current_state;

endmodule

