module accu (
    input clk,
    input rst_n,
    input [7:0] data_in,
    input valid_in,
    output reg valid_out,
    output reg [9:0] data_out
);

reg [9:0] accu_sum;
reg [1:0] data_count;
reg [9:0] new_sum;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        accu_sum <= 0;
        data_count <= 0;
        valid_out <= 0;
        data_out <= 0;
    end else begin
        valid_out <= 0;
        new_sum = accu_sum;
        if (valid_in) begin
            if (data_count < 4) begin
                new_sum = accu_sum + data_in;
                if (data_count == 3) begin
                    valid_out <= 1;
                    data_out <= new_sum;
                    accu_sum <= 0;
                    data_count <= 0;
                end else begin
                    accu_sum <= new_sum;
                    data_count <= data_count + 1;
                end
            end
        end
    end
end

endmodule
