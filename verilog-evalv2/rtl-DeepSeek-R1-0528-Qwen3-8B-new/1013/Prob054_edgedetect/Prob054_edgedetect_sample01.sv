
module TopModule (
  input  logic clk,
  input  logic [7:0] in,
  output logic [7:0] pedge
);

  // Using generate block for 8 bits
  genvar i;
  generate
    for (i = 0; i < 8; i++) begin : bit_detector
      logic prev_i;
      logic edge_i;
      logic detected_i;

      always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
          prev_i <= 0;
          detected_i <= 0;
        end else begin
          prev_i <= in[i];
          edge_i <= (prev_i == 0) && (in[i] == 1);
          detected_i <= edge_i;
        end
      end

      assign pedge[i] = detected_i;
    end
  endgenerate

endmodule

