module parallel2serial (
    input clk,
    input rst_n,
    input [3:0] d,
    output reg valid_out,
    output reg dout
);

    reg [1:0] cnt;
    reg [3:0] data;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset condition
            cnt <= 2'b0;
            data <= 4'b0;
            dout <= 1'b0;
            valid_out <= 1'b0;
        end
        else begin
            if (cnt == 2'b11) begin
                // Load new data and reset counter
                data <= d;
                cnt <= 2'b0;
                dout <= d[3];  // Output MSB first
                valid_out <= 1'b1;
            end
            else begin
                // Shift data and increment counter
                cnt <= cnt + 1'b1;
                data <= {data[2:0], 1'b0};  // Shift left
                dout <= data[3];
                valid_out <= 1'b1;
            end
        end
    end

endmodule
