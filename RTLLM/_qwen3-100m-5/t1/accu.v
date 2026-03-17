module accu (
    input clk,
    input rst_n,
    input [7:0] data_in,
    input valid_in,
    output reg valid_out,
    output reg [9:0] data_out
);

reg [9:0] sum;
reg [3:0] cnt;
reg [9:0] next_sum;
reg [3:0] next_cnt;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        sum <= 10'd0;
        cnt <= 4'd0;
        valid_out <= 1'b0;
        data_out <= 10'd0;
    end else begin
        valid_out <= 1'b0;
        if (valid_in) begin
            if (cnt < 4) begin
                next_sum = sum + data_in;
                next_cnt = cnt + 1;
            end else begin
                next_sum = sum;
                next_cnt = cnt;
            end
        end else begin
            next_sum = sum;
            next_cnt = cnt;
        end

        if (next_cnt == 4) begin
            data_out <= next_sum;
            valid_out <= 1'b1;
            sum <= 10'd0;
            cnt <= 4'd0;
        end else begin
            sum <= next_sum;
            cnt <= next_cnt;
        end
    end
end

endmodule
