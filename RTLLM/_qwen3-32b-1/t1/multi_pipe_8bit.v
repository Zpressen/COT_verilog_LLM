module multi_pipe_8bit (
    input clk,
    input rst_n,
    input mul_en_in,
    input [7:0] mul_a,
    input [7:0] mul_b,
    output reg mul_en_out,
    output reg [15:0] mul_out
);

reg [7:0] mul_a_reg, mul_b_reg;
reg [3:0] mul_en_out_reg;
reg [15:0] sum1, sum2, sum3, mul_out_reg;

// Input registers
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        mul_a_reg <= 8'd0;
        mul_b_reg <= 8'd0;
    end else if (mul_en_in) begin
        mul_a_reg <= mul_a;
        mul_b_reg <= mul_b;
    end
end

// Enable pipeline
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        mul_en_out_reg <= 4'b0;
    end else begin
        mul_en_out_reg <= {mul_en_out_reg[2:0], mul_en_in};
    end
end

assign mul_en_out = mul_en_out_reg[3];

// Partial products
wire [15:0] pp0 = (mul_b_reg[0]) ? (mul_a_reg << 0) : 16'd0;
wire [15:0] pp1 = (mul_b_reg[1]) ? (mul_a_reg << 1) : 16'd0;
wire [15:0] pp2 = (mul_b_reg[2]) ? (mul_a_reg << 2) : 16'd0;
wire [15:0] pp3 = (mul_b_reg[3]) ? (mul_a_reg << 3) : 16'd0;
wire [15:0] pp4 = (mul_b_reg[4]) ? (mul_a_reg << 4) : 16'd0;
wire [15:0] pp5 = (mul_b_reg[5]) ? (mul_a_reg << 5) : 16'd0;
wire [15:0] pp6 = (mul_b_reg[6]) ? (mul_a_reg << 6) : 16'd0;
wire [15:0] pp7 = (mul_b_reg[7]) ? (mul_a_reg << 7) : 16'd0;

// Pipeline stages for sum
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        sum1 <= 16'd0;
    end else begin
        sum1 <= pp0 + pp1;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        sum2 <= 16'd0;
    end else begin
        sum2 <= sum1 + pp2 + pp3;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        sum3 <= 16'd0;
    end else begin
        sum3 <= sum2 + pp4 + pp5;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        mul_out_reg <= 16'd0;
    end else begin
        mul_out_reg <= sum3 + pp6 + pp7;
    end
end

// Output assignment
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        mul_out <= 16'd0;
    end else begin
        if (mul_en_out) begin
            mul_out <= mul_out_reg;
        end else begin
            mul_out <= 16'd0;
        end
    end
end

endmodule
