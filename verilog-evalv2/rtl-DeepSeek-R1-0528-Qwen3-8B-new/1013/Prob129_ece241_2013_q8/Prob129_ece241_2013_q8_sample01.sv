
module TopModule (
  input  logic clk,
  input  logic aresetn,
  input  logic x,
  output logic z
);

  // State encoding: 2 bits for 3 states (00, 01, 10) with one unused state (11)
  typedef enum logic [1:0] {
    S0 = 2'b00,  // Reset/start state
    S1 = 2'b01,  // Detected '1'
    S2 = 2'b10,  // Detected '0' after '1'
    S3 = 2'b11   // Unused state (safety)
  } state_t;

  state_t current_state, next_state;

  // Combinational logic for next state and output
  always_comb begin
    next_state = current_state;
    z = 1'b0;

    case (current_state)
      S0: begin
        if (x) next_state = S1;
        else  next_state = S0;
      end
      S1: begin
        if (x) next_state = S1;  // Stay in S1 for overlapping sequences
        else  next_state = S2;
      end
      S2: begin
        if (x) begin
          next_state = S3;
          z = 1'b1;  // Output on transition to S3
        end
        else  next_state = S2;
      end
      S3: begin
        if (x) next_state = S1;
        else  next_state = S2;
      end
    endcase
  end

  // Sequential logic with negative edge asynchronous reset
  always @(posedge clk and !aresetn) begin
    current_state <= next_state;
  end

endmodule

// VERILOG-EVAL: response did not use <CODE></CODE> correctly

