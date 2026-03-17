
module TopModule (
  input  clk,
  input  reset,
  output reg [3:0] q
);

  reg [3:0] count_reg;

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      count_reg <= 0;
    end else begin
      if (count_reg < 10) begin
        count_reg <= count_reg + 1;
      end else begin
        count_reg <= 0;
      end
    end
  end

  assign q = count_reg + 1;

endmodule

