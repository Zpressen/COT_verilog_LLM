
module TopModule
(
  input  logic clk,
  input  logic load,
  input  logic [255:0] data,
  output logic [255:0] q
);

  // Internal signals
  logic [255:0] next_q;

  // Combinational logic for next state calculation
  always_comb begin
    next_q = '0;
    for (int i = 0; i < 256; i++) begin
      // Calculate row and column indices
      int row = i / 16;
      int col = i % 16;

      // Count live neighbors (toroidal grid)
      int live_neighbors = 0;
      for (int dr = -1; dr <= 1; dr++) begin
        for (int dc = -1; dc <= 1; dc++) begin
          if (dr == 0 && dc == 0) continue; // Skip self

          // Calculate neighbor coordinates with toroidal wrapping
          int n_row = (row + dr) % 16;
          int n_col = (col + dc) % 16;
          int n_index = n_row * 16 + n_col;

          // Count live neighbor
          if (q[n_index]) live_neighbors++;
        end
      end

      // Apply Game of Life rules
      if (live_neighbors == 2 && q[i]) next_q[i] = 1;
      else if (live_neighbors == 3) next_q[i] = 1;
      else next_q[i] = 0;
    end
  end

  // Sequential logic for state update
  always_ff @(posedge clk) begin
    if (load) begin
      q <= data; // Load initial state
    end else begin
      q <= next_q; // Update state
    end
  end

endmodule

