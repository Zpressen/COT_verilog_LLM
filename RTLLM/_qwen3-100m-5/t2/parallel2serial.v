module parallel2serial(
    input clk,
    input rst_n,
    input [3:0] d,
    output reg valid_out,
    output reg dout
);

reg [3:0] data;
reg [1:0] cnt;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        data <= 4'b0;
        cnt <= 2'b0;
        valid_out <= 1'b0;
    end else begin
        if (cnt == 3) begin
            data <= d;
            cnt <= 2'b0;
            valid_out <= 1'b1;
        end else begin
            data <= {data[2:0], data[3]};
            cnt <= cnt + 1;
            valid_out <= 1'b0;
        end
    end
end

assign dout = data[3];

endmodule
