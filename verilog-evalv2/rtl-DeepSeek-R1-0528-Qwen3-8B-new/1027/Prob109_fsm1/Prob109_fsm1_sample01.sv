
module TopModule(
  input clk,
  input areset,
  input in,
  output out
);

  // State encoding: 0 = A, 1 = B
  reg [1:0] state;

  // Asynchronous reset: reset to state B (1) if reset high
  always @(*) begin
    if (areset) begin
      state <= 2'b1;
    end else begin
      case (state)
        2'b00: // State A
          if (in == 1'b0) state <= 2'b01; // A --0--> B
          else state <= 2'b00; // A --1--> A
        2'b01: // State B
          if (in == 1'b0) state <= 2'b00; // B --0--> A
          else state <= 2'b01; // B --1--> B
      endcase
    end
  end

  // Moore machine: output is current state
  assign out = state;

endmodule

