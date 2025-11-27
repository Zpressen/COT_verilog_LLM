
module TopModule (
  input  logic clk,
  input  logic load,
  input  logic [511:0] data,
  output logic [511:0] q
);

  logic [511:0] next_state;

  // Generate block to compute next_state for each cell
  generate
    for (genvar i = 0; i < 512; i++) begin
      // Define left and right neighbors with boundaries
      logic left, right;
      if (i == 0) begin
        left = 0;
      end else begin
        left = q[i-1];
      end
      if (i == 511) begin
        right = 0;
      end else begin
        right = q[i+1];
      end

      // Compute next state for cell i
      assign next_state[i] = (left == 1 && q[i] == 1 && right == 1) ? 0 : 
                            (left == 0 && q[i] == 0 && right == 0) ? 0 : 1;
    end
  endgenerate

  // Register file for q
  always_ff @(posedge clk) begin
    if (load) begin
      q <= data;
    end else begin
      q <= next_state;
    end
  end

endmodule

