

module TopModule (
  input clk,
  input areset,
  input x,
  output z
);

logic A, B;

// Next state logic
logic next_A, next_B;

assign next_A = A & ~x;
assign next_B = (A & x) | B;

// State registers with asynchronous reset
always @(posedge clk or posedge areset) begin
  if (areset) begin
    A <= 1'b1;
    B <= 1'b0;
  end else begin
    A <= next_A;
    B <= next_B;
  end
end

// Output logic
assign z = (A & x) | (B & ~x);

endmodule

