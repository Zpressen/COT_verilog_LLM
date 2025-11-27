
module TopModule (
  input  logic clk,
  input  logic load,
  input  logic [511:0] data,
  output logic [511:0] q
);

  // Current state register array
  logic [511:0] current_state;

  // Combinational logic for next state computation
  always_comb begin
    for (int i = 0; i < 512; i++) begin
      // Boundary conditions: left and right neighbors are zero for out-of-bound cells
      logic left_neighbor, right_neighbor;
      if (i == 0) left_neighbor = 1'b0;
      else left_neighbor = current_state[i-1];
      
      if (i == 511) right_neighbor = 1'b0;
      else right_neighbor = current_state[i+1];
      
      // Rule 90: next state = XOR of left and right neighbors
      logic next_state;
      if (load) begin
        next_state = data[i]; // Load input overrides automaton logic
      end else begin
        next_state = left_neighbor ^ right_neighbor;
      end
      
      // Assign next state for this cell
      current_state[i] = next_state;
    end
  end

  // Sequential update on clock edge
  always @(posedge clk) begin
    q <= current_state;
  end

endmodule

// VERILOG-EVAL: response did not use <CODE></CODE> correctly

