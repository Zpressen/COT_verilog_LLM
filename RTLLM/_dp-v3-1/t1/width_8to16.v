module width_8to16 (
    input clk,
    input rst_n,
    input valid_in,
    input [7:0] data_in,
    output reg valid_out,
    output reg [15:0] data_out
);

reg [7:0] data_lock;
reg has_first_byte;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        // Reset all registers and flags
        data_lock <= 8'b0;
        has_first_byte <= 1'b0;
        valid_out <= 1'b0;
        data_out <= 16'b0;
    end
    else begin
        // Clear valid_out every cycle unless we're asserting it
        valid_out <= 1'b0;
        
        if (valid_in) begin
            if (!has_first_byte) begin
                // Store first byte and set flag
                data_lock <= data_in;
                has_first_byte <= 1'b1;
            end
            else begin
                // We have both bytes now, output the concatenated data
                data_out <= {data_lock, data_in};
                valid_out <= 1'b1;
                has_first_byte <= 1'b0;
            end
        end
    end
end

endmodule
