

module TopModule (
  input clk,
  input reset,
  input s,
  input w,
  output reg z
);

  parameter A = 2'b00, B1 = 2'b01, B2 = 2'b10, B3 = 2'b11;
  reg [1:0] state, next_state;
  reg [1:0] count;

  // Next state logic
  always @(*) begin
    case (state)
      A: next_state = (s) ? B1 : A;
      B1: next_state = B2;
      B2: next_state = B3;
      B3: next_state = B1;
      default: next_state = A;
    endcase
  end

  // State and count updates
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      state <= A;
      count <= 0;
      z <= 0;
    end else begin
      state <= next_state;
      if (next_state == B1) begin
        if (count == 2) z <= 1;
        else z <= 0;
        count <= 0;
      end else if (state == B1) begin
        if (w) count <= 1;
        else count <= 0;
        z <= 0;
      end else if (state == B2) begin
        if (w) count <= count + 1;
        z <= 0;
      end else if (state == B3) begin
        if (w) count <= count + 1;
        z <= 0;
      end
    end
  end

endmodule

