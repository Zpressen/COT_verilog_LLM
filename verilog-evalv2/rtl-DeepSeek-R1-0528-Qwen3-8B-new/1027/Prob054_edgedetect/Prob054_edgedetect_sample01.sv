
module TopModule(
  input clk,
  input [7:0] in,
  output reg [7:0] pedge
);

  reg [7:0] prev_in; // Stores previous input value
  reg [7:0] edge_out; // Stores detected edges

  always @(posedge clk) begin
    // Store current input for next cycle
    prev_in <= in;
    
    // Detect edges: 0 to 1 transition
    edge_out <= edge_out | (in & ~prev_in);
    
    // Output edges one cycle after detection
    pedge <= edge_out;
  end
endmodule

