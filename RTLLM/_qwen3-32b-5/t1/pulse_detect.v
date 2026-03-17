module pulse_detect (
    input      clk,
    input      rst_n,
    input      data_in,
    output reg data_out
);

reg prev_prev;
reg prev;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        prev_prev <= 1'b0;
        prev <= 1'b0;
        data_out <= 1'b0;
    end else begin
        prev_prev <= prev;
        prev <= data_in;
        if (prev_prev == 1'b0 && prev == 1'b1 && data_in == 1'b0) begin
            data_out <= 1'b1;
        end else begin
            data_out <= 1'b0;
        end
    end
end

endmodule
