
module TopModule (
  input  logic clk,
  input  logic reset,
  input  logic [31:0] in,
  output logic [31:0] out
);

  // Previous input value
  logic [31:0] prev;
  
  // Falling edge detection for each bit
  logic [31:0] falling_edge;
  
  // Latched falling edge output
  logic [31:0] falling_edge_reg;

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      prev <= 0;
      falling_edge_reg <= 0;
    end else begin
      // Compute falling edge for each bit
      for (int i = 0; i < 32; i++) begin
        falling_edge[i] = (in[i] == 1) & (prev[i] == 0);
      end
      
      // Latch the falling edge into output register
      falling_edge_reg <= falling_edge_reg | falling_edge;
      
      // Update prev to current input
      prev <= in;
    end
  end

  assign out = falling_edge_reg;

endmodule

