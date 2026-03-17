
module TopModule (
  input  logic a,
  input  logic b,
  input  logic c,
  input  logic d,
  output logic out
);

  always @* begin
    case ({a,b})
      2'b00: out = ~(c & d);
      2'b01: out = ~d;
      2'b10: out = ~c;
      2'b11: out = c | d;
    endcase
  end

endmodule

