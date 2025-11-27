
module TopModule (
  input  logic clk,
  input  logic reset,
  output logic [4:0] q
);

  // Register to hold the LFSR state
  logic [4:0] q_reg;

  // Always block for synchronous reset and clock edge
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      // Active-high reset: set q to 1 (binary 00001)
      q_reg <= 5'b1;
    end else begin
      // Galois LFSR logic: shift right and XOR taps with LSB
      q_reg <= {q_reg[3:0], (q_reg[4] ^ q_reg[2] ^ q_reg[0])};
    end
  end

  // Assign output
  assign q = q_reg;

endmodule

// VERILOG-EVAL: response did not use <CODE></CODE> correctly

