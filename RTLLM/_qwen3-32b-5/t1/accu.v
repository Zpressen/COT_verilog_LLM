[BEIGN]
module accu (
    input clk,
    input rst_n,
    input [7:0] data_in,
    input valid_in,
    output reg valid_out,
    output reg [9:0] data_out
);

reg [1:0] counter;
reg [9:0] accu_sum;
reg output_pulsed;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        counter <= 2'd0;
        accu_sum <= 10'd0;
        output_pulsed <= 1'b0;
        valid_out <= 1'b0;
        data_out <= 10'd0;
    end else begin
        output_pulsed <= 1'b0;
        if (valid_in) begin
            if (counter < 4'd4) begin
                accu_sum <= accu_sum + data_in;
                counter <= counter + 1;
                if (counter == 3) begin
                    output_pulsed <= 1'b1;
                end
            end
        end
        
        if (output_pulsed) begin
            valid_out <= 1'b1;
            data_out <= accu_sum;
            accu_sum <= 10'd0;
            counter <= 2'd0;
        end else begin
            valid_out <= 1'b0;
        end
    end
end

endmodule
