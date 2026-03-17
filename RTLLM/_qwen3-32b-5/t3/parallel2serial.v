module parallel2serial (
    input clk,
    input rst_n,
    input [3:0] d,
    output valid_out,
    output dout
);

reg [1:0] cnt;
reg [3:0] data_reg;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt <= 2'd0;
        data_reg <= 4'b0;
    end else begin
        if (cnt == 2'd3) begin
            cnt <= 2'd0;
            data_reg <= d;
        end else begin
            cnt <= cnt + 1;
            data_reg <= {data_reg[2:0], data_reg[3]};
        end
    end
end

assign valid_out = (cnt == 2'd0);
assign dout = data_reg[3];

endmodule
