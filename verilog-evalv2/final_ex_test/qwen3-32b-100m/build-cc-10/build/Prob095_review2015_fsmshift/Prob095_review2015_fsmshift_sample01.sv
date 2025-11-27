
module TopModule (
  input clk,
  input reset,
  output shift_ena
);

  reg [2:0] counter;

  always @(posedge clk) begin
    if (reset) begin
      counter <= 0;
    end else begin
      if (counter < 4) begin
        counter <= counter + 1;
      end
    end
  end

  assign shift_ena = (counter < 4);

endmodule

// VERILOG-EVAL: errant inclusion of module definition


