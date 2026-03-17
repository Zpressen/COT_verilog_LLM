
module TopModule (
  input  logic clk,
  input  logic areset,
  
  input  logic predict_valid,
  input  logic [6:0] predict_pc,
  output logic predict_taken,
  output logic [6:0] predict_history,
  
  input  logic train_valid,
  input  logic train_taken,
  input  logic train_mispredicted,
  input  logic [6:0] train_history,
  input  logic [6:0] train_pc,
  input  logic [6:0] train_pc_old
);

  // Global history register (7 bits: 1=taken, 0=not taken)
  logic [6:0] global_history;
  
  // PHT: 128 entries, each 2-bit saturating counter
  typedef enum {NEUTRAL, STRONGLY_TAKEN, STRONGLY_NOT_TAKEN} pht_state_t;
  pht_state_t pht [0:127];
  
  // Branch history register (7 bits: 1=taken, 0=not taken)
  logic [6:0] branch_history;
  
  // PHT index calculation (gshare: XOR of PC and global history)
  logic [6:0] pht_index;
  assign pht_index = predict_pc ^ global_history;
  
  // PHT access and update logic
  always_ff @(posedge clk or posedge areset) begin
    if (areset) begin
      // Initialize PHT to neutral state
      for (int i = 0; i < 128; i++) begin
        pht[i] <= NEUTRAL;
      end
      // Initialize branch history to all not taken
      branch_history <= 7'b0;
      global_history <= 7'b0;
    end else begin
      // Handle training and prediction with priority
      if (train_valid) begin
        // Training takes precedence over prediction
        // Update PHT entry with actual outcome
        pht[pht_index] <= train_taken ? STRONGLY_TAKEN : STRONGLY_NOT_TAKEN;
        
        // If mispredicted, recover branch history
        if (train_mispredicted) begin
          // Reset branch history to state after mispredicting branch completes
          branch_history <= train_pc_old;
        end
      end else if (predict_valid) begin
        // Prediction: update PHT entry with predicted outcome
        pht[pht_index] <= predict_taken ? STRONGLY_TAKEN : STRONGLY_NOT_TAKEN;
        
        // Update global history register for predicted outcome
        global_history <= {global_history[5:0], predict_taken};
      end
    end
  end
  
  // Prediction interface logic
  always_comb begin
    if (predict_valid) begin
      // Determine prediction based on PHT entry
      case (pht[pht_index])
        NEUTRAL: predict_taken = 1'b0;
        STRONGLY_TAKEN: predict_taken = 1'b1;
        STRONGLY_NOT_TAKEN: predict_taken = 1'b0;
      endcase
      
      // Output current branch history for prediction
      predict_history = branch_history;
    end else begin
      // Default values when not predicting
      predict_taken = 1'b0;
      predict_history = 7'b0;
    end
  end

endmodule

