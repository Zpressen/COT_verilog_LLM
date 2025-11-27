module JC_counter (
    input clk,
    input rst_n,
    output reg [63:0] Q
);

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        // Active-low reset: clear all bits
        Q <= 64'b0;
    end
    else begin
        // Johnson counter behavior
        if (Q[0] == 1'b0) begin
            // Shift right and append 1 at MSB (increment phase)
            Q <= {1'b1, Q[63:1]};
        end
        else begin
            // Shift right and append 0 at MSB (decrement phase)
            Q <= {1'b0, Q[63:1]};
        end
    end
end

endmodule
