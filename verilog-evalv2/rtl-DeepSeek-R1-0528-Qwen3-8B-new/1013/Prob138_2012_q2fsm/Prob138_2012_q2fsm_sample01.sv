
module TopModule
(
  input  logic clk,
  input  logic reset,
  input  logic w,
  output logic z
);

  // State encoding: 3 bits for 6 states
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
    case (current_state)
      A: begin
        if (w) next_state = B;
        else next_state = A;
      end
      B: begin
        if (w) next_state = C;
        else next_state = D;
      end
      C: begin
        if (w) next_state = E;
        else next_state = D;
      end
      D: begin
        if (w) next_state = F;
        else next_state = A;
      end
      E: begin
        if (w) next_state = E;
        else next_state = D;
      end
      F: begin
        if (w) next_state = C;
        else next_state = D;
      end
      default: next_state = A;
    endcase
  end

  // State flip-flops
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      current_state <= A;
      z <= 0;
    end else begin
      current_state <= next_state;
      // Output logic
      case (current_state)
        E: z <= w;
        F: z <= w;
        default: z <= 0;
      endcase
    end
  end

endmodule

