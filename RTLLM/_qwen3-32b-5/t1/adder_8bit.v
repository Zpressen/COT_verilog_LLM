module adder_8bit (
    input [7:0] a,
    input [7:0] b,
    input cin,
    output [7:0] sum,
    output cout
);

reg [7:0] sum;
reg [7:0] carry;

always @* begin
    carry[0] = (a[0] & b[0]) | ((a[0] ^ b[0]) & cin);
    sum[0] = a[0] ^ b[0] ^ cin;

    for (integer i = 1; i < 8; i = i + 1) begin
        carry[i] = (a[i] & b[i]) | ((a[i] ^ b[i]) & carry[i-1]);
        sum[i] = a[i] ^ b[i] ^ carry[i-1];
    end
end

assign cout = carry[7];

endmodule
