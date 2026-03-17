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
reg [63:0] adda_reg, addb_reg;
reg [63:0] sum_reg;
reg [7:0] carry_reg;
reg [7:0] en_reg;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        // Reset all registers
        adda_reg <= 64'b0;
        addb_reg <= 64'b0;
        sum_reg <= 64'b0;
        carry_reg <= 8'b0;
        en_reg <= 8'b0;
        result <= 65'b0;
        o_en <= 1'b0;
    end
    else begin
        // Pipeline stage 0 (bits 7:0)
        if (i_en) begin
            {carry_reg[0], sum_reg[7:0]} <= adda[7:0] + addb[7:0];
            adda_reg[7:0] <= adda[7:0];
            addb_reg[7:0] <= addb[7:0];
        end
        
        // Pipeline stages 1-7
        for (integer i = 1; i < 8; i = i + 1) begin
            if (en_reg[i-1]) begin
                {carry_reg[i], sum_reg[i*8 +: 8]} <= 
                    adda_reg[i*8 +: 8] + addb_reg[i*8 +: 8] + carry_reg[i-1];
                adda_reg[i*8 +: 8] <= adda_reg[(i-1)*8 +: 8];
                addb_reg[i*8 +: 8] <= addb_reg[(i-1)*8 +: 8];
            end
        end
        
        // Propagate enable signal through pipeline
        en_reg[0] <= i_en;
        for (integer i = 1; i < 8; i = i + 1) begin
            en_reg[i] <= en_reg[i-1];
        end
        
        // Final output assembly
        if (en_reg[7]) begin
            result <= {carry_reg[7], sum_reg};
            o_en <= 1'b1;
        end else begin
            o_en <= 1'b0;
        end
    end
end

endmodule
