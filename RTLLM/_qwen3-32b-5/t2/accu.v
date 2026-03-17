module accu (
    input clk,
    input rst_n,
    input [7:0] data_in,
    input valid_in,
    output reg valid_out,
    output reg [9:0] data_out
);

reg [3:0] count;
reg [9:0] sum;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        count <= 4'd0;
        sum <= 10'd0;
        valid_out <= 1'b0;
        data_out <= 10'd0;
    end else begin
        valid_out <= 1'b0;
        if (valid_in) begin
            if (count < 4'd4) begin
                if (count == 4'd3) begin
                    sum <= sum + data_in;
                    count <= 4'd0;
                    valid_out <= 1'b1;
                    data_out <= sum + data_in;
                end else begin
                    sum <= sum + data_in;
                    count <= count + 1;
                end
            end
        end
    end
end

endmodule
