module width_8to16(
    input clk,
    input rst_n,
    input valid_in,
    input [7:0] data_in,
    output reg [15:0] data_out,
    output reg valid_out
);

reg [7:0] data_lock;
reg has_first;
reg pending_valid;
reg [15:0] data_concat_prev;
reg pending_valid_prev;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        data_lock <= 8'b0;
        has_first <= 1'b0;
        pending_valid <= 1'b0;
        data_concat_prev <= 16'b0;
        pending_valid_prev <= 1'b0;
        data_out <= 16'b0;
        valid_out <= 1'b0;
    end else begin
        pending_valid_prev <= pending_valid;
        
        if (valid_in) begin
            if (!has_first) begin
                data_lock <= data_in;
                has_first <= 1'b1;
                pending_valid <= 1'b0;
            end else begin
                data_concat_prev <= {data_lock, data_in};
                has_first <= 1'b0;
                pending_valid <= 1'b1;
            end
        end else begin
            pending_valid <= 1'b0;
        end
        
        if (pending_valid_prev) begin
            data_out <= data_concat_prev;
            valid_out <= 1'b1;
        end else begin
            data_out <= 16'b0;
            valid_out <= 1'b0;
        end
    end
end

endmodule
