
module TopModule(
  input clk,
  input enable,
  input S,
  input A,
  input B,
  input C,
  output Z
);

  reg [7:0] Q;
  wire [2:0] sel;

  // 3-to-8 decoder for ABC inputs
  assign sel = {A, B, C};

  // 8-bit shift register with synchronous enable
  always @(posedge clk) begin
    if (enable)
      Q <= {S, Q[7:1]};
  end

  // Multiplexer selects Q output based on ABC
  assign Z = Q[sel];

endmodule

