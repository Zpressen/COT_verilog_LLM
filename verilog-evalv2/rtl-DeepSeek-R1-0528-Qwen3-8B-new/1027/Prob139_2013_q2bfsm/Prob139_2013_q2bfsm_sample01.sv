
module TopModule(
  input clk,
  input resetn,
  input x,
  input y,
  output f,
  output g
);

  // Internal signals
  reg f;
  reg g;
  reg [1:0] x_seq; // Tracks last two x values for sequence detection
  reg y_timeout;   // Tracks y monitoring timeout

  // Reset pulse generation
  always @(posedge clk or negedge resetn) begin
    if (!resetn) begin
      f <= 1'b1;
      // Reset internal states
      x_seq <= 2'b00;
      y_timeout <= 1'b0;
    end else begin
      f <= 1'b0;
      // Reset pulse logic
      if (!resetn) begin
        f <= 1'b1;
      end
      // x sequence tracking
      x_seq <= {x_seq[0], x};
      // y monitoring
      if (x_seq == 2'b101) begin
        y_timeout <= 1'b1;
      end else if (y_timeout) begin
        if (y) begin
          y_timeout <= 1'b0;
        end
      end
    end
  end

  // Output assignments
  assign f = f;
  assign g = y_timeout ? 1'b1 : 1'b0;

endmodule

