

module TopModule (
  input a,
  input b,
  input sel_b1,
  input sel_b2,
  output out_assign,
  output reg out_always
);

  // Combinational logic using assign
  assign out_assign = (sel_b1 & sel_b2) ? b : a;

  // Procedural logic using always block
  always @(a or b or sel_b1 or sel_b2) begin
    if (sel_b1 && sel_b2) begin
      out_always = b;
    end else begin
      out_always = a;
    end
  end

endmodule

