
module TopModule(
  input  clk,
  input  areset,
  input  logic [7:0] d,
  output logic [7:0] q
);

  // Parameter for width
  parameter WIDTH = 8;

  // Registers for DFFs
  logic [WIDTH-1:0] q_reg;

  // Always block for synchronous logic with async reset
  always_ff @(posedge clk or posedge areset) begin
    if (areset) begin
      q_reg <= 8'b0;
    end else begin
      q_reg <= d;
    end
  end

  assign q = q_reg;

endmodule

