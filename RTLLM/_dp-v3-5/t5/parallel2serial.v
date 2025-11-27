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
            cnt <= 2'b0;
            data <= 4'b0;
            valid_out <= 1'b0;
            dout <= 1'b0;
        end
        else begin
            if (cnt == 2'b11) begin
                // Last bit is being output, load new data
                data <= d;
                cnt <= 2'b0;
                valid_out <= 1'b1;
                dout <= d[3]; // Output MSB first
            end
            else begin
                // Shift data and increment counter
                cnt <= cnt + 1;
                valid_out <= 1'b0;
                data <= {data[2:0], data[3]}; // Rotate left
                dout <= data[2]; // Next bit to output
            end
        end
    end

endmodule
