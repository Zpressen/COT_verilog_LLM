
module TopModule(
  input  clk,
  input  aresetn,
  input  x,
  output z
);

  // State definitions
  localparam S0 = 2'b00,
            S1 = 2'b01,
            S2 = 2'b10;

  // State register
  reg [1:0] state;

  // Output logic
  assign z = (state == S2);

  // FSM always block
  always @(posedge clk or negedge aresetn) begin
    if (!aresetn) begin
      state <= S0;
    end else begin
      case (state)
        S0: if (x) state <= S1;
        S1: if (!x) state <= S2;
        S2: if (x) state <= S0;
        default: state <= S0;
      endcase
    end
  end

endmodule

