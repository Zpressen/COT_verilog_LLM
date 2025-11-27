[BEIGN]
module adder_8bit (
    input  [7:0] a,
    input  [7:0] b,
    input        cin,
    output [7:0] sum,
    output       cout
);

wire [8:0] carry;
assign carry[0] = cin;

genvar i;
generate
    for (i = 0; i < 8; i = i + 1) begin : gen_adder
        assign {
            carry[i+1],
            sum[i]
        } = a[i] + b[i] + carry[i];
    end
endgenerate

assign cout = carry[8];

endmodule

module adder_16bit (
    input  [15:0] a,
    input  [15:0] b,
    input         Cin,
    output [15:0] y,
    output        Co
);

wire carry_mid;

adder_8bit u_lower (
    .a(a[7:0]),
    .b(b[7:0]),
    .cin(Cin),
    .sum(y[7:0]),
    .cout(carry_mid)
);

adder_8bit u_upper (
    .a(a[15:8]),
    .b(b[15:8]),
    .cin(carry_mid),
    .sum(y[15:8]),
    .cout(Co)
);

endmodule
