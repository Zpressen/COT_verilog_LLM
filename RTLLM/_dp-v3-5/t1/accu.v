module accu (
    input clk,
    input rst_n,
    input [7:0] data_in,
    input valid_in,
    output reg valid_out,
    output reg [9:0] data_out
);

    reg [1:0] count;       // Count from 0 to 3 (4 inputs)
    reg [9:0] accumulator; // Accumulate up to 4 inputs

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset all registers
            count <= 2'b0;
            accumulator <= 10'b0;
            data_out <= 10'b0;
            valid_out <= 1'b0;
        end
        else begin
            // Default assignment
            valid_out <= 1'b0;
            
            if (valid_in) begin
                // Add input to accumulator
                accumulator <= accumulator + data_in;
                
                if (count == 2'b11) begin
                    // After 4 inputs, output result
                    data_out <= accumulator + data_in;
                    valid_out <= 1'b1;
                    count <= 2'b0;
                    accumulator <= 10'b0;
                end
                else begin
                    // Increment counter
                    count <= count + 1;
                end
            end
        end
    end

endmodule
