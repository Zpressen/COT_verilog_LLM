module adder_pipe_64bit (
    input clk,
    input rst_n,
    input i_en,
    input [63:0] adda,
    input [63:0] addb,
    output reg [64:0] result,
    output reg o_en
);

    // Pipeline stage 1 (bits 0-15)
    reg [15:0] adda_stage1;
    reg [15:0] addb_stage1;
    reg carry_stage1;
    reg en_stage1;
    wire [15:0] sum_stage1;
    wire carry_stage1_out;

    // Pipeline stage 2 (bits 16-31)
    reg [15:0] adda_stage2;
    reg [15:0] addb_stage2;
    reg carry_stage2;
    reg en_stage2;
    wire [15:0] sum_stage2;
    wire carry_stage2_out;

    // Pipeline stage 3 (bits 32-47)
    reg [15:0] adda_stage3;
    reg [15:0] addb_stage3;
    reg carry_stage3;
    reg en_stage3;
    wire [15:0] sum_stage3;
    wire carry_stage3_out;

    // Pipeline stage 4 (bits 48-63)
    reg [15:0] adda_stage4;
    reg [15:0] addb_stage4;
    reg carry_stage4;
    reg en_stage4;
    wire [15:0] sum_stage4;
    wire carry_stage4_out;

    // Pipeline enable signals
    reg en_stage5;
    reg en_stage6;

    // Stage 1 adder (bits 0-15)
    assign {carry_stage1_out, sum_stage1} = adda_stage1 + addb_stage1 + carry_stage1;

    // Stage 2 adder (bits 16-31)
    assign {carry_stage2_out, sum_stage2} = adda_stage2 + addb_stage2 + carry_stage2;

    // Stage 3 adder (bits 32-47)
    assign {carry_stage3_out, sum_stage3} = adda_stage3 + addb_stage3 + carry_stage3;

    // Stage 4 adder (bits 48-63)
    assign {carry_stage4_out, sum_stage4} = adda_stage4 + addb_stage4 + carry_stage4;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset all pipeline registers
            adda_stage1 <= 16'b0;
            addb_stage1 <= 16'b0;
            carry_stage1 <= 1'b0;
            en_stage1 <= 1'b0;

            adda_stage2 <= 16'b0;
            addb_stage2 <= 16'b0;
            carry_stage2 <= 1'b0;
            en_stage2 <= 1'b0;

            adda_stage3 <= 16'b0;
            addb_stage3 <= 16'b0;
            carry_stage3 <= 1'b0;
            en_stage3 <= 1'b0;

            adda_stage4 <= 16'b0;
            addb_stage4 <= 16'b0;
            carry_stage4 <= 1'b0;
            en_stage4 <= 1'b0;

            en_stage5 <= 1'b0;
            en_stage6 <= 1'b0;

            result <= 65'b0;
            o_en <= 1'b0;
        end else begin
            // Stage 1 registers
            adda_stage1 <= adda[15:0];
            addb_stage1 <= addb[15:0];
            carry_stage1 <= 1'b0;  // No carry in for first stage
            en_stage1 <= i_en;

            // Stage 2 registers
            adda_stage2 <= adda[31:16];
            addb_stage2 <= addb[31:16];
            carry_stage2 <= carry_stage1_out;
            en_stage2 <= en_stage1;

            // Stage 3 registers
            adda_stage3 <= adda[47:32];
            addb_stage3 <= addb[47:32];
            carry_stage3 <= carry_stage2_out;
            en_stage3 <= en_stage2;

            // Stage 4 registers
            adda_stage4 <= adda[63:48];
            addb_stage4 <= addb[63:48];
            carry_stage4 <= carry_stage3_out;
            en_stage4 <= en_stage3;

            // Pipeline the enable signal
            en_stage5 <= en_stage4;
            en_stage6 <= en_stage5;

            // Combine results when all stages are complete
            if (en_stage6) begin
                result <= {carry_stage4_out, sum_stage4, sum_stage3, sum_stage2, sum_stage1};
                o_en <= 1'b1;
            end else begin
                o_en <= 1'b0;
            end
        end
    end

endmodule
