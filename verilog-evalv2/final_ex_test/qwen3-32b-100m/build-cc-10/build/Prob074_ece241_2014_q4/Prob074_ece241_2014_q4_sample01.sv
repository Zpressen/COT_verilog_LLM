

module TopModule (
  input clk,
  input x,
  output z
);

logic q1, q2, q3;
logic q1_d, q2_d, q3_d;

assign q1_d = x ^ q1;
assign q2_d = x & ~q2;
assign q3_d = x | ~q3;

always_ff @(posedge clk) begin
  q1 <= q1_d;
  q2 <= q2_d;
  q3 <= q3_d;
end

assign z = ~(q1 | q2 | q3);

endmodule

