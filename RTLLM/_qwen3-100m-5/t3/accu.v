module accu(
    input clk,
    input rst_n,
    input [7:0] data_in,
    input valid_in,
    output reg valid_out,
    output [9:0] data_out
);

reg [2:0] cnt;
reg [9:0] sum_reg;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt <= 3'd0;
        sum_reg <= 10'd0;
        valid_out <= 1'b0;
    end else begin
        if (valid_in) begin
            if (cnt < 4) begin
                sum_reg <= sum_reg + data_in;
                cnt <= cnt + 1;
                if (cnt + 1 == 4) 
                    valid_out <= 1'b1;
                else 
                    valid_out <= 1'b0;
            end else begin
                sum_reg <= 10'd0;
                cnt <= 3'd0;
                valid_out <= 1'b0;
            end
        end else begin
            valid_out <= 1'b0;
        end
    end
end

assign data_out = valid_out ? sum_reg : 10'd0;

endmodule
