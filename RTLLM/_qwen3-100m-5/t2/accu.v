module accu(
    input clk,
    input rst_n,
    input [7:0] data_in,
    input valid_in,
    output reg valid_out,
    output [9:0] data_out
);

reg [3:0] count;
reg [9:0] sum;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        count <= 4'd0;
        sum <= 10'd0;
        valid_out <= 1'b0;
    end else begin
        if (valid_in) begin
            if (count == 4) begin
                count <= 4'd0;
                sum <= 10'd0;
                valid_out <= 1'b0;
            end else begin
                if (count == 3) begin
                    count <= 4'd4;
                    sum <= sum + data_in;
                    valid_out <= 1'b1;
                end else begin
                    count <= count + 1;
                    sum <= sum + data_in;
                    valid_out <= 1'b0;
                end
            end
        end else begin
            count <= count;
            sum <= sum;
            valid_out <= 1'b0;
        end
    end
end

assign data_out = sum;

endmodule
