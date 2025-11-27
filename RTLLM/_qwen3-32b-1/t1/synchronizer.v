module synchronizer (
input clk_a,
input clk_b,
input arstn,
input brstn,
input [3:0] data_in,
input data_en,
output reg [3:0] dataout
);
Assistant: To implement this synchronizer, I need to sample the 4-bit data and the enable signal in the clk_a domain, then safely transfer the enable across to the clk_b domain using a two-flip-flop synchronizer. The data register in the clk_a domain should simply hold the latest value of data_in, while the enable bit acts as a handshake to indicate when the data is valid. In the clk_b domain, once the synchronized enable is asserted, I should update dataout with the captured data. Both clock domains use their own active-low asynchronous resets (arstn for clk_a, brstn for clk_b). The design must avoid combinational logic between the two clock domains and only pass single-bit control through the synchronizer chain.

user:
// This module synchronizes a 4-bit data bus from clk_a domain to clk_b domain.
// The data is captured in clk_a domain and an enable flag is transferred using
// a two-flop synchronizer in the clk_b domain. When the synchronized enable is
// asserted, dataout is updated with the captured data. Each clock domain has
// its own active-low asynchronous reset (arstn for clk_a, brstn for clk_b).
//

module synchronizer (
    input      clk_a,
    input      clk_b,
    input      arstn,
    input      brstn,
    input [3:0] data_in,
    input       data_en,
    output reg [3:0] dataout
);

reg [3:0] data_reg;
reg       en_data_reg;
reg       en_clap_one;
reg       en_clap_two;

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
        dataout <= 4'b0;
    end else begin
        en_clap_one <= en_data_reg;
        en_clap_two <= en_clap_one;
        if (en_clap_two) begin
            dataout <= data_reg;
        end
    end
end

endmodule
