
module TopModule
(
  input  logic clk,
  input  logic resetn,
  input  logic [1:0] byteena,
  input  logic [15:0] d,
  output logic [15:0] q
);

  // Internal signals for byte-enable control
  logic [15:0] q_reg;

  // Synchronous reset and byte-enable controlled D flip-flops
  always @(posedge clk) begin
    if (!resetn) begin
      // Active-low synchronous reset: clear all bits
      q_reg <= 16'b0;
    end else begin
      // Conditional byte-enable logic
      q_reg[15:8] <= (byteena[1] && ~byteena[0]) ? d[15:8] : q_reg[15:8];
      q_reg[7:0]  <= (byteena[0] && ~byteena[1]) ? d[7:0]  : q_reg[7:0];
    end
  end

  // Output assignment
  assign q = q_reg;

endmodule

