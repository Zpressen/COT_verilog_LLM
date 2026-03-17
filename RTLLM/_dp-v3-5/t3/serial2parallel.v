module serial2parallel (
    input clk,
    input rst_n,
    input din_serial,
    input din_valid,
    output reg [7:0] dout_parallel,
    output reg dout_valid
);

    reg [3:0] cnt;  // 4-bit counter (0-7)
    reg [7:0] shift_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt <= 4'b0;
            shift_reg <= 8'b0;
            dout_parallel <= 8'b0;
            dout_valid <= 1'b0;
        end
        else begin
            dout_valid <= 1'b0;  // Default to 0, only pulse when 8 bits received
            
            if (din_valid) begin
                // Shift in new bit (MSB first)
                shift_reg <= {shift_reg[6:0], din_serial};
                
                // Increment counter
                if (cnt == 4'd7) begin
                    cnt <= 4'b0;
                    dout_parallel <= {shift_reg[6:0], din_serial};
                    dout_valid <= 1'b1;
                end
                else begin
                    cnt <= cnt + 4'b1;
                end
            end
        end
    end

endmodule
