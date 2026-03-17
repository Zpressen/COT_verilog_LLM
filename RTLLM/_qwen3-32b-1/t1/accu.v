module accu (
    input              clk,
    input              rst_n,
    input      [7:0]   data_in,
    input              valid_in,
    output reg         valid_out,
    output reg [9:0]   data_out
);

reg [2:0] count;
reg [7:0] data_regs [0:3];

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        count <= 3'd0;
        data_regs <= '{default: 8'd0};
        data_out <= 10'd0;
        valid_out <= 1'b0;
    end else begin
        data_out <= 10'd0;
        if (valid_in) begin
            if (count < 4'd4) begin
                data_regs[count] <= data_in;
                count <= count + 1;
            end 
        end 
        if (count == 4'd4) begin 
            data_out <= data_regs[0] + data_regs[1] + data_regs[2] + data_regs[3];
            valid_out <= 1'b1;
            count <= 3'd0; 
        end else begin 
            valid_out <= 1'b0; 
        end 
    end 
end 

endmodule
