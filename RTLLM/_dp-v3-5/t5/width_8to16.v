module width_8to16 (
    input clk,
    input rst_n,
    input valid_in,
    input [7:0] data_in,
    output reg valid_out,
    output reg [15:0] data_out
);

    reg [7:0] data_lock;  // To store the first 8-bit input
    reg flag;             // Flag to indicate we have the first part

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset all registers
            data_lock <= 8'b0;
            flag <= 1'b0;
            valid_out <= 1'b0;
            data_out <= 16'b0;
        end
        else begin
            // Clear valid_out every cycle unless we're outputting data
            valid_out <= 1'b0;

            if (valid_in) begin
                if (!flag) begin
                    // First valid input: store data and set flag
                    data_lock <= data_in;
                    flag <= 1'b1;
                end
                else begin
                    // Second valid input: combine with stored data and output
                    data_out <= {data_lock, data_in};
                    valid_out <= 1'b1;
                    flag <= 1'b0;
                end
            end
        end
    end

endmodule
