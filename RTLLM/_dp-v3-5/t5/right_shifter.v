module right_shifter (
    input clk,
    input d,
    output [7:0] q
);

    reg [7:0] q_reg;
    initial q_reg = 8'b0;

    always @(posedge clk) begin
        q_reg <= {d, q_reg[7:1]};
    end

    assign q = q_reg;

endmodule
