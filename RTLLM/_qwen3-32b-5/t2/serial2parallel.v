[BEING]
module serial2parallel (
    input clk,
    input rst_n,
    input din_serial,
    input din_valid,
    output reg [7:0] dout_parallel,
    output reg dout_valid
);

reg [7:0] shift_reg;
reg [2:0] pointer;
reg [3:0] counter;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        shift_reg <= 8'b0;
        pointer <= 3'd7;
        counter <= 4'd0;
        dout_valid <= 1'b0;
        dout_parallel <= 8'b0;
    end else begin
        dout_parallel <= shift_reg;
        if (din_valid) begin
            if (counter < 8) begin
                shift_reg <= (shift_reg & ~(1 << pointer)) | (din_serial << pointer);
                pointer <= pointer - 1;
                counter <= counter + 1;
                dout_valid <= 1'b0;
            end
            if (counter == 8) begin
                dout_valid <= 1'b1;
                pointer <= 3'd7;
                counter <= 4'd0;
            end
        end
    end
end

endmodule
