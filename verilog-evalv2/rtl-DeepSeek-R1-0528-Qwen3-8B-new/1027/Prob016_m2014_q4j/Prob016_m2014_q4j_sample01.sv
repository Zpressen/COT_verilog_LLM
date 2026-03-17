
module TopModule(
  input  logic [3:0] x,
  input  logic [3:0] y,
  output logic [4:0] sum
);

  // Full adder for each bit position
  genvar i;
  generate
    for (i = 0; i < 4; i = i + 1) begin
      FullAdder fa_inst(
        .a(x[i]),
        .b(y[i]),
        .cin(i == 0 ? 1'b0 : sum[i]),
        .sum(sum[i]),
        .cout(sum[i+1])
      );
    end
  endgenerate
endmodule

// FullAdder module definition (assumed to be defined elsewhere)
module FullAdder(
  input  logic a,
  input  logic b,
  input  logic cin,
  output logic sum,
  output logic cout
);
  assign {cout, sum} = a + b + cin;
endmodule

