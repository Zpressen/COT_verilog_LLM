
module TopModule
(
  input  logic clk,
  input  logic reset,
  input  logic w,
  output logic z
);

  // State encoding: A=000, B=001, C=010, D=011, E=100, F=101
  typedef enum logic [2:0] {
    A = 3'b000,
    B = 3'b001,
    C = 3'b010,
    D = 3'b011,
    E = 3'b100,
    F = 3'b101
  } state_t;

  state_t current_state, next_state;

  // State transition logic
  always_comb begin
    next_state = A; // default state
    case (current_state)
      A: if (w) next_state = A; else next_state = B;
      B: if (w) next_state = D; else next_state = C;
      C: if (w) next_state = D; else next_state = E;
      D: if (w) next_state = A; else next_state = F;
      E: if (w) next_state = D; else next_state = E;
      F: if (w) next_state = C; else next_state = D;
    endcase
  end

  // State register
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      current_state <= A;
    end else begin
      current_state <= next_state;
    end
  end

  // Output logic
  assign z = (current_state == E) || (current_state == F);

endmodule

