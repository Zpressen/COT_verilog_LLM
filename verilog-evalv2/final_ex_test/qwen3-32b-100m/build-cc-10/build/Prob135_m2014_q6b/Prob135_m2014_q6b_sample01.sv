

module TopModule (
  input [3:1] y,
  input w,
  output reg Y2
);

always @* begin
  Y2 = (y == 3'b001) | ((y == 3'b010) & w) | ((y == 3'b100) & w) | (y == 3'b101);
end

endmodule

