module adder_pipe_64bit (
    input clk,
    input rst_n,
    input i_en,
    input [63:0] adda,
    input [63:0] addb,
    output reg [64:0] result,
    output reg o_en
);

// Stage 1 registers
reg [63:0] adda_s1;
reg [63:0] addb_s1;
reg en_s1;

// Stage 2 registers
reg [31:0] sum_low_s2;
reg carry_low_s2;
reg en_s2;

// Stage 3 registers
reg en_s3;

wire [31:0] sum_high_s3;
wire carry_high_s3;

// Combinational logic for lower addition
wire [31:0] sum_low_comb;
wire carry_low_comb;
assign {carry_low_comb, sum_low_comb} = adda_s1[31:0] + addb_s1[31:0] + 1'b0;

// Combinational logic for upper addition
assign {carry_high_s3, sum_high_s3} = adda_s1[63:32] + addb_s1[63:32] + carry_low_s2;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        adda_s1 <= 0;
        addb_s1 <= 0;
        en_s1 <= 0;
        sum_low_s2 <= 0;
        carry_low_s2 <= 0;
        en_s2 <= 0;
        en_s3 <= 0;
        result <= 0;
        o_en <= 0;
    end else begin
        // Stage 1: register inputs
        adda_s1 <= adda;
        addb_s1 <= addb;
        en_s1 <= i_en;

        // Stage 2: register lower addition results
        sum_low_s2 <= sum_low_comb;
        carry_low_s2 <= carry_low_comb;
        en_s2 <= en_s1;

        // Stage 3: register upper addition results and enable
        result <= {carry_high_s3, sum_high_s3, sum_low_s2};
        en_s3 <= en_s2;

        // Output enable is en_s3
        o_en <= en_s3;
    end
end

endmodule
