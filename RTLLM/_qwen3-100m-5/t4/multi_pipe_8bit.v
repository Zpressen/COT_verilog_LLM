module multi_pipe_8bit (
    input clk,
    input rst_n,
    input mul_en_in,
    input [7:0] mul_a,
    input [7:0] mul_b,
    output logic mul_en_out,
    output logic [15:0] mul_out
);

logic [2:0] mul_en_out_reg;
logic [7:0] mul_a_reg;
logic [7:0] mul_b_reg;
logic [15:0] sum [0:2];
logic [15:0] mul_out_reg;

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        mul_en_out_reg <= 3'b0;
    end else begin
        mul_en_out_reg <= {mul_en_out_reg[1:0], mul_en_in};
    end
end

assign mul_en_out = mul_en_out_reg[2];

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        mul_a_reg <= 8'b0;
        mul_b_reg <= 8'b0;
    end else if (mul_en_in) begin
        mul_a_reg <= mul_a;
        mul_b_reg <= mul_b;
    end
end

wire [15:0] temp [0:7];
genvar i;
generate
    for (i=0; i<8; i=i+1) begin: gen_temp
        assign temp[i] = (mul_b_reg[i]) ? (mul_a_reg << i) : 16'b0;
    end
endgenerate

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        sum[0] <= 16'b0;
        sum[1] <= 16'b0;
        sum[2] <= 16'b0;
    end else begin
        if (mul_en_out_reg[0]) begin
            sum[0] <= temp[0] + temp[1] + temp[2] + temp[3];
        end
        if (mul_en_out_reg[1]) begin
            sum[1] <= sum[0] + temp[4] + temp[5] + temp[6] + temp[7];
        end
        if (mul_en_out_reg[2]) begin
            sum[2] <= sum[1];
        end
    end
end

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        mul_out_reg <= 16'b0;
    end else if (mul_en_out_reg[2]) begin
        mul_out_reg <= sum[2];
    end
end

assign mul_out = (mul_en_out) ? mul_out_reg : 16'b0;

endmodule
