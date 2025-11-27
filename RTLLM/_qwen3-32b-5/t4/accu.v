[EGIN]
module accu (
    input clk,
    input rst_n,
    input [7:0] data_in,
    input valid_in,
    output reg valid_out,
    output reg [9:0] data_out
);

reg [2:0] counter;
reg [7:0] data_buffer [0:3];

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        counter <= 3'd0;
        valid_out <= 1'b0;
        data_out <= 10'd0;
        data_buffer[0] <= 8'd0;
        data_buffer[1] <= 8'd0;
        data_buffer[2] <= 8'd0;
        data_buffer[3] <= 8'd0;
    end else begin
        if (valid_in) begin
            if (counter < 4) begin
                data_buffer[counter] <= data_in;
                counter <= counter + 1;
            end
        end
        if (counter == 4) begin
            data_out <= data_buffer[0] + data_buffer[1] + data_buffer[2] + data_buffer[3];
            valid_out <= 1'b1;
            counter <= 3'd0;
        end else begin
            valid_out <= 1'b0;
        end
    end
end

endmodule
