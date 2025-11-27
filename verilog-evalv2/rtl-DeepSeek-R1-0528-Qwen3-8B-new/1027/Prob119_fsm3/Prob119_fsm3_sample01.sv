
module TopModule(
  input  clk,
  input  areset,
  input  in,
  output out
);

  // State definitions
  localparam A = 2'b00,
            B = 2'b01,
            C = 2'b10,
            D = 2'b11;

  // State register
  reg [1:0] state;

  // Output logic
  assign out = (state == A) ? 0 :
               (state == B) ? 0 :
               (state == C) ? 0 :
               (state == D) ? 1;

  // State transition logic
  always @(posedge clk or posedge areset) begin
    if (areset) begin
      state <= A;
    end else begin
      case (state)
        A: if (in == 0) state <= A;
        A: if (in == 1) state <= B;
        B: if (in == 0) state <= C;
        B: if (in == 1) state <= B;
        C: if (in == 0) state <= A;
        C: if (in == 1) state <= D;
        D: if (in == 0) state <= C;
        D: if (in == 1) state <= B;
      endcase
    end
  end
endmodule

