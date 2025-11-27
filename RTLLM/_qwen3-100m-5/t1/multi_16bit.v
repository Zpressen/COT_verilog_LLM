module multi_16bit (
    input clk,
    input rst_n,
    input start,
    input [15:0] ain,
    input [15:0] bin,
    output reg [31:0] yout,
    output reg done
);

reg [4:0] i; // 0 to 17
reg [15:0] areg;
reg [15:0] breg;
reg [31:0] yout_r;
reg done_r;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        i <= 5'd0;
        areg <= 16'd0;
        breg <= 16'd0;
        yout_r <= 32'd0;
        done_r <= 1'b0;
    end else begin
        if (start) begin
            if (i < 17) begin
                i <= i + 1;
                if (i == 0) begin
                    areg <= ain;
                    breg <= bin;
                    yout_r <= 32'd0;
                end else if (i > 0 && i < 17) begin
                    if (areg[i-1]) begin
                        yout_r <= yout_r + ((32'b0 + breg) << (i-1));
                    end
                end
            end
        end else begin
            i <= 5'd0;
            areg <= 16'd0;
            breg <= 16'd0;
            yout_r <= 32'd0;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        done_r <= 1'b0;
    end else begin
        if (i == 16) begin
            done_r <= 1'b1;
        end else if (i == 17) begin
            done_r <= 1'b0;
        end
    end
end

assign done = done_r;
assign yout = yout_r;

endmodule
