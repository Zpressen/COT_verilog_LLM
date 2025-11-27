
module TopModule (
  input  logic clock,
  input  logic a,
  output logic p,
  output logic q
);

  // D flip-flop for p: on rising edge, D_p = a; on falling edge, D_p = 0 if a==0 else ~q
  always @(posedge clock or negedge clock) begin
    if (clock == 1'b1) begin // rising edge
      p <= a;
    end else if (clock == 1'b0) begin // falling edge
      p <= (a == 0) ? 0 : ~q;
    end
  end

  // D flip-flop for q: on rising edge, D_q = p (previous value); on falling edge, D_q = 0 if a==0 else ~q
  always @(posedge clock or negedge clock) begin
    if (clock == 1'b1) begin // rising edge
      q <= p; // p is the previous value of p
    end else if (clock == 1'b0) begin // falling edge
      q <= (a == 0) ? 0 : ~q;
    end
  end

endmodule

