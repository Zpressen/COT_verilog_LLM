
module TopModule (
  input  clk,
  input  areset,
  input  predict_valid,
  input  predict_pc,
  output predict_taken,
  output predict_history,
  input  train_valid,
  input  train_taken,
  input  train_mispredicted,
  input  train_history,
  input  train_pc
);

  // Global branch history register
  reg [6:0] global_history;
  reg [6:0] next_global_history;

  // PHT table: 128 entries, each 2-bit saturating counter
  reg [1:0] pht_table [127:0];

  // PHT index computation
  function [6:0] gshare_index;
    input [6:0] pc, history;
    begin
      gshare_index = pc ^ history;
    end
  endfunction

  // PHT entry update
  always @(posedge clk or posedge areset) begin
    if (areset) begin
      // Initialize PHT entries to 0
      for (int i = 0; i < 128; i++) begin
        pht_table[i] <= 2'b00;
      end
      global_history <= 7'b0;
    end else begin
      if (train_valid) begin
        // Training operation
        if (train_mispredicted) begin
          // Recover branch history register
          next_global_history <= global_history;
        end
        // Update PHT entry
        pht_table[gshare_index(train_pc, global_history)] <= pht_table[gshare_index(train_pc, global_history)] + 1;
      end else begin
        // Prediction operation
        // Output predicted direction and history
        predict_taken <= (pht_table[gshare_index(predict_pc, global_history)] == 2'b11);
        predict_history <= global_history;
      end
    end
  end

endmodule

