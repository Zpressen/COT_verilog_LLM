
module TopModule
(
  input  logic clk,
  input  logic reset,
  input  logic x,
  output logic z
);

  // State encoding: 000, 001, 010, 011, 100
  typedef enum logic [2:0] {
    S0 = 3'b000,
    S1 = 3'b001,
    S2 = 3'b010,
    S3 = 3'b011,
    S4 = 3'b100
  } state_t;

  state_t current_state, next_state;

  // Synchronous reset
  always_ff @(posedge clk) begin
    if (reset) begin
      current_state <= S0;
    end else begin
      current_state <= next_state;
    end
  end

  // Next state and output logic
  always_comb begin
    next_state = current_state;
    z = 0;
    case (current_state)
      S0: begin
        if (x == 0) next_state = S0;
        else next_state = S1;
        z = 0;
      end
      S1: begin
        if (x == 0) next_state = S1;
        else next_state = S4;
        z = 0;
      end
      S2: begin
        if (x == 0) next_state = S2;
        else next_state = S1;
        z = 0;
      end
      S3: begin
        if (x == 0) next_state = S1;
        else next_state = S2;
        z = 1;
      end
      S4: begin
        if (x == 0) next_state = S3;
        else next_state = S4;
        z = 1;
      end
    endcase
  end

endmodule

