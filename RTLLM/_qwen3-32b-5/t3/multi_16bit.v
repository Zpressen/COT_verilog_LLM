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
reg [15:0] areg;
reg [15:0] breg;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        i <= 5'd0;
    end else begin
        if (!start) begin
            i <= 5'd0;
        end else if (i < 17) begin
            i <= i + 1;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        done <= 1'b0;
    end else begin
        if (i == 16) begin
            done <= 1'b1;
        end else if (i == 17) begin
            done <= 1'b0;
        end else begin
            done <= 1'b0;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        areg <= 16'd0;
        breg <= 16'd0;
        yout <= 32'd0;
    end else begin
        if (!start) begin
            areg <= 16'd0;
            breg <= 16'd0;
            yout <= 32'd0;
        end else begin
            if (i == 0) begin
                areg <= ain;
                breg <= bin;
                yout <= 32'd0;
            end else if (i > 0 && i < 17) begin
                if (areg[i-1]) begin
                    yout <= yout + (breg << (i-1));
                end
            end
        end
    end
end

endmodule
