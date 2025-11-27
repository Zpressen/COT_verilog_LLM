
module TopModule
(
  input  logic clk,
  input  logic resetn,
  input  logic in,
  output logic out
);

  logic q0, q1, q2, q3;

  // Shift register with four D flip-flops
  always_ff @(posedge clk or negedge resetn) begin
    if (!resetn) begin
      q0 <= 0;
      q1 <= 0;
      q2 <= 0;
      q3 <= 0;
    end else begin
      q0 <= in;
      q1 <= q0;
      q2 <= q1;
      q3 <= q2;
    end
  end

  assign out = q3;

endmodule

