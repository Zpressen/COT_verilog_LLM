

module TopModule (
  input clk,
  input in,
  input reset,
  output out
);

  localparam [1:0] A = 2'b00, B = 2'b01, C = 2'b10, D = 2'b11;
  reg [1:0] state_reg, state_next;

  // Synchronous reset
  always @(posedge clk) begin
    if (reset)
      state_reg <= A;
    else
      state_reg <= state_next;
  end

  // Next state logic
  always @(*) begin
    case (state_reg)
      A: state_next = (in) ? B : A;
      B: state_next = (in) ? B : C;
      C: state_next = (in) ? D : A;
      D: state_next = (in) ? B : C;
      default: state_next = A;
    endcase
  end

  // Output logic
  assign out = (state_reg == D) ? 1'b1 : 1'b0;

endmodule

