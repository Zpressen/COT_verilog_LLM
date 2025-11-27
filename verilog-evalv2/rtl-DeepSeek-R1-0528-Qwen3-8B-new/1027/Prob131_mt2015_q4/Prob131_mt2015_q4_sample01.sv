
module A(input x, y, output z);
  assign z = x & ~y;
endmodule

module B(input x, y, output z);
  assign z = ~x & y;
endmodule

module TopModule(input x, y, output z);
  wire a1, a2, b1, b2;
  A a1(x, y, a1);
  A a2(x, y, a2);
  B b1(x, y, b1);
  B b2(x, y, b2);
  wire or_out = a1 | b1;
  wire and_out = a2 & b2;
  assign z = or_out ^ and_out;
endmodule

