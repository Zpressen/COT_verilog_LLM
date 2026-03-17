

module TopModule (
  input [7:0] a,
  input [7:0] b,
  input [7:0] c,
  input [7:0] d,
  output reg [7:0] min
);

  reg [7:0] first_min, second_min;

  always @* begin
    first_min = (a < b) ? a : b;
    second_min = (first_min < c) ? first_min : c;
    min = (second_min < d) ? second_min : d;
  end

endmodule

