module width_8to16 (
    input clk,
    input rst_n,
    input valid_in,
    input [7:0] data_in,
    output reg valid_out,
    output reg [15:0] data_out
);

reg [7:0] data_lock;
reg has_data;
reg [15:0] output_data;
reg output_ready;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        data_lock <= 8'b0;
        has_data <= 1'b0;
        output_data <= 16'b0;
        output_ready <= 1'b0;
        valid_out <= 1'b0;
        data_out <= 16'b0;
    end else begin
        if (valid_in) begin
            if (!has_data) begin
                data_lock <= data_in;
                has_data <= 1'b1;
            end else begin
                output_data <= {data_lock, data_in};
                output_ready <= 1'b1;
                has_data <= 1'b0;
            end
        end

        if (output_ready) begin
            valid_out <= 1'b1;
            data_out <= output_data;
            output_ready <= 1'b0;
        end else begin
            valid_out <= 1'b0;
        end
    end
end

endmodule
