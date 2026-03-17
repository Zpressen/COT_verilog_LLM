module adder_pipe_64bit (
    input clk,
    input rst_n,
    input i_en,
    input [63:0] adda,
    input [63:0] addb,
    output reg [64:0] result,
    output reg o_en
);

reg [63:0] stage1_adda;
reg [63:0] stage1_addb;
reg stage1_en;
reg stage1_en_prev;
reg [64:0] stage2_result;
reg stage2_en;

wire [64:0] add_result = stage1_adda + stage1_addb;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        stage1_adda <= 64'd0;
        stage1_addb <= 64'd0;
        stage1_en <= 1'b0;
        stage1_en_prev <= 1'b0;
        stage2_result <= 65'd0;
        stage2_en <= 1'b0;
        result <= 65'd0;
        o_en <= 1'b0;
    end else begin
        if (i_en) begin
            stage1_adda <= adda;
            stage1_addb <= addb;
            stage1_en <= 1'b1;
        end else begin
            stage1_en <= 1'b0;
        end
        stage1_en_prev <= stage1_en;
        if (stage1_en_prev) begin
            stage2_result <= add_result;
            stage2_en <= 1'b1;
        end else begin
            stage2_en <= 1'b0;
        end
        result <= stage2_result;
        o_en <= stage2_en;
    end
end

endmodule
