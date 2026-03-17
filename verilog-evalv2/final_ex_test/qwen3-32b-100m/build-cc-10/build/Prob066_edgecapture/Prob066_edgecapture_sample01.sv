

module TopModule (
  input clk,
  input reset,
  input [31:0] in,
  output reg [31:0] out
);

reg [31:0] previous_in;

always @(posedge clk) begin
  if (reset) begin
    out <= 32'b0;
    previous_in <= in;
  end else begin
    previous_in <= in;
    out <= out | (previous_in & ~in);
  end
end

endmodule

