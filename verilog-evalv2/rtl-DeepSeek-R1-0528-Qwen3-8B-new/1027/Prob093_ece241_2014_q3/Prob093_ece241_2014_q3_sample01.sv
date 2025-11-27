
module mux2to1(input a, b, sel, output y);
  assign y = (sel ? b : a);
endmodule

module TopModule(input c, d, output [3:0] mux_in);
  wire temp1, temp2;
  mux2to1 mux1 (.a(c), .b(1'b0), .sel(d), .y(temp1));
  mux2to1 mux2 (.a(c), .b(c), .sel(1'b0), .y(temp2));
  assign mux_in[0] = temp1;
  assign mux_in[1] = temp1;
  assign mux_in[2] = temp2;
  assign mux_in[3] = temp2;
endmodule

