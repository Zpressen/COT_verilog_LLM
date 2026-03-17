
module TopModule (
  input clk,
  input reset,
  input pattern_detected,
  output shift_ena
);

  logic [1:0] counter;

  always_ff @(posedge clk) begin
    if (reset || pattern_detected) begin
      counter <= 0;
    end else if (counter < 3) begin
      counter <= counter + 1;
    end else begin
      counter <= 3; // stay at 3
    end
  end

  assign shift_ena = (counter < 4) ? 1'b1 : 1'b0;

endmodule

// VERILOG-EVAL: response did not use <CODE></CODE> correctly

