
module TopModule(
  input clk,
  input x,
  output z
);

  reg [2:0] Q1, Q2, Q3;

  always @(posedge clk) begin
    Q1 <= x ^ Q1;
    Q2 <= x & ~Q2;
    Q3 <= x | ~Q3;
  end

  assign z = ~(Q1 & Q2 & Q3);

endmodule

