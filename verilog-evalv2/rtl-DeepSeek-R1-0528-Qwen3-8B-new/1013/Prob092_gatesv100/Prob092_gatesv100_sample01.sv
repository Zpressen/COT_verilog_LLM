
module TopModule (
  input  logic [99:0] in,
  output logic [99:0] out_both,
  output logic [99:0] out_any,
  output logic [99:0] out_different
);

  // out_both: 1 if both current bit and left neighbor are 1, 0 otherwise (with out_both[99] = 0)
  generate
    genvar i;
    for (i = 0; i < 100; i++) begin : gen_out_both
      if (i < 99) begin
        out_both[i] = in[i] & in[i+1];
      end else begin
        out_both[i] = 1'b0;
      end
    end
  endgenerate

  // out_any: 1 if either current bit or right neighbor is 1, 0 otherwise (with out_any[0] = 0)
  generate
    genvar j;
    for (j = 0; j < 100; j++) begin : gen_out_any
      if (j == 0) begin
        out_any[j] = 1'b0;
      end else begin
        out_any[j] = in[j] | in[j-1];
      end
    end
  endgenerate

  // out_different: 1 if current bit differs from left neighbor, 0 otherwise (with wrapping)
  generate
    genvar k;
    for (k = 0; k < 100; k++) begin : gen_out_diff
      integer left_index;
      if (k == 0) begin
        left_index = 99;
      end else begin
        left_index = k-1;
      end
      out_different[k] = (in[k] != in[left_index]);
    end
  endgenerate

endmodule

