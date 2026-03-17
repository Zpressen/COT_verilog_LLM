module serial2parallel (
    input clk,
    input rst_n,
    input din_serial,
    input din_valid,
    output reg [7:0] dout_parallel,
    output reg dout_valid
);

reg [7:0] shift_reg;
reg [3:0] cnt;

always @(posedge clk) begin
    if (!rst_n) begin
        shift_reg <= 8'b0;
        cnt <= 4'b0;
        dout_parallel <= 8'b0;
        dout_valid <= 1'b0;
    end else begin
        if (din_valid) begin
            if (cnt == 4'd7) begin
                shift_reg <= {shift_reg[6:0], din_serial};
                cnt <= 4'd0;
                dout_parallel <= shift_reg;
                dout_valid <= 1'b1;
            end else begin
                shift_reg <= {shift_reg[6:0], din_serial};
                cnt <= cnt + 1;
                dout_parallel <= shift_reg;
                dout_valid <= 1'b0;
            end
        end else begin
            dout_valid <= 1'b0;
        end
    end
end

endmodule
