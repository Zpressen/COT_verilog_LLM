
module TopModule
(
  input  logic [3:0] x,
  input  logic [3:0] y,
  output logic [4:0] sum
);

  // Ripple-carry adder with overflow detection

  logic carry;
  assign {sum[4], sum[3:0]} = x + y;

  // Overflow detection: 1 when MSB of sum differs from MSBs of inputs
  assign sum[4] = (x[3] & y[3] & ~sum[3]) | (~x[3] & ~y[3] & sum[3]);

endmodule

