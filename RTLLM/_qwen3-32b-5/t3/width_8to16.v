module width_8to16 (
    input clk,
    input rst_n,
    input valid_in,
    input [7:0] data_in,
    output reg valid_out,
    output reg [15:0] data_out
);

reg [7:0] data_lock;
reg waiting_for_second;
reg [15:0] data_out_prev;
reg valid_out_prev;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        data_out <= 16'b0;
        valid_out <= 1'b0;
        data_lock <= 8'b0;
        waiting_for_second <= 1'b0;
        data_out_prev <= 16'b0;
        valid_out_prev <= 1'b0;
    end else begin
        // Assign current output based on previous values
        data_out <= data_out_prev;
        valid_out <= valid_out_prev;

        // Default: clear the previous values
        data_out_prev <= 16'b0;
        valid_out_prev <= 1'b0;

        if (valid_in) begin
            if (waiting_for_second) begin
                // Second data arrived
                data_out_prev <= {data_lock, data_in};
                valid_out_prev <= 1'b1;
                data_lock <= 8'b0; // Clear the data lock
                waiting_for_second <= 1'b0; // Reset the flag
            end else begin
                // First data
                data_lock <= data_in;
                waiting_for_second <= 1'b1;
            end
        end
    end
end

endmodule
