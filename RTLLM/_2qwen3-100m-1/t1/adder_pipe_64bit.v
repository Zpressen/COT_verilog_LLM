module adder_pipe_64bit (
    input clk,
    input rst_n,
    input i_en,
    input [63:0] adda,
    input [63:0] addb,
    output reg [64:0] result,
    output reg o_en
);

reg [31:0] adda1, addb1;
reg [31:0] adda2, addb2;
reg en1, en2;

wire [31:0] sum_lower;
wire carry_out1;
wire [31:0] sum_upper;
wire carry_out2;

assign {carry_out1, sum_lower} = adda1 + addb1;
assign {carry_out2, sum_upper} = adda2 + addb2 + carry_out1;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        adda1 <= 32'd0;
        addb1 <= 32'd0;
        en1 <= 1'b0;
        adda2 <= 32'd0;
        addb2 <= 32'd0;
        en2 <= 1'b0;
        result <= 65'd0;
        o_en <= 1'b0;
    end else begin
        adda1 <= adda[31:0];
        addb1 <= addb[31:0];
        en1 <= i_en;
        adda2 <= adda[63:32];
        addb2 <= addb[63:32];
        en2 <= en1;
        if (en2) begin
            result <= {carry_out2, sum_upper, sum_lower};
            o_en <= 1'b1;
        end else begin
            o_en <= 1'b0;
        end
    end
end

endmodule
