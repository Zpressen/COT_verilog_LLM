module synchronizer (
    clk_a,
    clk_b,
    arstn,
    brstn,
    data_in,
    data_en,
    dataout
);

input clk_a, clk_b;
input arstn, brstn;
input [3:0] data_in;
input data_en;
output [3:0] dataout;

reg [3:0] data_reg;
reg en_data_reg;
reg en_clap_one, en_clap_two;
reg [3:0] dataout;

always @(posedge clk_a or negedge arstn) begin
    if (!arstn) begin
        data_reg <= 4'b0;
        en_data_reg <= 1'b0;
    end else begin
        data_reg <= data_in;
        en_data_reg <= data_en;
    end
end

always @(posedge clk_b or negedge brstn) begin
    if (!brstn) begin
        en_clap_one <= 1'b0;
        en_clap_two <= 1'b0;
    end else begin
        en_clap_one <= en_data_reg;
        en_clap_two <= en_clap_one;
    end
end

always @(posedge clk_b or negedge brstn) begin
    if (!brstn) begin
        dataout <= 4'b0;
    end else if (en_clap_two) begin
        dataout <= data_reg;
    end
end

endmodule
