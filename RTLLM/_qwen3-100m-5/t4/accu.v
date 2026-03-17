module accu (
    input clk,
    input rst_n,
    input [7:0] data_in,
    input valid_in,
    output valid_out,
    output [9:0] data_out
);

reg [9:0] sum_reg;
reg [2:0] count_reg;
reg will_count_reach_4_prev;

wire will_count_reach_4 = (count_reg == 3) && valid_in;

assign valid_out = (count_reg == 4);
assign data_out = sum_reg;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        will_count_reach_4_prev <= 1'b0;
    end else begin
        will_count_reach_4_prev <= will_count_reach_4;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        sum_reg <= 10'd0;
        count_reg <= 3'd0;
    end else begin
        if (will_count_reach_4_prev) begin
            sum_reg <= 10'd0;
            count_reg <= 3'd0;
        end else if (valid_in && (count_reg < 4)) begin
            sum_reg <= sum_reg + data_in;
            count_reg <= count_reg + 1;
        end
    end
end

endmodule
