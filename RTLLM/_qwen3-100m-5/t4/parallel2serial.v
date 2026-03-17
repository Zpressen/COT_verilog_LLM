[EGIN]
module parallel2serial (
    input clk,
    input rst_n,
    input [3:0] d,
    output reg valid_out,
    output reg dout
);

reg [1:0] cnt;  // 2-bit counter to count 0 to 3
reg [3:0] data_reg;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt <= 0;
        data_reg <= 0;
        valid_out <= 0;
        dout <= 0;
    end else begin
        // Shift data_reg left first
        data_reg <= data_reg << 1;
        // Capture the new MSB
        dout <= data_reg[3];
        // Update cnt and valid_out
        if (cnt == 3) begin
            cnt <= 0;
            data_reg <= d;  // Overwrite the shifted data with new d
            valid_out <= 1;
        end else begin
            cnt <= cnt + 1;
            valid_out <= 1;
        end
    end
end

endmodule
