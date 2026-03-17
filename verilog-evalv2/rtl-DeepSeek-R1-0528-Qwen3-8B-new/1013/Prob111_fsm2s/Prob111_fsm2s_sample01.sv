
module TopModule(
  input  logic clk,
  input  logic reset,
  input  logic j,
  input  logic k,
  output logic out
);

  // State definitions
  parameter OFF = 2'b00,
            ON  = 2'b01;

  // State register
  reg [1:0] current_state, next_state;

  // State transition logic
  always_comb begin
    case (current_state)
      OFF: begin
        if (j) next_state = ON;
        else next_state = OFF;
      end
      ON: begin
        if (k) next_state = OFF;
        else next_state = ON;
      end
      default: next_state = OFF; // Prevent unknown states
    endcase
  end

  // Synchronous state update with reset
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      current_state <= OFF;
    end else begin
      current_state <= next_state;
    end
  end

  // Moore output: 0 for OFF, 1 for ON
  assign out = current_state[1];

endmodule

// VERILOG-EVAL: response did not use <CODE></CODE> correctly

