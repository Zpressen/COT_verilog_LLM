module multi_pipe_8bit (
    input clk,
    input rst_n,
    input mul_en_in,
    input [7:0] mul_a,
    input [7:0] mul_b,
    output mul_en_out,
    output [15:0] mul_out
);

reg [7:0] mul_a_reg, mul_b_reg;
reg [3:0] mul_en_out_reg;
wire [15:0] p0, p1, p2, p3, p4, p5, p6, p7;
wire [15:0] s1_0, s1_1, s1_2, s1_3;
reg [15:0] s1_reg_0, s1_reg_1, s1_reg_2, s1_reg_3;
wire [15:0] s2_0, s2_1;
reg [15:0] s2_reg_0, s2_reg_1;
wire [15:0] final_sum;
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

// Enable register
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        mul_en_out_reg <= 4'b0;
    else
        mul_en_out_reg <= {mul_en_out_reg[2:0], mul_en_in};
end

assign mul_en_out = mul_en_out_reg[3];

// Partial products
assign p0 = (mul_b_reg[0]) ? (mul_a_reg << 0) : 16'b0;
assign p1 = (mul_b_reg[1]) ? (mul_a_reg << 1) : 16'b0;
assign p2 = (mul_b_reg[2]) ? (mul_a_reg << 2) : 16'b0;
assign p3 = (mul_b_reg[3]) ? (mul_a_reg << 3) : 16'b0;
assign p4 = (mul_b_reg[4]) ? (mul_a_reg << 4) : 16'b0;
assign p5 = (mul_b_reg[5]) ? (mul_a_reg << 5) : 16'b0;
assign p6 = (mul_b_reg[6]) ? (mul_a_reg << 6) : 16'b0;
assign p7 = (mul_b_reg[7]) ? (mul_a_reg << 7) : 16'b0;

// First addition stage (stage 2)
assign s1_0 = p0 + p1;
assign s1_1 = p2 + p3;
assign s1_2 = p4 + p5;
assign s1_3 = p6 + p7;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        s1_reg_0 <= 16'b0;
        s1_reg_1 <= 16'b0;
        s1_reg_2 <= 16'b0;
        s1_reg_3 <= 16'b0;
    end else if (mul_en_out_reg[1]) begin
        s1_reg_0 <= s1_0;
        s1_reg_1 <= s1_1;
        s1_reg_2 <= s1_2;
        s1_reg_3 <= s1_3;
    end
end

// Second addition stage (stage 3)
assign s2_0 = s1_reg_0 + s1_reg_1;
assign s2_1 = s1_reg_2 + s1_reg_3;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        s2_reg_0 <= 16'b0;
        s2_reg_1 <= 16'b0;
    end else if (mul_en_out_reg[2]) begin
        s2_reg_0 <= s2_0;
        s2_reg_1 <= s2_1;
    end
end

// Final addition stage (stage 4)
assign final_sum = s2_reg_0 + s2_reg_1;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        mul_out_reg <= 16'b0;
    end else if (mul_en_out_reg[3]) begin
        mul_out_reg <= final_sum;
    end
end

// Output assignment
assign mul_out = (mul_en_out) ? mul_out_reg : 16'b0;

endmodule
