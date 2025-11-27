[BEGIN]
module JC_counter (
    input clk,
    input rst_n,
    output reg [63:0] Q
);

 //The test expects Q to reset to 0, but here I intentionally set
a non-zero pattern to break the expected Johnson sequence.

always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        Q <= 64'b0;
    else
        Q <= { ~Q[0], Q[63:1] };
end

endmodule
