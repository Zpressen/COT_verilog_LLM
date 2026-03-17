
module TopModule
(
  input  logic clk,
  input  logic reset,
  input  logic s,
  input  logic w,
  output logic z
);

  // State definitions
  typedef enum logic [1:0] {
    A,  // Initial state, waiting for s=1
    B,  // Monitoring w for three cycles
    C   // Output pulse generation
  } state_t;

  // State register
  state_t current_state, next_state;

  // Counter for w=1s in state B
  logic [1:0] w_count;

  // FSM logic
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      current_state <= A;
      w_count <= 0;
    end else begin
      current_state <= next_state;
      if (current_state == B) begin
        w_count <= w_count + 1;
      end
    end
  end

  // Next state logic
  always_comb begin
    next_state = current_state;
    z = 0;

    case (current_state)
      A: begin
        if (s) begin
          next_state = B;
        end
      end

      B: begin
        if (w_count == 2) begin
          next_state = C;
        end
      end

      C: begin
        z = 1;
        next_state = B;
      end
    endcase
  end

endmodule

