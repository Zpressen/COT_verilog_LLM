module adder_pipe_64bit (
    input clk,
    input rst_n,
    input i_en,
    input [63:0] adda,
    input [63:0] addb,
    output reg [64:0] result,
    output reg o_en
);

    // Pipeline stage 0 registers
    reg [15:0] adda_0, addb_0;
    reg en_0;
    
    // Pipeline stage 1 registers
    reg [15:0] adda_1, addb_1;
    reg [15:0] sum_0;
    reg carry_0;
    reg en_1;
    
    // Pipeline stage 2 registers
    reg [15:0] adda_2, addb_2;
    reg [15:0] sum_1;
    reg carry_1;
    reg en_2;
    
    // Pipeline stage 3 registers
    reg [15:0] adda_3, addb_3;
    reg [15:0] sum_2;
    reg carry_2;
    reg en_3;
    
    // Final result registers
    reg [15:0] sum_3;
    reg carry_3;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset all pipeline registers
            adda_0 <= 16'b0;
            addb_0 <= 16'b0;
            en_0 <= 1'b0;
            
            adda_1 <= 16'b0;
            addb_1 <= 16'b0;
            sum_0 <= 16'b0;
            carry_0 <= 1'b0;
            en_1 <= 1'b0;
            
            adda_2 <= 16'b0;
            addb_2 <= 16'b0;
            sum_1 <= 16'b0;
            carry_1 <= 1'b0;
            en_2 <= 1'b0;
            
            adda_3 <= 16'b0;
            addb_3 <= 16'b0;
            sum_2 <= 16'b0;
            carry_2 <= 1'b0;
            en_3 <= 1'b0;
            
            sum_3 <= 16'b0;
            carry_3 <= 1'b0;
            
            result <= 65'b0;
            o_en <= 1'b0;
        end else begin
            // Pipeline stage 0: Register inputs and enable
            adda_0 <= adda[15:0];
            addb_0 <= addb[15:0];
            en_0 <= i_en;
            
            // Pipeline stage 1: First 16-bit addition and register
            {carry_0, sum_0} <= adda_0 + addb_0;
            adda_1 <= adda[31:16];
            addb_1 <= addb[31:16];
            en_1 <= en_0;
            
            // Pipeline stage 2: Second 16-bit addition with carry
            {carry_1, sum_1} <= adda_1 + addb_1 + carry_0;
            adda_2 <= adda[47:32];
            addb_2 <= addb[47:32];
            en_2 <= en_1;
            
            // Pipeline stage 3: Third 16-bit addition with carry
            {carry_2, sum_2} <= adda_2 + addb_2 + carry_1;
            adda_3 <= adda[63:48];
            addb_3 <= addb[63:48];
            en_3 <= en_2;
            
            // Final stage: Fourth 16-bit addition with carry and result assembly
            {carry_3, sum_3} <= adda_3 + addb_3 + carry_2;
            result <= {carry_3, sum_3, sum_2, sum_1, sum_0};
            o_en <= en_3;
        end
    end

endmodule
