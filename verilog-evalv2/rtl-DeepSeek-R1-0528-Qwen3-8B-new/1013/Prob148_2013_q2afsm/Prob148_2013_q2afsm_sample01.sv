
module TopModule (
  input  logic clk,
  input  logic resetn,
  input  logic [2:0] r,
  output logic [2:0] g
);

  // State encoding: 2 bits for 4 states
  typedef enum logic [1:0] {
    A = 2'b00,  // Idle state
    B = 2'b01,  // Grant device 0
    C = 2'b10,  // Grant device 1
    D = 2'b11   // Grant device 2
  } state_t;

  state_t current_state, next_state;

  // State transition logic (combinational)
  always_comb begin
    next_state = A;
    case (current_state)
      A: begin
        if (r[0]) next_state = B;
        else if (r[1]) next_state = C;
        else if (r[2]) next_state = D;
        else next_state = A;
      end
      B: begin
        if (r[0]) next_state = B;  // Keep granting device 0
        else next_state = A;
      end
      C: begin
        if (r[1]) next_state = C;  // Keep granting device 1
        else next_state = A;
      end
      D: begin
        if (r[2]) next_state = D;  // Keep granting device 2
        else next_state = A;
      end
    endcase
  end

  // State register (sequential)
  always_ff @(posedge clk or negedge resetn) begin
    if (!resetn) current_state <= A;
    else current_state <= next_state;
  end

  // Output logic (combinational)
  assign g[0] = (current_state == B);
  assign g[1] = (current_state == C);
  assign g[2] = (current_state == D);

endmodule

// VERILOG-EVAL: response did not use <CODE></CODE> correctly

