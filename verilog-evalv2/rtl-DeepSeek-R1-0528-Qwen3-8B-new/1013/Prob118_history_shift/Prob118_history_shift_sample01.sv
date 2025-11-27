
module TopModule (
  input  clk,
  input  areset,
  input  predict_valid,
  input  predict_taken,
  input  train_mispredicted,
  input  train_taken,
  input  train_history,
  output predict_history
);

  // State tracking: 5-bit counter for history position (0-31)
  logic [4:0] counter;
  // 32-bit history register
  logic [31:0] history_reg;

  // Shift register logic: update on prediction or misprediction
  always @(posedge clk or posedge areset) begin
    if (areset) begin
      counter <= 5'b0;
      history_reg <= 32'b0;
    end else begin
      // Misprediction takes precedence over prediction
      if (train_mispredicted) begin
        // Load history before mispredicted branch + actual outcome
        history_reg <= {train_history, train_taken};
        counter <= 5'b0; // Reset counter to start fresh
      end else if (predict_valid) begin
        // Shift left and insert predicted branch direction
        history_reg <= {history_reg[30:0], predict_taken};
        counter <= counter + 1; // Increment counter for next position
      end
    end
  end

  // Output is the current history register value
  assign predict_history = history_reg;

endmodule

// VERILOG-EVAL: response did not use <CODE></CODE> correctly

