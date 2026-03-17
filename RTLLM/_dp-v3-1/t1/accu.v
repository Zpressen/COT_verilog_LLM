module accu (
    input clk,
    input rst_n,
    input [7:0] data_in,
    input valid_in,
    output reg valid_out,
    output reg [9:0] data_out
);

    reg [1:0] counter;
    reg [9:0] accumulator;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset all registers
            counter <= 2'b00;
            accumulator <= 10'b0;
            data_out <= 10'b0;
            valid_out <= 1'b0;
        end
        else begin
            // Default assignment for valid_out (only high for one cycle)
            valid_out <= 1'b0;

            if (valid_in) begin
                // Accumulate input data
                accumulator <= accumulator + data_in;
                
                // Increment counter
                if (counter == 2'b11) begin
                    // When we've received 4 inputs
                    data_out <= accumulator + data_in;
                    valid_out <= 1'b1;
                    counter <= 2'b00;
                    accumulator <= 10'b0;
                end
                else begin
                    counter <= counter + 1;
                end
            end
        end
    end

endmodule
