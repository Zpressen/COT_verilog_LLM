
module TopModule (
  input a,
  input b,
  input c,
  input d,
  output q
);

  always @* begin
    case ({a,b,c,d})
      4'b0000: q = 0;
      4'b0001: q = 0;
      4'b1000: q = 0;
      4'b1001: q = 0;
      default: q = 1;
    endcase
  end
endmodule

