module adder_8bit(
    input  [7:0] a,
    input  [7:0] b,
    input        Cin,
    output [7:0] y,
    output       Co
);
    wire [8:0] sum = a + b + Cin;
    assign y = sum[7:0];
    assign Co = sum[8];
endmodule

module adder_16bit(
    input  [15:0] a,
    input  [15:0] b,
    input          Cin,
    output [15:0]  y,
    output         Co
);
    wire             co_lower;
    wire [7:0]       lower_y;
    wire [7:0]       upper_y;

    adder_8bit u_lower (
        .a(a[7:0]),
        .b(b[7:0]),
        .Cin(Cin),
        .y(lower_y),
        .Co(co_lower)
    );

    adder_8bit u_upper (
        .a(a[15:8]),
        .b(b[15:8]),
        .Cin(co_lower),
        .y(upper_y),
        .Co(Co)
    );

    assign y[7:0]  = lower_y;
    assign y[15:8] = upper_y;
endmodule
