
module TopModule(
  input  logic [5:0] y,
  input  logic w,
  output logic Y1,
  output logic Y3
);

  // Combinational logic for Y1 (y[1])
  assign Y1 = (y == 6'b000010) | (y == 6'b000100) | (y == 6'b001000) | (y == 6'b010000) | (y == 6'b100000) & w;

  // Combinational logic for Y3 (y[3])
  assign Y3 = (y == 6'b000010) | (y == 6'b000100) | (y == 6'b001000) | (y == 6'b010000) | (y == 6'b100000) & w;

endmodule

