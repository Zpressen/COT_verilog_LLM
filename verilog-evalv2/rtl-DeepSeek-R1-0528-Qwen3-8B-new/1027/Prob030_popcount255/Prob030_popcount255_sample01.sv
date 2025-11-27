
module TopModule
(
  input  logic [254:0] in,
  output logic [7:0] out
);

  // Helper module to count ones in 8-bit vector
  module PopCount8 (
    input  logic [7:0] data,
    output logic [7:0] count
  );
    integer i;
    assign count = 8'b0;
    for (i = 0; i < 8; i = i + 1) begin
      count = count + data[i];
    end
  endmodule

  // Instantiate four 8-bit popcount modules for 64-bit chunks
  PopCount8 pc0 (.data(in[63:0]), .count(pc0_out));
  PopCount8 pc1 (.data(in[127:64]), .count(pc1_out));
  PopCount8 pc2 (.data(in[191:128]), .count(pc2_out));
  PopCount8 pc3 (.data(in[255:192]), .count(pc3_out));

  // Sum the four 8-bit counts
  assign out = pc0_out + pc1_out + pc2_out + pc3_out;

endmodule

