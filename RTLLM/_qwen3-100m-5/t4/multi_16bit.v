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
reg done_r;
reg [15:0] areg, breg;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        i <= 5'd0;
        done_r <= 1'b0;
        yout <= 32'd0;
        areg <= 16'd0;
        breg <= 16'd0;
    end else begin
        // Shift count logic
        if (start) begin
            if (i < 17) 
                i <= i + 1;
        end else 
            i <= 5'd0;

        // done_r logic
        if (i == 16) 
            done_r <= 1'b1;
        else if (i == 17) 
            done_r <= 1'b0;
        else 
            done_r <= done_r;

        // Shift and accumulate logic
        if (start) begin
            if (i == 0) begin
                areg <= ain;
                breg <= bin;
                yout <= 32'd0;
            end else if (i > 0 && i < 17) begin
                if (areg[i-1]) 
                    yout <= yout + (breg << (i-1));
            end
        end else begin
            areg <= 16'd0;
            breg <= 16'd0;
            yout <= 32'd0;
        end
    end
end

assign done = done_r;

endmodule
