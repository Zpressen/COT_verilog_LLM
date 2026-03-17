
module TopModule (
  input clk,
  input L,
  input r,
  input shifted,
  output q
);

  assign mux_out = (L) ? r : shifted;

  always @(posedge clk) begin
    q <= mux_out;
  end

endmodule

