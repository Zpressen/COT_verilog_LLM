module width_8to16(
    input clk,
    input rst_n,
    input valid_in,
    input [7:0] data_in,
    output reg valid_out,
    output reg [15:0] data_out
);

reg [7:0] data_lock;
reg flag;
reg [15:0] data_temp;
reg next_valid;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        data_lock <= 8'b0;
        flag <= 1'b0;
        data_temp <= 16'b0;
        next_valid <= 1'b0;
    end else begin
        if (valid_in) begin
            if (flag) begin
                data_temp <= {data_lock, data_in};
                next_valid <= 1'b1;
                flag <= 1'b0;
            end else begin
                data_lock <= data_in;
                flag <= 1'b1;
                data_temp <= data_temp;
                next_valid <= 1'b0;
            end
        end else begin
            data_temp <= data_temp;
            next_valid <= 1'b0;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        valid_out <= 1'b0;
        data_out <= 16'b0;
    end else begin
        valid_out <= next_valid;
        data_out <= data_temp;
    end
end

endmodule
