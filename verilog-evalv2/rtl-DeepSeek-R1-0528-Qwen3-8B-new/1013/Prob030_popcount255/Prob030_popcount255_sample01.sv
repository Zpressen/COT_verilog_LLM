
module TopModule
(
  input  logic [254:0] in,
  output logic [7:0] out
);

  // Break input into 31 groups of 8 bits and one 7-bit remainder
  logic [3:0] cnt8 [0:30];  // 31 counters for 8-bit groups
  logic [2:0] cnt7;          // Counter for 7-bit remainder

  // 8-bit group counters (each counts 0-8)
  for (genvar i = 0; i < 31; i++) begin
    assign cnt8[i] = $countones(in[8*i +: 8]);
  end

  // 7-bit remainder counter
  assign cnt7 = $countones(in[248:255]);

  // Tree of 4-bit adders to sum counts
  logic [7:0] sum [0:7];
  assign sum[0] = cnt8[0] + cnt8[1];
  assign sum[1] = cnt8[2] + cnt8[3];
  assign sum[2] = cnt8[4] + cnt8[5];
  assign sum[3] = cnt8[6] + cnt8[7];
  assign sum[4] = cnt8[8] + cnt8[9];
  assign sum[5] = cnt8[10] + cnt8[11];
  assign sum[6] = cnt8[12] + cnt8[13];
  assign sum[7] = cnt8[14] + cnt8[15];

  assign sum[8] = sum[0] + sum[1];
  assign sum[9] = sum[2] + sum[3];
  assign sum[10] = sum[4] + sum[5];
  assign sum[11] = sum[6] + sum[7];

  assign sum[12] = sum[8] + sum[9];
  assign sum[13] = sum[10] + sum[11];

  assign sum[14] = sum[12] + sum[13];

  // Final sum includes the 7-bit remainder
  assign out = sum[14] + cnt7;

endmodule

