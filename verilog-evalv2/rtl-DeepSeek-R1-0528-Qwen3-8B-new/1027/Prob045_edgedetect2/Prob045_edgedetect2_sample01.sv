
module TopModule(
  input clk,
  input [7:0] in,
  output reg [7:0] anyedge
);

  reg [7:0] prev_in; // Stores previous input state for edge detection

  always @(posedge clk) begin
    // Store current input as previous for next cycle
    prev_in <= in;
    
    // Detect edges and set output
    anyedge <= (in ^ prev_in); // XOR detects any transition
  end

endmodule

// VERILOG-EVAL: response did not use <CODE></CODE> correctly

