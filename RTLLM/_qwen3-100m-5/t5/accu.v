module accu(
    input clk,
    input rst_n,
    input [7:0] data_in,
    input valid_in,
    output reg valid_out,
    output reg [9:0] data_out
);

reg [2:0] count_reg;
reg [3:0][7:0] data_reg;
reg [9:0] sum_out_reg;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        count_reg <= 3'd0;
        data_reg <= '{default: 8'd0};
        sum_out_reg <= 10'd0;
        valid_out <= 1'b0;
        data_out <= 10'd0;
    end else begin
        if (valid_in && (count_reg < 4)) begin
            data_reg[count_reg] <= data_in;
            count_reg <= count_reg + 1;
            if (count_reg + 1 == 4) begin
                sum_out_reg <= data_reg[0] + data_reg[1] + data_reg[2] + data_in;
                valid_out <= 1'b1;
                data_out <= sum_out_reg;
            end else begin
                valid_out <= 1'b0;
                data_out <= 10'd0;
            end
        end else if (count_reg == 4) begin
            count_reg <= 3'd0;
            valid_out <= 1'b0;
            data_out <= 10'd0;
        end else begin
            valid_out <= 1'b0;
            data_out <= 10'd0;
        end
    end
end

endmodule
