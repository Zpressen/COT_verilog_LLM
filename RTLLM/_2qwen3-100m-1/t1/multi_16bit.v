module multi_16bit (
    input clk,
    input rst_n,
    input start,
    input [15:0] ain,
    input [15:0] bin,
    output reg [31:0] yout,
    output reg done
);

reg [4:0] i;
reg [15:0] areg, breg;
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
            if (i < 5'd17) begin
                i <= i + 1;
            end else begin
                i <= i;
            end
        end else begin
            i <= 5'd0;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        done_r <= 1'b0;
    end else begin
        case (i)
            5'd16: done_r <= 1'b1;
            5'd17: done_r <= 1'b0;
            default: done_r <= 1'b0;
        endcase
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        areg <= 16'd0;
        breg <= 16'd0;
        yout_r <= 32'd0;
    end else if (start) begin
        if (i == 5'd0) begin
            areg <= ain;
            breg <= bin;
            yout_r <= 32'd0;
        end else if (i < 5'd17) begin
            if (areg[i-1]) begin
                yout_r <= yout_r + (breg << (i-1));
            end
        end
    end else begin
        areg <= 16'd0;
        breg <= 16'd0;
        yout_r <= 32'd0;
    end
end

assign yout = yout_r;
assign done = done_r;

endmodule
