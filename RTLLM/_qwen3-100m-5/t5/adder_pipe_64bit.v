module adder_pipe_64bit (
    input clk,
    input rst_n,
    input i_en,
    input [63:0] adda,
    input [63:0] addb,
    output reg [64:0] result,
    output reg o_en
);

reg [63:0] reg_adda_0;
reg [63:0] reg_addb_0;
reg reg_i_en_0;

reg [31:0] reg_sum_low;
reg reg_carry_low;
reg reg_i_en_1;

reg [31:0] reg_sum_high;
reg reg_carry_high;
reg reg_i_en_2;

wire [31:0] adda_low = reg_adda_0[31:0];
wire [31:0] addb_low = reg_addb_0[31:0];
wire [32:0] temp_sum_low = {1'b0, adda_low} + {1'b0, addb_low};
wire carry_low = temp_sum_low[32];
wire [31:0] sum_low = temp_sum_low[31:0];

wire [31:0] adda_high = reg_adda_0[63:32];
wire [31:0] addb_high = reg_addb_0[63:32];
wire [32:0] temp_sum_high = {1'b0, adda_high} + {1'b0, addb_high} + {1'b0, reg_carry_low};
wire carry_high = temp_sum_high[32];
wire [31:0] sum_high = temp_sum_high[31:0];

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        reg_adda_0 <= 64'b0;
        reg_addb_0 <= 64'b0;
        reg_i_en_0 <= 1'b0;
        reg_sum_low <= 32'b0;
        reg_carry_low <= 1'b0;
        reg_i_en_1 <= 1'b0;
        reg_sum_high <= 32'b0;
        reg_carry_high <= 1'b0;
        reg_i_en_2 <= 1'b0;
    end else begin
        if (i_en) begin
            reg_adda_0 <= adda;
            reg_addb_0 <= addb;
            reg_i_en_0 <= i_en;
        end
        reg_sum_low <= sum_low;
        reg_carry_low <= carry_low;
        reg_i_en_1 <= reg_i_en_0;
        reg_sum_high <= sum_high;
        reg_carry_high <= carry_high;
        reg_i_en_2 <= reg_i_en_1;
    end
end

assign result = {reg_carry_high, reg_sum_high, reg_sum_low};
assign o_en = reg_i_en_2;

endmodule
