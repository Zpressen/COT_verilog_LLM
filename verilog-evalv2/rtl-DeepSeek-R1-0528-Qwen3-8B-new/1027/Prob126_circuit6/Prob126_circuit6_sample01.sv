
module TopModule(
  input  logic [2:0] a,
  output logic [15:0] q
);

  always @* begin
    case (a)
      3'b000: q = 16'h07E0; // 1232
      3'b001: q = 16'hAE00; // 43520
      3'b010: q = 16'h042C; // 10692
      3'b011: q = 16'h05D2; // 14822
      3'b100: q = 16'h0100; // 4160
      3'b101: q = 16'h069E; // 16574
      3'b110: q = 16'hC526; // 32550
      3'b111: q = 16'h1F19; // 7935
      default: q = 16'h0000;
    endcase
  end
endmodule

