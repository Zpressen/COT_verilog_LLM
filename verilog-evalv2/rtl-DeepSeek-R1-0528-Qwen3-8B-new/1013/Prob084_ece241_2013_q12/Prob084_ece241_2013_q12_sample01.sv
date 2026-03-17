
module TopModule
(
  input  logic clk,
  input  logic enable,
  input  logic S,
  input  logic A,
  input  logic B,
  input  logic C,
  output logic Z
);

  // 8-bit shift register with MSB shifted in first
  logic [7:0] Q;

  // Shift register implementation
  generate
    for (genvar i = 0; i < 8; i++) begin
      Dff dff (
        .clk(clk),
        .enable(enable),
        .D((i == 0) ? S : Q[i-1]),
        .Q(Q[i])
      );
    end
  endgenerate

  // 3-to-8 decoder for address ABC
  logic [7:0] decoder_out;
  assign decoder_out = {A, B, C}; // ABC as 3-bit address

  // 8-to-1 multiplexer to select Q output based on ABC
  always_comb begin
    case (decoder_out)
      3'b000: Z = Q[0];
      3'b001: Z = Q[1];
      3'b010: Z = Q[2];
      3'b011: Z = Q[3];
      3'b100: Z = Q[4];
      3'b101: Z = Q[5];
      3'b110: Z = Q[6];
      3'b111: Z = Q[7];
      default: Z = 1'b0;
    endcase
  end

endmodule

