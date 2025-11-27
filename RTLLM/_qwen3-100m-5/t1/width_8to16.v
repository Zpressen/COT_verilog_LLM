module width_8to16 (
    input clk,
    input rst_n,
    input valid_in,
    input [7:0] data_in,
    output reg valid_out,
    output reg [15:0] data_out
);

reg [7:0] data_lock;
reg flag;
reg [15:0] next_data_out;
reg next_valid_out;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        data_lock <= 8'b0;
        flag <= 1'b0;
        next_data_out <= 16'b0;
        next_valid_out <= 1'b0;
        data_out <= 16'b0;
        valid_out <= 1'b0;
    end else begin
        if (valid_in) begin
            if (flag == 1'b0) begin
                data_lock <= data_in;
                flag <= 1'b1;
                next_data_out <= 16'b0;
                next_valid_out <= 1'b0;
            end else begin
                next_data_out <= {data_lock, data_in};
                next_valid_out <= 1'b1;
                data_lock <= 8'b0;
                flag <= 1'b0;
            end
        end
        data_out <= next_data_out;
        valid_out <= next_valid_out;
    end
end

endmodule
