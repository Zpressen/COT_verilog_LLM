module multi_pipe_8bit (
    input clk,
    input rst_n,
    input mul_en_in,
    input [7:0] mul_a,
    input [7:0] mul_b,
    output reg mul_en_out,
    output reg [15:0] mul_out
);

reg [7:0] mul_a_reg;
reg [7:0] mul_b_reg;
wire [15:0] temp [0:7];
wire [15:0] total_sum;
reg [3:0] mul_en_out_reg;
reg [15:0] mul_out_reg;

// Input registers
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        mul_a_reg <= 8'b0;
        mul_b_reg <= 8'b0;
    end else if (mul_en_in) begin
        mul_a_reg <= mul_a;
        mul_b_reg <= mul_b;
    end
end

// Partial product generation
genvar i;
generate
for (i=0; i<8; i=i+1) begin: gen_temp
    assign temp[i] = (mul_b_reg[i]) ? (mul_a_reg << i) : 16'b0;
end
endgenerate

// Total sum of all partial products
assign total_sum = temp[0] + temp[1] + temp[2] + temp[3] + 
                   temp[4] + temp[5] + temp[6] + temp[7];

// Enable pipeline
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        mul_en_out_reg <= 4'b0;
    end else begin
        mul_en_out_reg <= {mul_en_out_reg[2:0], mul_en_in};
    end
end

assign mul_en_out = mul_en_out_reg[3];

// Final product register
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        mul_out_reg <= 16'b0;
    end else if (mul_en_out_reg[3]) begin
        mul_out_reg <= total_sum;
    end else begin
        mul_out_reg <= mul_out_reg;
    end
end

// Output assignment
assign mul_out = (mul_en_out) ? mul_out_reg : 16'b0;

endmodule
