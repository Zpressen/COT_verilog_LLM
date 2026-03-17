

module TopModule (
  input clk,
  input [7:0] in,
  output reg [7:0] anyedge
);

reg [7:0] prev1, prev2;

always @(posedge clk) begin
  prev2 <= prev1;
  prev1 <= in;
  anyedge <= prev1 ^ prev2;
end

endmodule

