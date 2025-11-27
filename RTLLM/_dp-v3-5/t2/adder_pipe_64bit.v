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
    reg [15:0] adda_stage1, addb_stage1;
    reg [15:0] adda_stage2, addb_stage2;
    reg [15:0] adda_stage3, addb_stage3;
    reg [15:0] adda_stage4, addb_stage4;
    
    // Carry registers between stages
    reg carry_stage1, carry_stage2, carry_stage3;
    
    // Partial sum registers
    reg [15:0] sum_stage1, sum_stage2, sum_stage3;
    
    // Pipeline enable signals
    reg en_stage1, en_stage2, en_stage3;
    
    // Stage 1: Add bits [15:0]
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            adda_stage1 <= 16'b0;
            addb_stage1 <= 16'b0;
            sum_stage1 <= 16'b0;
            carry_stage1 <= 1'b0;
            en_stage1 <= 1'b0;
        end else begin
            if (i_en) begin
                {carry_stage1, sum_stage1} <= adda[15:0] + addb[15:0];
                adda_stage1 <= adda[31:16];
                addb_stage1 <= addb[31:16];
            end
            en_stage1 <= i_en;
        end
    end
    
    // Stage 2: Add bits [31:16] with carry from stage 1
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            adda_stage2 <= 16'b0;
            addb_stage2 <= 16'b0;
            sum_stage2 <= 16'b0;
            carry_stage2 <= 1'b0;
            en_stage2 <= 1'b0;
        end else begin
            if (en_stage1) begin
                {carry_stage2, sum_stage2} <= adda_stage1 + addb_stage1 + carry_stage1;
                adda_stage2 <= adda[47:32];
                addb_stage2 <= addb[47:32];
            end
            en_stage2 <= en_stage1;
        end
    end
    
    // Stage 3: Add bits [47:32] with carry from stage 2
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            adda_stage3 <= 16'b0;
            addb_stage3 <= 16'b0;
            sum_stage3 <= 16'b0;
            carry_stage3 <= 1'b0;
            en_stage3 <= 1'b0;
        end else begin
            if (en_stage2) begin
                {carry_stage3, sum_stage3} <= adda_stage2 + addb_stage2 + carry_stage2;
                adda_stage3 <= adda[63:48];
                addb_stage3 <= addb[63:48];
            end
            en_stage3 <= en_stage2;
        end
    end
    
    // Stage 4: Final addition and output generation
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            result <= 65'b0;
            o_en <= 1'b0;
        end else begin
            if (en_stage3) begin
                result[64] <= adda_stage3 + addb_stage3 + carry_stage3 > 65535;  // Final carry
                result[63:48] <= adda_stage3 + addb_stage3 + carry_stage3;
                result[47:32] <= sum_stage3;
                result[31:16] <= sum_stage2;
                result[15:0] <= sum_stage1;
                o_en <= 1'b1;
            end else begin
                o_en <= 1'b0;
            end
        end
    end

endmodule
