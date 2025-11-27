
module TopModule
(
  input  logic a,
  input  logic b,
  input  logic c,
  input  logic d,
  input  logic e,
  output logic [24:0] out
);

  wire [4:0] in_vec = {a, b, c, d, e};

  genvar i, j;

  generate
    for (i = 0; i < 5; i++) begin
      for (j = 0; j < 5; j++) begin
        assign out[24 - 5*i - j] = ~in_vec[i] ^ in_vec[j];
      end
    end
  endgenerate

endmodule

