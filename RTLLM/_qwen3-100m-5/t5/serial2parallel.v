module serial2parallel(
    input clk,
    input rst_n,
    input din_serial,
    input din_valid,
    output [7:0] dout_parallel,
    output reg dout_valid
);

reg [3:0] cnt;
reg [7:0] shift_register;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt <= 4'd0;
        shift_register <= 8'd0;
        dout_valid <= 1'b0;
    end else begin
        if (din_valid) begin
            if (cnt == 4'd8) begin
                cnt <= 4'd0;
                dout_valid <= 1'b0;
            end else begin
                cnt <= cnt + 1;
                if ((cnt + 1) == 4'd8) begin
                    dout_valid <= 1'b1;
                end else begin
                    dout_valid <= 1'b0;
                end
                if (cnt < 4'd8) begin
                    shift_register <= {din_serial, shift_register[7:1]};
                end
            end
        end
    end
end

assign dout_parallel = shift_register;

endmodule
