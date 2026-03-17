
module TopModule
(
  input  logic clk,
  input  logic j,
  input  logic k,
  output logic Q
);

  always @(posedge clk) begin
    case ({j, k})
      2'b00: Q <= Q;   // J=0, K=0: no change
      2'b01: Q <= 0;   // J=0, K=1: reset to 0
      2'b10: Q <= 1;   // J=1, K=0: set to 1
      2'b11: Q <= ~Q;  // J=1, K=1: toggle
    endcase
  end

endmodule

