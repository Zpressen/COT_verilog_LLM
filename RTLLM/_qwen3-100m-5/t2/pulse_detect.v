module pulse_detect (
    input clk,
    input rst_n,
    input data_in,
    output reg data_out
);

reg data_prev1;
reg data_prev2;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        data_prev1 <= data_in;
        data_prev2 <= data_in;
        data_out <= 1'b0;
    end else begin
        data_prev2 <= data_prev1;
        data_prev1 <= data_in;
        if (data_prev2 == 1'b0 && data_prev1 == 1'b1 && data_in == 1'b0)
            data_out <= 1'b1;
        else
            data_out <= 1'b0;
    end
end

endmodule
