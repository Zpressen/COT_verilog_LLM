module adder_pipe_64bit (
    input wire clk,
    input wire rst_n,
    input wire i_en,
    input wire [63:0] adda,
    input wire [63:0] addb,
    output reg [64:0] result,
    output reg o_en
);

    // Pipeline registers
    reg [63:0] adda_reg1, addb_reg1;
    reg [63:0] adda_reg2, addb_reg2;
    reg [63:0] adda_reg3, addb_reg3;
    reg [63:0] adda_reg4, addb_reg4;
    
    // Carry signals for each stage
    reg carry_reg1, carry_reg2, carry_reg3;
    
    // Partial sums
    wire [15:0] sum_stage1;
    wire [31:0] sum_stage2;
    wire [47:0] sum_stage3;
    
    // Enable signal pipeline
    reg en_reg1, en_reg2, en_reg3, en_reg4;
    
    // Stage 1: Add lower 16 bits
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            adda_reg1 <= 64'b0;
            addb_reg1 <= 64'b0;
            carry_reg1 <= 1'b0;
            en_reg1 <= 1'b0;
        end else begin
            adda_reg1 <= adda;
            addb_reg1 <= addb;
            carry_reg1 <= 1'b0; // No carry in for first stage
            en_reg1 <= i_en;
        end
    end
    
    assign sum_stage1 = adda_reg1[15:0] + addb_reg1[15:0] + carry_reg1;
    
    // Stage 2: Add next 16 bits (16-31)
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            adda_reg2 <= 64'b0;
            addb_reg2 <= 64'b0;
            carry_reg2 <= 1'b0;
            en_reg2 <= 1'b0;
        end else begin
            adda_reg2 <= adda_reg1;
            addb_reg2 <= addb_reg1;
            carry_reg2 <= sum_stage1[16]; // Carry from stage 1
            en_reg2 <= en_reg1;
        end
    end
    
    assign sum_stage2 = {adda_reg2[31:16] + addb_reg2[31:16] + carry_reg2, sum_stage1[15:0]};
    
    // Stage 3: Add next 16 bits (32-47)
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            adda_reg3 <= 64'b0;
            addb_reg3 <= 64'b0;
            carry_reg3 <= 1'b0;
            en_reg3 <= 1'b0;
        end else begin
            adda_reg3 <= adda_reg2;
            addb_reg3 <= addb_reg2;
            carry_reg3 <= sum_stage2[32]; // Carry from stage 2
            en_reg3 <= en_reg2;
        end
    end
    
    assign sum_stage3 = {adda_reg3[47:32] + addb_reg3[47:32] + carry_reg3, sum_stage2[31:0]};
    
    // Stage 4: Add upper 16 bits (48-63) and generate final result
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            adda_reg4 <= 64'b0;
            addb_reg4 <= 64'b0;
            result <= 65'b0;
            o_en <= 1'b0;
            en_reg4 <= 1'b0;
        end else begin
            adda_reg4 <= adda_reg3;
            addb_reg4 <= addb_reg3;
            result <= {adda_reg4[63:48] + addb_reg4[63:48] + sum_stage3[48], sum_stage3[47:0]};
            o_en <= en_reg3;
            en_reg4 <= en_reg3;
        end
    end

endmodule
