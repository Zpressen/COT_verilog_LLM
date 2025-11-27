
module TopModule
(
  input  logic clk,
  input  logic areset,
  input  logic x,
  output logic z
);

  // State definitions
  typedef enum logic [1:0] {
    state_A = 2'b00,
    state_B = 2'b01
  } state_t;

  // State register with one-hot encoding
  state_t state, next_state;

  // State transition logic
  always_ff @(posedge clk or posedge areset) begin
    if (areset) begin
      state <= state_A;
    end else begin
      state <= next_state;
    end
  end

  // Next state and output logic
  always_comb begin
    next_state = state_A;
    z = 1'b0;

    case (state)
      state_A: begin
        if (x == 1'b0) begin
          next_state = state_A;
          z = 1'b0;
        end else begin
          next_state = state_B;
          z = 1'b1;
        end
      end

      state_B: begin
        next_state = state_B;
        if (x == 1'b0) begin
          z = 1'b1;
        end else begin
          z = 1'b0;
        end
      end
    endcase
  end

endmodule

