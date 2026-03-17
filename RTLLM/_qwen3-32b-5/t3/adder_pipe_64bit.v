module adder_pipe_64bit (
    input clk,
    input rst_n,
    input i_en,
    input [63:0] adda,
    input [63:0] addb,
    output reg [64:0] result,
    output reg o_en
);

// Pipeline registers
reg [63:0] pipe1_adda;
reg [63:0] pipe1_addb;
reg [31:0] pipe2_sum_lower;
reg pipe2_carry_lower;
reg [31:0] pipe3_sum_upper;
reg pipe3_carry_upper;
reg en_pipe1, en_pipe2;

// Lower addition
wire [31:0] adda_lower = pipe1_adda[31:0];
wire [31:0] addb_lower = pipe1_addb[31:0];
wire [32:0] temp_lower = {1'b0, adda_lower} + {1'b0, addb_lower};
wire [31:0] sum_lower = temp_lower[31:0];
wire carry_lower = temp_lower[32];

// Upper addition
wire [31:0] adda_upper = pipe1_adda[63:32];
wire [31:0] addb_upper = pipe1_addb[63:32];
wire [32:0] temp_upper = ({1'b0, adda_upper} + {1'b0, addb_upper}) + {1'b0, pipe2_carry_lower};
wire [31:0] sum_upper = temp_upper[31:0];
wire carry_upper = temp_upper[32];

// Input pipeline
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        pipe1_adda <= 64'b0;
        pipe1_addb <= 64'b0;
    end else if (i_en) begin
        pipe1_adda <= adda;
        pipe1_addb <= addb;
    end
end

// Lower sum pipeline
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        pipe2_sum_lower <= 32'b0;
        pipe2_carry_lower <= 1'b0;
    end else begin
        pipe2_sum_lower <= sum_lower;
        pipe2_carry_lower <= carry_lower;
    end
end

// Upper sum pipeline
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        pipe3_sum_upper <= 32'b0;
        pipe3_carry_upper <= 1'b0;
    end else begin
        pipe3_sum_upper <= sum_upper;
        pipe3_carry_upper <= carry_upper;
    end
end

// Enable pipeline
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        en_pipe1 <= 1'b0;
        en_pipe2 <= 1'b0;
    end else begin
        en_pipe1 <= i_en;
        en_pipe2 <= en_pipe1;
    end
end

// Output assignment
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        result <= 65'b0;
        o_en <= 1'b0;
    end else begin
        result <= {pipe3_carry_upper, pipe3_sum_upper, pipe2_sum_lower};
        o_en <= en_pipe2;
    end
end

endmodule
