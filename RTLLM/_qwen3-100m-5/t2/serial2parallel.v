module serial2parallel(
    input              clk,
    input              rst_n,
    input              din_serial,
    input              din_valid,
    output reg [7:0]   dout_parallel,
    output reg         dout_valid
);

reg [3:0] cnt;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt <= 4'b0;
        dout_parallel <= 8'b0;
        dout_valid <= 1'b0;
    end else begin
        if (din_valid) begin
            if (cnt == 8) begin
                cnt <= 4'b0;
            end else begin
                cnt <= cnt + 1;
            end
        end
        
        if (din_valid && (cnt < 8)) begin
            dout_parallel <= {din_serial, dout_parallel[7:1]};
        end
        
        dout_valid <= (cnt == 8) ? 1'b1 : 1'b0;
    end
end

endmodule
