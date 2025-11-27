
module TopModule (
  input clk,
  input logic [7:0] in,
  output logic [7:0] anyedge
);

  // Registers for previous state of each input bit
  logic [7:0] prev_reg;
  // Registers for edge detection flags
  logic [7:0] edge_flag;
  // Registers for delayed edge flags (output)
  logic [7:0] out_reg;

  // Edge detection and update previous state
  always @(posedge clk) begin
    // For each bit, compare current input with previous state
    edge_flag <= in ^ prev_reg;  // XOR gives 1 if different
    prev_reg <= in;
  end

  // Delay edge flags by one cycle
  always @(posedge clk) begin
    out_reg <= edge_flag;
  end

  // Output is the delayed edge flags
  assign anyedge = out_reg;

endmodule

