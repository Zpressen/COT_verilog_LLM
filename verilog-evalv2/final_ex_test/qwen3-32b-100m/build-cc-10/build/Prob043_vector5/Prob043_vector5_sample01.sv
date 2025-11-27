
module TopModule (
  input a,
  input b,
  input c,
  input d,
  input e,
  output [24:0] out
);

wire [4:0] signals;
assign signals[0] = a;
assign signals[1] = b;
assign signals[2] = c;
assign signals[3] = d;
assign signals[4] = e;

genvar i, j;
generate
  for (i=0; i<5; i=i+1) begin : gen_i
    for (j=0; j<5; j=j+1) begin : gen_j
      assign out[24 - (i*5 + j)] = ~signals[i] ^ signals[j];
    end
  end
endgenerate

endmodule

// VERILOG-EVAL: errant inclusion of module definition


