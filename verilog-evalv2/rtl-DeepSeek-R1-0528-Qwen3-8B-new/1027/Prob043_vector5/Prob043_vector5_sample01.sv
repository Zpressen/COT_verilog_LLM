
module TopModule(
  input  logic a,
  input  logic b,
  input  logic c,
  input  logic d,
  input  logic e,
  output logic [24:0] out
);

  logic [4:0] inputs = {a, b, c, d, e};
  genvar i, j;
  generate
    for (i = 0; i < 5; i = i + 1) begin
      for (j = 0; j < 5; j = j + 1) begin
        assign out[24 - (i*5 + j)] = inputs[i] == inputs[j];
      end
    end
  endgenerate
endmodule

