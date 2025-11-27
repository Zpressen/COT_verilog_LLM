
module TopModule
(
  input  logic clk,
  input  logic reset,
  input  logic [7:0] d,
  output logic [7:0] q
);

  // Instantiate 8 D flip-flops with synchronous reset
  genvar i;
  generate
    for (i = 0; i < 8; i = i + 1) begin : DFF_ARRAY
      DFF DFF_inst (
        .clk(clk),
        .reset(reset),
        .d(d[i]),
        .q(q[i])
      );
    end
  endgenerate

endmodule

// D flip-flop implementation
module DFF
(
  input  logic clk,
  input  logic reset,
  input  logic d,
  output logic q
);

  always_ff @(posedge clk) begin
    if (reset)
      q <= 0;
    else
      q <= d;
  end

endmodule

