
module TopModule(
  input  clk,
  input  load,
  input  [255:0] data,
  output [255:0] q
);

  reg [255:0] state;

  always @(posedge clk) begin
    if (load) begin
      state <= data;
    end
  end

  // Toroidal neighbor counting and state update
  always @(*) begin
    for (int i = 0; i < 256; i++) begin
      int neighbors = 0;
      int row = i / 16;
      int col = i % 16;

      // Check all 8 neighbors with toroidal wrapping
      for (int dr = -1; dr <= 1; dr++) begin
        for (int dc = -1; dc <= 1; dc++) begin
          if (dr == 0 && dc == 0) continue;
          int n_row = (row + dr + 16) % 16;
          int n_col = (col + dc + 16) % 16;
          if (state[n_row * 16 + n_col]) neighbors++;
        end
      end

      // Apply Game of Life rules
      if (neighbors < 2) state[i] = 0;
      else if (neighbors == 2) state[i] = state[i];
      else if (neighbors == 3) state[i] = 1;
      else state[i] = 0;
    end
  end

  assign q = state;
endmodule

