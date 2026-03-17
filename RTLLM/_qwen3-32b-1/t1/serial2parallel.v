module serial2parallel (
    input clk,
    input rst_n,
    input din_serial,
    input din_valid,
    output reg [7:0] dout_parallel,
    output reg dout_valid
);

reg [3:0] counter;
reg [7:0] shift_register;
reg need_to_reset;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        shift_register <= 8'b0;
        counter <= 4'b0;
        dout_valid <= 1'b0;
        need_to_reset <= 1'b0;
    end else begin
        if (need_to_reset) begin
            shift_register <= 8'b0;
            counter <= 4'b0;
            need_to_reset <= 1'b0;
        end else if (din_valid) begin
            if (counter < 8) begin
                shift_register <= {shift_register[6:0], din_serial};
                counter <= counter + 1;
            end 
        end 

        if (counter == 8) begin
            need_to_reset <= 1'b1;
        end else begin
            need_to_reset <= 1'b0;
        end 

        dout_valid <= (counter == 8) ? 1'b1 : 1'b0;
        dout_parallel <= shift_register;
    end
end

endmodule
