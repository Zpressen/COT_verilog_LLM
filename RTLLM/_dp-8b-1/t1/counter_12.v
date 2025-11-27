module counter_12 (
    input wire rst_n,          // Active low reset
    input wire clk,            // Clock signal
    input wire valid_count,    // Count enable signal
    output reg [3:0] out       // 4-bit counter output
);

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        // Active low reset - reset counter to 0
        out <= 4'b0000;
    end
    else if (valid_count) begin
        // Increment counter when valid_count is high
        if (out == 4'd11) begin
            // Wrap around when reaching maximum count (11)
            out <= 4'b0000;
        end
        else begin
            // Normal increment
            out <= out + 4'b0001;
        end
    end
    // When valid_count is low, counter maintains its value
end

endmodule
