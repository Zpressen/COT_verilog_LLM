module multi_pipe_8bit (
    input clk,
    input rst_n,
    input mul_en_in,
    input [7:0] mul_a,
    input [7:0] mul_b,
    output reg mul_en_out,
    output reg [15:0] mul_out
);

reg [1:0] mul_en_out_reg;
reg [7:0] mul_a_reg, mul_b_reg;
reg [15:0] sum1, sum2;
reg [15:0] mul_out_reg;

// Input enable register
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        mul_en_out_reg <= 2'b0;
    end else begin
        mul_en_out_reg <= {mul_en_out_reg[0], mul_en_in};
    end
end

assign mul_en_out = mul_en_out_reg[1];

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

// Partial products
wire [15:0] pp0 = (mul_b_reg[0]) ? (mul_a_reg << 0) : 16'h0;
wire [15:0] pp1 = (mul_b_reg[1]) ? (mul_a_reg << 1) : 16'h0;
wire [15:0] pp2 = (mul_b_reg[2]) ? (mul_a_reg << 2) : 16'h0;
wire [15:0] pp3 = (mul_b_reg[3]) ? (mul_a_reg << 3) : 16'h0;
wire [15:0] pp4 = (mul_b_reg[4]) ? (mul_a_reg << 4) : 16'h0;
wire [15:0] pp5 = (mul_b_reg[5]) ? (mul_a_reg << 5) : 16'h0;
wire [15:0] pp6 = (mul_b_reg[6]) ? (mul_a_reg << 6) : 16'h0;
wire [15:0] pp7 = (mul_b_reg[7]) ? (mul_a_reg << 7) : 16'h0;

// Partial sum registers
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        sum1 <= 16'b0;
        sum2 <= 16'b0;
    end else begin
        if (mul_en_out_reg[0]) begin
            sum1 <= pp0 + pp1 + pp2 + pp3;
        end
        if (mul_en_out_reg[1]) begin
            sum2 <= sum1 + pp4 + pp5 + pp6 + pp7;
        end
    end
end

// Final product register
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        mul_out_reg <= 16'b0;
    end else if (mul_en_out_reg[1]) begin
        mul_out_reg <= sum2;
    end
end

// Output assignment
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        mul_out <= 16'b0;
    end else begin
        if (mul_en_out) begin
            mul_out <= mul_out_reg;
        end else begin
            mul_out <= 16'b0;
        end
    end
end

endmodule
