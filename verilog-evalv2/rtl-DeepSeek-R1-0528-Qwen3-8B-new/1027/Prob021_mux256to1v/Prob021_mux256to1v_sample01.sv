
module TopModule(
  input  logic [1023:0] in,
  input  logic [7:0]    sel,
  output logic [3:0]   out
);

  always @(*) begin
    case (sel)
      8'h0: out = in[3:0];
      8'h1: out = in[7:4];
      8'h2: out = in[11:8];
      8'h3: out = in[15:12];
      8'h4: out = in[19:16];
      8'h5: out = in[23:20];
      8'h6: out = in[27:24];
      8'h7: out = in[31:28];
      8'h8: out = in[35:32];
      8'h9: out = in[39:36];
      8'hA: out = in[43:40];
      8'hB: out = in[47:44];
      8'hC: out = in[51:48];
      8'hD: out = in[55:52];
      8'hE: out = in[59:56];
      8'hF: out = in[63:60];
      default: out = 4'b0;
    endcase
  end
endmodule

