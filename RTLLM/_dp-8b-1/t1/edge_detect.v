module edge_detect (
    input  wire clk,
    input  wire rst_n,
    input  wire a,
    output reg  rise,
    output reg  down
);

    reg a_prev;  // Stores the previous value of 'a'

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Active-low reset
            a_prev <= 1'b0;
            rise   <= 1'b0;
            down   <= 1'b0;
        end
        else begin
            // Detect edges by comparing current and previous values
            rise <= (a & ~a_prev);  // Rising edge: current=1, previous=0
            down <= (~a & a_prev);  // Falling edge: current=0, previous=1
            
            // Store current value for next comparison
            a_prev <= a;
        end
    end

endmodule
