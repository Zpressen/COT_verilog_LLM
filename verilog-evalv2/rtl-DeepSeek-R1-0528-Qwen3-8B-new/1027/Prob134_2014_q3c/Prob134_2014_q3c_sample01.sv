
module TopModule(
  input clk,
  input x,
  input [2:0] y,
  output Y0,
  output z
);

  // State definitions
  localparam [2:0] S0 = 3'b000;
  localparam [2:0] S1 = 3'b001;
  localparam [2:0] S2 = 3'b010;
  localparam [2:0] S3 = 3'b011;
  localparam [2:0] S4 = 3'b100;

  // State register
  reg [2:0] current_state;
  reg [2:0] next_state;

  // Output logic
  assign Y0 = current_state[0];
  assign z = (current_state == 3'b011 && y == 3'b001) ? 1'b1 : 1'b0;

  // Next state logic
  always @(*) begin
    case (current_state)
      S0: next_state = (x == 1'b0) ? S0 : S1;
      S1: next_state = (x == 1'b0) ? S1 : S4;
      S2: next_state = (x == 1'b0) ? S2 : S1;
      S3: next_state = (x == 1'b0) ? S1 : S2;
      S4: next_state = (x == 1'b0) ? S3 : S4;
      default: next_state = S0;
    endcase
  end

  // State transition
  always @(posedge clk) begin
    current_state <= next_state;
  end
endmodule

// VERILOG-EVAL: response did not use <CODE></CODE> correctly

