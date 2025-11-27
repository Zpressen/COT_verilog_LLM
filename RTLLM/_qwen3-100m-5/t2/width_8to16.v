module width_8to16 (
    input clk,
    input rst_n,
    input valid_in,
    input [7:0] data_in,
    output reg valid_out,
    output reg [15:0] data_out
);

reg [7:0] data_prev;
reg stored_flag;
reg [15:0] pending_data;
reg output_valid_flag;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        data_prev <= 8'b0;
        stored_flag <= 1'b0;
        pending_data <= 16'b0;
        output_valid_flag <= 1'b0;
        data_out <= 16'b0;
        valid_out <= 1'b0;
    end else begin
        if (valid_in) begin
            if (!stored_flag) begin
                data_prev <= data_in;
                stored_flag <= 1'b1;
            end else begin
                pending_data <= {data_prev, data_in};
                output_valid_flag <= 1'b1;
                stored_flag <= 1'b0;
            end
        end
        if (output_valid_flag) begin
            data_out <= pending_data;
            valid_out <= 1'b1;
            output_valid_flag <= 1'b0;
        end else begin
            valid_out <= 1'b0;
        end
    end
end

endmodule
